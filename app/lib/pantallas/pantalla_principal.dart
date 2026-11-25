import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/logo_mi_doyang.dart';
import '../theme/tema_doyang.dart';
import 'pantalla_inicio_doyang.dart';
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
    if (estado.mostrarInicio) {
      return const PantallaInicioDoyang();
    }
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
                // Barra superior institucional: Logo arriba a la izquierda y nombre de academia centrado
                Container(
                  decoration: BoxDecoration(
                    gradient: ColoresDoyang.gradienteEncabezado(
                      estado.motor.academia.colorPrimarioHex,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final logoWidget = InkWell(
                        onTap: ctrl.irAInicio,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: LogoMiDoyang(
                            compacto: true,
                            sobreOscuro: true,
                          ),
                        ),
                      );

                      final centroAcademia = Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            estado.motor.academia.nombre,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TipografiaDoyang.tituloSeccion(
                              color: ColoresDoyang.superficieTatami,
                            ),
                          ),
                          Text(
                            pendientesOutbox == 0
                                ? 'En línea · Caja sincronizada'
                                : 'Modo local · $pendientesOutbox en cola',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TipografiaDoyang.metadato(
                              color: ColoresDoyang.papelDobok,
                            ),
                          ),
                        ],
                      );

                      final chipsNavegacion = Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-inicio'),
                            etiqueta: 'Dashboard',
                            activo: false,
                            alTocar: ctrl.irAInicio,
                          ),
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-recepcion'),
                            etiqueta: 'Recepción',
                            activo: estado.rolActivo == RolUsuario.dueno ||
                                estado.rolActivo == RolUsuario.recepcion,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.dueno),
                          ),
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-padre'),
                            etiqueta: 'Padres',
                            activo: estado.rolActivo == RolUsuario.tutor,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.tutor),
                          ),
                          _ChipSelectorVista(
                            llave: const Key('selector-vista-instructor'),
                            etiqueta: 'Instructor',
                            activo: estado.rolActivo == RolUsuario.instructor,
                            alTocar: () =>
                                ctrl.cambiarRolActivo(RolUsuario.instructor),
                          ),
                        ],
                      );

                      if (constraints.maxWidth >= 980) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: logoWidget,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Center(child: centroAcademia),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: chipsNavegacion,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: logoWidget,
                          ),
                          const SizedBox(height: 4),
                          centroAcademia,
                          const SizedBox(height: 8),
                          Center(child: chipsNavegacion),
                        ],
                      );
                    },
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
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activo
              ? ColoresDoyang.azulChung
              : ColoresDoyang.tintaCinturonNegro.withValues(alpha: 0.45),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: activo
                ? ColoresDoyang.papelDobok
                : ColoresDoyang.superficieTatami.withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              etiqueta,
              style: TipografiaDoyang.metadato(
                color: ColoresDoyang.papelDobok,
                peso: activo ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
