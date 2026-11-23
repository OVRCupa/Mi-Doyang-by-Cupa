import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/belt_widget.dart';
import '../theme/tema_doyang.dart';

/// Vista 3 · App Móvil Android — Instructor / Sabonim en Tatami (`docs/diseno.md` §6.4).
///
/// Diseñada para operarse con una sola mano de pie frente al grupo (`360 dp`
/// mínimo), con filas táctiles de `>= 56 dp`, botones de `>= 48×48 dp`,
/// visualización de alertas médicas autorizadas y pase de lista por QR.
class VistaInstructorAndroid extends ConsumerWidget {
  const VistaInstructorAndroid({super.key});

  static const _fechaHoyIso = '2026-11-23';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);
    final alumnos = estado.motor.alumnosActivos;
    final presentesHoyIds = estado.motor.asistencias
        .where((a) => a.fechaDiaIso == _fechaHoyIso)
        .map((a) => a.alumnoId)
        .toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: ColoresDoyang.superficieTatami,
              borderRadius: const BorderRadius.all(
                Radius.circular(DimensionesDoyang.radioContenedor),
              ),
              border: Border.all(color: ColoresDoyang.bordePiedra),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'PASE DE LISTA EN TATAMI · $_fechaHoyIso',
                  style: TipografiaDoyang.tituloSeccion(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Presentes hoy: ${presentesHoyIds.length} de ${alumnos.length} alumnos activos',
                  style: TipografiaDoyang.celda(
                    color: ColoresDoyang.jadeAprobado,
                    peso: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final al in alumnos) ...<Widget>[
            _TarjetaAsistenciaAlumno(
              alumno: al,
              grado: estado.motor.obtenerGradoPorId(al.gradoActualId),
              presenteHoy: presentesHoyIds.contains(al.id),
              alMarcarPresente: () => ctrl.registrarAsistenciaAlumno(
                alumnoId: al.id,
                fechaDiaIso: _fechaHoyIso,
                metodo: MetodoAsistencia.qr,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TarjetaAsistenciaAlumno extends StatelessWidget {
  final Alumno alumno;
  final GradoCinta grado;
  final bool presenteHoy;
  final VoidCallback alMarcarPresente;

  const _TarjetaAsistenciaAlumno({
    required this.alumno,
    required this.grado,
    required this.presenteHoy,
    required this.alMarcarPresente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: DimensionesDoyang.altoFilaTactil,
      ),
      decoration: BoxDecoration(
        color: ColoresDoyang.superficieTatami,
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        border: Border.all(
          color: presenteHoy
              ? ColoresDoyang.jadeAprobado
              : ColoresDoyang.bordePiedra,
          width: presenteHoy ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    alumno.nombreCompleto,
                    style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
                  ),
                  Text(
                    '${alumno.horarioGrupo} · Asistencias en cinta: ${alumno.asistenciasEnGradoActual}',
                    style: TipografiaDoyang.metadato(),
                  ),
                ],
              ),
              presenteHoy
                  ? FilledButton(
                      key: Key('btn-asistencia-${alumno.id}'),
                      onPressed: alMarcarPresente,
                      style: FilledButton.styleFrom(
                        backgroundColor: ColoresDoyang.jadeAprobado,
                      ),
                      child: const Text('PRESENTE ✓'),
                    )
                  : OutlinedButton(
                      key: Key('btn-asistencia-${alumno.id}'),
                      onPressed: alMarcarPresente,
                      child: const Text('Marcar QR +'),
                    ),
            ],
          ),
          if (alumno.tieneDatosSaludSensibles) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: ColoresDoyang.fondoHongSuave,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: ColoresDoyang.selloHong),
              ),
              child: Text(
                '[!] Alerta médica: ${alumno.alergiasCuidadosOpcional ?? "Cuidado especial"} · Sangre: ${alumno.tipoSangreOpcional ?? "-"}',
                style: TipografiaDoyang.metadato(
                  color: ColoresDoyang.selloHong,
                  peso: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          BeltWidget(grado: grado, compacto: true),
        ],
      ),
    );
  }
}
