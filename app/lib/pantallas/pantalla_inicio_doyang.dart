import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/logo_mi_doyang.dart';
import '../theme/tema_doyang.dart';

/// Pantalla de Inicio amigable de **Mi Doyang by Cupa**, con fondo fotográfico
/// de academia de Taekwondo, el logo oficial con la "O" dividida azul/rojo
/// (estilo OVR CUPA) + "By Cupa" debajo, y botones claros para iniciar.
class PantallaInicioDoyang extends ConsumerWidget {
  const PantallaInicioDoyang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);
    final academia = estado.motor.academia;
    final alumnosActivos = estado.motor.alumnosActivos.length;
    final ticketsVigentes =
        estado.motor.tickets.where((t) => !t.cancelado).length;
    final corte = estado.motor.calcularCorteCaja();
    final primario =
        ColoresDoyang.primarioAcademiaAccesible(academia.colorPrimarioHex);

    return Scaffold(
      backgroundColor: ColoresDoyang.papelDobok,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // ── Hero con imagen de fondo de academia de Taekwondo + Logo ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Image.asset(
                      'assets/imagenes/fondo_academia_tkd.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        decoration: BoxDecoration(
                          gradient: ColoresDoyang.gradienteEncabezado(
                            academia.colorPrimarioHex,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            ColoresDoyang.tintaCinturonNegro
                                .withValues(alpha: 0.52),
                            primario.withValues(alpha: 0.32),
                            ColoresDoyang.tintaCinturonNegro
                                .withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const LogoMiDoyang(compacto: false, sobreOscuro: true),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ColoresDoyang.tintaCinturonNegro
                                  .withValues(alpha: 0.45),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                color: ColoresDoyang.superficieTatami
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              academia.nombre,
                              textAlign: TextAlign.center,
                              style: TipografiaDoyang.cuerpo(
                                color: ColoresDoyang.superficieTatami,
                                peso: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (academia.lema.trim().isNotEmpty) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              academia.lema,
                              textAlign: TextAlign.center,
                              style: TipografiaDoyang.celda(
                                color: ColoresDoyang.papelDobok,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: <Widget>[
                              _PillResumenInicio(
                                etiqueta: 'Alumnos activos',
                                valor: '$alumnosActivos',
                              ),
                              _PillResumenInicio(
                                etiqueta: 'Tickets emitidos',
                                valor: '$ticketsVigentes',
                              ),
                              _PillResumenInicio(
                                etiqueta: 'Cobrado hoy',
                                valor: formatearMxn(corte.totalCobradoCentavos),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Botones de Iniciar por perfil ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Iniciar sesión en tu espacio',
                    style: TipografiaDoyang.tituloSeccion(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona tu perfil para comenzar. Todas las pestañas comparten el mismo estado en tiempo real.',
                    style: TipografiaDoyang.celda(
                      color: ColoresDoyang.tintaGrafito,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, c) {
                      final tarjetas = <Widget>[
                        _TarjetaAccesoInicio(
                          llave: const Key('inicio-entrar-recepcion'),
                          icono: Icons.point_of_sale_rounded,
                          colorAcento: primario,
                          titulo: 'Recepción y Administración',
                          descripcion:
                              'Cobra mensualidades, emite tickets con QR, gestiona alumnos, exámenes Kup/Poom/Dan, equipo y torneos.',
                          etiquetaBoton: 'Iniciar en Recepción',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.dueno);
                            ctrl.salirDeInicio();
                          },
                        ),
                        _TarjetaAccesoInicio(
                          llave: const Key('inicio-entrar-padres'),
                          icono: Icons.family_restroom_rounded,
                          colorAcento: ColoresDoyang.jadeAprobado,
                          titulo: 'Portal de Padres de Familia',
                          descripcion:
                              'Visualiza a tus hijos, avance de cintas Kup/Poom/Dan, tickets de comprobante de pago, equipo y torneos.',
                          etiquetaBoton: 'Iniciar como Padre / Tutor',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.tutor);
                            ctrl.salirDeInicio();
                          },
                        ),
                        _TarjetaAccesoInicio(
                          llave: const Key('inicio-entrar-instructor'),
                          icono: Icons.sports_martial_arts_rounded,
                          colorAcento: ColoresDoyang.selloHong,
                          titulo: 'Instructor en Tatami',
                          descripcion:
                              'Pasa lista por código QR o toque rápido y consulta alertas médicas autorizadas antes de clase.',
                          etiquetaBoton: 'Iniciar como Instructor',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.instructor);
                            ctrl.salirDeInicio();
                          },
                        ),
                      ];
                      if (c.maxWidth >= 920) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: tarjetas[0]),
                            const SizedBox(width: 12),
                            Expanded(child: tarjetas[1]),
                            const SizedBox(width: 12),
                            Expanded(child: tarjetas[2]),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          tarjetas[0],
                          const SizedBox(height: 12),
                          tarjetas[1],
                          const SizedBox(height: 12),
                          tarjetas[2],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.superficieTatami,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(DimensionesDoyang.radioContenedor),
                      ),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'COLOR EDITABLE DE TU ACADEMIA',
                          style: TipografiaDoyang.etiqueta(),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final preset
                                in ColoresDoyang.presetsColorAcademia)
                              OutlinedButton(
                                onPressed: () =>
                                    ctrl.actualizarColorPrimarioRapido(
                                  preset.$2,
                                ),
                                child: Text(preset.$1),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillResumenInicio extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _PillResumenInicio({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColoresDoyang.tintaCinturonNegro.withValues(alpha: 0.48),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(
          color: ColoresDoyang.superficieTatami.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            etiqueta,
            style: TipografiaDoyang.metadato(
              color: ColoresDoyang.papelDobok,
            ),
          ),
          Text(
            valor,
            style: TipografiaDoyang.cuerpo(
              color: ColoresDoyang.superficieTatami,
              peso: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaAccesoInicio extends StatelessWidget {
  final Key llave;
  final IconData icono;
  final Color colorAcento;
  final String titulo;
  final String descripcion;
  final String etiquetaBoton;
  final VoidCallback alTocar;

  const _TarjetaAccesoInicio({
    required this.llave,
    required this.icono,
    required this.colorAcento,
    required this.titulo,
    required this.descripcion,
    required this.etiquetaBoton,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresDoyang.superficieTatami,
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        border: Border.all(color: ColoresDoyang.bordePiedra),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorAcento.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Icon(icono, color: colorAcento, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TipografiaDoyang.tituloSeccion(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            style: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: llave,
            onPressed: alTocar,
            child: Text(etiquetaBoton),
          ),
        ],
      ),
    );
  }
}
