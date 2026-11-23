import 'dart:convert';
import 'dart:io';

/// Contrato de persistencia local offline-first para el estado completo de
/// **Mi Doyang by Cupa** (D-05).
abstract interface class AlmacenDoyang {
  Future<Map<String, dynamic>?> leer();
  Future<void> guardar(Map<String, dynamic> datos);
  Future<void> borrar();
}

Future<Directory> _directorioSoporteLocal() async {
  final rutaBase = Platform.environment['LOCALAPPDATA'] ??
      Platform.environment['APPDATA'] ??
      Directory.systemTemp.path;
  final dir = Directory(
    '$rutaBase${Platform.pathSeparator}MiDoyangByCupa',
  );
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Persistencia atómica en archivo JSON dentro del directorio privado de
/// soporte de la aplicación (excluido de respaldos no cifrados en Android).
class AlmacenArchivoDoyang implements AlmacenDoyang {
  AlmacenArchivoDoyang({Future<Directory> Function()? directorio})
      : _directorio = directorio ?? _directorioSoporteLocal;

  final Future<Directory> Function() _directorio;
  Future<void> _cola = Future<void>.value();

  Future<File> _archivo() async => File(
        '${(await _directorio()).path}${Platform.pathSeparator}mi_doyang_estado.json',
      );

  Future<void> _encolar(Future<void> Function() tarea) {
    final siguiente = _cola.then((_) => tarea());
    _cola = siguiente.then((_) {}, onError: (Object _) {});
    return siguiente;
  }

  @override
  Future<Map<String, dynamic>?> leer() async {
    try {
      final f = await _archivo();
      if (!await f.exists()) return null;
      final decodificado = jsonDecode(await f.readAsString());
      return decodificado is Map
          ? Map<String, dynamic>.from(decodificado)
          : null;
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> guardar(Map<String, dynamic> datos) {
    final texto = jsonEncode(datos);
    return _encolar(() async {
      final f = await _archivo();
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsString(texto, flush: true);
      await tmp.rename(f.path);
    });
  }

  @override
  Future<void> borrar() => _encolar(() async {
        final f = await _archivo();
        if (await f.exists()) {
          await f.delete();
        }
      });
}

/// Almacén en memoria para pruebas unitarias y de widgets.
class AlmacenMemoriaDoyang implements AlmacenDoyang {
  Map<String, dynamic>? datos;

  @override
  Future<Map<String, dynamic>?> leer() async => datos == null
      ? null
      : Map<String, dynamic>.from(jsonDecode(jsonEncode(datos)) as Map);

  @override
  Future<void> guardar(Map<String, dynamic> d) async {
    datos = Map<String, dynamic>.from(jsonDecode(jsonEncode(d)) as Map);
  }

  @override
  Future<void> borrar() async {
    datos = null;
  }
}
