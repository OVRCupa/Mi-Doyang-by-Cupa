import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/tema_doyang.dart';
import 'vista_instructor_android.dart';
import 'vista_padre_android.dart';
import 'vista_recepcion_windows.dart';

/// Contenedor principal de **Mi Doyang by Cupa** que conecta el mismo estado
/// reactivo (`ControladorDoyang`) con las 3 experiencias del producto:
/// 1. Recepción / Dueño (Escritorio Windows)
/// 2. Portal del Padre de Familia (Móvil Android)
/// 3. Instructor / Sabonim en Tatami (Móvil Android)
class PantallaPrincipalDoyang extends ConsumerWidget {
  const PantallaPrincipalDoyang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);
    final pendientesOutbox =
        estado.motor.colaOutbox.where((e) => !e.sincronizado).length;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.f2): () {
          ctrl.cambiarRolActivo(RolUsuario.dueno);
          ctrl.cambiarSeccionRecepcion(0);
        },
        const SingleActivator(LogicalKeyboardKey.f3): () {
          ctrl.cambiarRolActivo(RolUsuario.dueno);
          ctrl.cambiarSeccionRecepcion(1);
        },
        const SingleActivator(LogicalKeyboardKey.f4): () {
          if (estado.rolActivo == RolUsuario.dueno ||
              estado.rolActivo == RolUsuario.recepcion) {
            ctrl.generarMensualidadesFamiliaSeleccionada();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Barra superior institucional con selector de vista/rol
                Container(
                  color: ColoresDoyang.tintaCinturonNegro,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: ColoresDoyang.selloHong,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text(
                              'MI DOYANG BY CUPA',
                              style: TipografiaDoyang.metadato(
                                color: ColoresDoyang.papelDobok,
                                peso: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${estado.motor.academia.nombre} · ${pendientesOutbox == 0 ? "En línea" : "Local ($pendientesOutbox en cola)"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TipografiaDoyang.celda(
                              color: ColoresDoyang.papelDobok,
                              peso: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-recepcion'),
                            etiqueta: 'Recepción (Windows)',
                            activo: estado.rolActivo == RolUsuario.dueno ||
                                estado.rolActivo == RolUsuario.recepcion,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.dueno),
                          ),
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-padre'),
                            etiqueta: 'Portal Padre (Android)',
                            activo: estado.rolActivo == RolUsuario.tutor,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.tutor),
                          ),
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-instructor'),
                            etiqueta: 'Instructor (Android)',
                            activo: estado.rolActivo == RolUsuario.instructor,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.instructor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Avisos de retroalimentación inmediata
                if (estado.avisoExito != null || estado.avisoError != null)
                  Container(
                    color: estado.avisoError != null
                        ? ColoresDoyang.fondoHongSuave
                        : ColoresDoyang.fondoJadeSuave,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            estado.avisoError ?? estado.avisoExito!,
                            style: TipografiaDoyang.celda(
                              color: estado.avisoError != null
                                  ? ColoresDoyang.selloHong
                                  : ColoresDoyang.jadeAprobado,
                              peso: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: ctrl.limpiarAvisos,
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _construirVistaPorRol(estado.rolActivo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirVistaPorRol(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.dueno:
      case RolUsuario.recepcion:
        return const VistaRecepcionWindows();
      case RolUsuario.tutor:
        return const VistaPadreAndroid();
      case RolUsuario.instructor:
        return const VistaInstructorAndroid();
    }
  }
}

class _ChipSelectorVista extends StatelessWidget {
  final Key llave;
  final String etiqueta;
  final bool activo;
  final VoidCallback alTocar;

  const _ChipSelectorVista({
    required this.llave,
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: llave,
      onTap: alTocar,
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 38,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: activo
              ? ColoresDoyang.azulChung
              : ColoresDoyang.bordeActivo.withAlpha(80),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          border: Border.all(
            color: activo
                ? ColoresDoyang.papelDobok
                : ColoresDoyang.bordeActivo,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          etiqueta,
          style: TipografiaDoyang.metadato(
            color: ColoresDoyang.papelDobok,
            peso: activo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
