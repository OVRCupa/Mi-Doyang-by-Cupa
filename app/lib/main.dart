import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'estado/controlador_doyang.dart';
import 'pantallas/pantalla_principal.dart';
import 'theme/tema_doyang.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _registrarLicenciasFuentes();
  runApp(const ProviderScope(child: MiDoyangApp()));
}

class MiDoyangApp extends ConsumerWidget {
  const MiDoyangApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDoyangProvider);
    return MaterialApp(
      title: 'Mi Doyang by Cupa',
      debugShowCheckedModeBanner: false,
      theme: construirTemaDoyang(
        colorPrimarioHex: estado.motor.academia.colorPrimarioHex,
      ),
      home: const PantallaPrincipalDoyang(),
    );
  }
}

void _registrarLicenciasFuentes() {
  LicenseRegistry.addLicense(() async* {
    final texto = await rootBundle.loadString('assets/fuentes/OFL.txt');
    yield LicenseEntryWithLineBreaks(const <String>['Oswald'], texto);
  });
}
