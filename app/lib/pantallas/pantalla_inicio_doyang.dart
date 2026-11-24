import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/tema_doyang.dart';

/// Pantalla de Inicio amigable de **Mi Doyang by Cupa**, inspirada en el estilo
/// visual de **CUPA Taekwondo** y **CUPA Scanner** (encabezado con degradado
/// marino/personalizable, tarjetas claras con bordes suaves y botones grandes).
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

    return Scaffold(
      backgroundColor: ColoresDoyang.papelDobok,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // ── Encabezado estilo CupaHeader con color editable ──────────
            Container(
              decoration: BoxDecoration(
                gradient: ColoresDoyang.gradienteEncabezado(
                  academia.colorPrimarioHex,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: ColoresDoyang.selloHong,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      'MI DOYANG BY CUPA',
                      style: TipografiaDoyang.metadato(
                        color: ColoresDoyang.superficieTatami,
                        peso: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    academia.nombre,
                    style: TipografiaDoyang.granTotal(
                      color: ColoresDoyang.superficieTatami,
                    ),
                  ),
                  if (academia.lema.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      academia.lema,
                      style: TipografiaDoyang.cuerpo(
                        color: ColoresDoyang.papelDobok,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
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

            // ── Tarjetas de acceso rápido por perfil ─────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '¿Cómo deseas entrar hoy?',
                    style: TipografiaDoyang.tituloSeccion(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige tu espacio de trabajo. Todos los cambios se reflejan al instante entre escritorio y celular.',
                    style: TipografiaDoyang.celda(
                      color: ColoresDoyang.tintaGrafito,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _TarjetaAccesoInicio(
                    llave: const Key('inicio-entrar-recepcion'),
                    icono: Icons.point_of_sale_rounded,
                    colorAcento: ColoresDoyang.primarioAcademiaAccesible(
                      academia.colorPrimarioHex,
                    ),
                    titulo: 'Recepción y Administración',
                    descripcion:
                        'Cobra mensualidades, emite tickets con QR, gestiona alumnos, exámenes Kup/Poom/Dan, equipo y torneos.',
                    etiquetaBoton: 'Entrar a Recepción',
                    alTocar: () {
                      ctrl.cambiarRolActivo(RolUsuario.dueno);
                      ctrl.salirDeInicio();
                    },
                  ),
                  const SizedBox(height: 12),
                  _TarjetaAccesoInicio(
                    llave: const Key('inicio-entrar-padres'),
                    icono: Icons.family_restroom_rounded,
                    colorAcento: ColoresDoyang.jadeAprobado,
                    titulo: 'Portal de Padres de Familia',
                    descripcion:
                        'Consulta a tus hijos, su avance de cinta Kup/Poom/Dan, descarga tickets de pago y solicita equipo o torneos.',
                    etiquetaBoton: 'Entrar como Padre / Tutor',
                    alTocar: () {
                      ctrl.cambiarRolActivo(RolUsuario.tutor);
                      ctrl.salirDeInicio();
                    },
                  ),
                  const SizedBox(height: 12),
                  _TarjetaAccesoInicio(
                    llave: const Key('inicio-entrar-instructor'),
                    icono: Icons.sports_martial_arts_rounded,
                    colorAcento: ColoresDoyang.selloHong,
                    titulo: 'Instructor en Tatami',
                    descripcion:
                        'Pasa lista por código QR o toque rápido y consulta alertas médicas autorizadas antes de clase.',
                    etiquetaBoton: 'Entrar como Instructor',
                    alTocar: () {
                      ctrl.cambiarRolActivo(RolUsuario.instructor);
                      ctrl.salirDeInicio();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Acceso rápido a personalizar colores de la academia
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
                          'PERSONALIZA EL COLOR DE TU ACADEMIA',
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
        color: ColoresDoyang.superficieTatami.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
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
