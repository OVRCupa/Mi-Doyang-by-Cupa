import 'dart:convert';

import 'almacen_doyang_web.dart'
    if (dart.library.io) 'almacen_doyang_io.dart' as impl;

export 'almacen_doyang_web.dart'
    if (dart.library.io) 'almacen_doyang_io.dart' show AlmacenArchivoDoyang;

/// Contrato de persistencia local offline-first para el estado completo de
/// **Mi Doyang by Cupa** (D-05).
abstract interface class AlmacenDoyang {
  Future<Map<String, dynamic>?> leer();
  Future<void> guardar(Map<String, dynamic> datos);
  Future<void> borrar();
}

AlmacenDoyang crearAlmacenPorDefecto() => impl.crearAlmacenPlataforma();

/// Almacén en memoria para pruebas unitarias, de widgets y vista web.
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
