import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/belt_widget.dart';
import '../theme/tema_doyang.dart';
import '../theme/ticket_termico_widget.dart';

/// Vista 2 · App Móvil Android — Portal del Padre de Familia (`docs/diseno.md` §6.3).
///
/// Diseñada para ancho mínimo de `360 dp` con objetivos táctiles `>= 48×48 dp`,
/// selector familiar multi-hijo, faja de cinta `BeltWidget`, bandeja de tickets
/// de comprobante, seguimiento de grados/torneos y tienda de equipo.
class VistaPadreAndroid extends ConsumerStatefulWidget {
  const VistaPadreAndroid({super.key});

  @override
  ConsumerState<VistaPadreAndroid> createState() => _VistaPadreAndroidState();
}

class _VistaPadreAndroidState extends ConsumerState<VistaPadreAndroid> {
  bool _responsivaTorneoAceptada = true;

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);
    final tutor = estado.tutorActual;
    final hijos = estado.hijosTutorActual;
    final hijo = estado.hijoActual;

    if (hijo == null) {
      return Center(
        child: Text(
          'No hay alumnos vinculados a esta cuenta familiar.',
          style: TipografiaDoyang.cuerpo(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Encabezado familiar y selector multi-hijo (pestañas >= 48 dp)
        Container(
          color: ColoresDoyang.superficieTatami,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hola, ${tutor.nombreCompleto}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    for (final h in hijos)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: h.id == hijo.id
                            ? FilledButton(
                                key: Key('tab-hijo-${h.id}'),
                                onPressed: () => ctrl.seleccionarHijo(h.id),
                                child: Text(
                                  '${h.nombre} (${h.calcularEdadAnios()})',
                                ),
                              )
                            : OutlinedButton(
                                key: Key('tab-hijo-${h.id}'),
                                onPressed: () => ctrl.seleccionarHijo(h.id),
                                child: Text(
                                  '${h.nombre} (${h.calcularEdadAnios()})',
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: _construirContenidoPestana(estado, ctrl, tutor, hijo),
          ),
        ),
        const Divider(height: 1),
        // Barra inferior de 4 destinos con objetivos táctiles >= 48 dp
        Container(
          color: ColoresDoyang.superficieTatami,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            children: <Widget>[
              _BotonDestinoInferior(
                llave: const Key('nav-padre-inicio'),
                etiqueta: 'Inicio',
                icono: Icons.home_outlined,
                activo: estado.pestanaPadreIndex == 0,
                alTocar: () => ctrl.cambiarPestanaPadre(0),
              ),
              _BotonDestinoInferior(
                llave: const Key('nav-padre-tickets'),
                etiqueta: 'Tickets',
                icono: Icons.receipt_long_outlined,
                activo: estado.pestanaPadreIndex == 1,
                alTocar: () => ctrl.cambiarPestanaPadre(1),
              ),
              _BotonDestinoInferior(
                llave: const Key('nav-padre-grados'),
                etiqueta: 'Grados',
                icono: Icons.military_tech_outlined,
                activo: estado.pestanaPadreIndex == 2,
                alTocar: () => ctrl.cambiarPestanaPadre(2),
              ),
              _BotonDestinoInferior(
                llave: const Key('nav-padre-tienda'),
                etiqueta: 'Tienda',
                icono: Icons.shopping_bag_outlined,
                activo: estado.pestanaPadreIndex == 3,
                alTocar: () => ctrl.cambiarPestanaPadre(3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirContenidoPestana(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    TutorFamilia tutor,
    Alumno hijo,
  ) {
    switch (estado.pestanaPadreIndex) {
      case 0:
        return _construirPestanaInicioHijo(estado, ctrl, tutor, hijo);
      case 1:
        return _construirPestanaTickets(estado, ctrl, tutor);
      case 2:
        return _construirPestanaGradosYEventos(estado, ctrl, hijo);
      case 3:
        return _construirPestanaTiendaEquipo(estado, ctrl, hijo);
      default:
        return _construirPestanaInicioHijo(estado, ctrl, tutor, hijo);
    }
  }

  // ── PESTAÑA 0: INICIO · MI HIJO Y ESTADO DE CUENTA ───────────────────────

  Widget _construirPestanaInicioHijo(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    TutorFamilia tutor,
    Alumno hijo,
  ) {
    final gradoActual = estado.motor.obtenerGradoPorId(hijo.gradoActualId);
    final dictamen = estado.motor.evaluarElegibilidadExamen(hijo.id);
    final cargosHijo = estado.motor
        .cargosPendientesTutor(tutor.id)
        .where((c) => c.alumnoId == hijo.id || c.alumnoId == null)
        .toList();
    final saldoHijoCentavos =
        cargosHijo.fold<int>(0, (s, c) => s + c.saldoCentavos);
    final ticketsFamilia =
        estado.motor.tickets.where((t) => t.tutorId == tutor.id).toList();
    final pedidosHijo = estado.motor.pedidosEquipo
        .where((p) => p.alumnoId == hijo.id)
        .toList();

    final requeridas = dictamen.asistenciasRequeridas > 0
        ? dictamen.asistenciasRequeridas
        : 24;
    final progreso =
        (hijo.asistenciasEnGradoActual / requeridas).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ContenedorTarjetaMovil(
          titulo: 'GRADO ACTUAL · ${hijo.nombre.toUpperCase()}',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BeltWidget(grado: gradoActual),
              const SizedBox(height: 10),
              Text(
                'Próximo grado: ${dictamen.siguienteGrado?.codigo ?? "Grado Máximo"} (${dictamen.siguienteGrado?.nombre ?? "-"})',
                style: TipografiaDoyang.celda(peso: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Asistencias: ${hijo.asistenciasEnGradoActual} de $requeridas clases (${(progreso * 100).round()}%)',
                style: TipografiaDoyang.celda(),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: ColoresDoyang.esqueletoCarga,
                color: dictamen.elegible
                    ? ColoresDoyang.jadeAprobado
                    : ColoresDoyang.azulChung,
              ),
              const SizedBox(height: 8),
              Text(
                dictamen.elegible
                    ? 'Estado examen: ELEGIBLE PARA EXAMEN ✓'
                    : 'Pendiente para examen: ${dictamen.motivos.join(" · ")}',
                style: TipografiaDoyang.metadato(
                  color: dictamen.elegible
                      ? ColoresDoyang.jadeAprobado
                      : ColoresDoyang.ambarTatami,
                  peso: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ContenedorTarjetaMovil(
          titulo: 'ESTADO DE CUENTA · ${hijo.nombre.toUpperCase()}',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                saldoHijoCentavos == 0
                    ? 'MENSUALIDAD AL DÍA ✓'
                    : 'SALDO PENDIENTE: ${formatearMxn(saldoHijoCentavos)}',
                style: TipografiaDoyang.tituloSeccion(
                  color: saldoHijoCentavos == 0
                      ? ColoresDoyang.jadeAprobado
                      : ColoresDoyang.selloHong,
                ),
              ),
              if (cargosHijo.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                for (final c in cargosHijo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${c.concepto}: ${formatearMxn(c.saldoCentavos)}',
                      style: TipografiaDoyang.celda(),
                    ),
                  ),
              ],
              if (ticketsFamilia.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('btn-ver-ultimo-recibo-padre'),
                  onPressed: () {
                    ctrl.seleccionarTicket(ticketsFamilia.last.id);
                    ctrl.cambiarPestanaPadre(1);
                  },
                  child: Text(
                    'Recibo: Ver ${ticketsFamilia.last.folio} (${formatearMxn(ticketsFamilia.last.totalPagadoCentavos)})',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ContenedorTarjetaMovil(
          titulo: 'PEDIDOS DE EQUIPO Y CREDENCIAL QR',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Credencial QR de asistencia: ${hijo.codigoQr}',
                style: TipografiaDoyang.celda(peso: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (pedidosHijo.isEmpty)
                Text(
                  'Sin pedidos de equipo activos.',
                  style: TipografiaDoyang.metadato(),
                )
              else
                for (final p in pedidosHijo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${p.nombreProductoSnapshot} (${p.tallaSnapshot}): ${_textoEstadoPedidoPadre(p.estadoEntrega)}',
                      style: TipografiaDoyang.celda(
                        color: p.estadoEntrega ==
                                EstadoEntregaEquipo.pagadoPendienteEntrega
                            ? ColoresDoyang.jadeAprobado
                            : ColoresDoyang.tintaCinturonNegro,
                        peso: FontWeight.w600,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  // ── PESTAÑA 1: BANDEJA DE TICKETS DE COMPROBANTE ─────────────────────────

  Widget _construirPestanaTickets(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    TutorFamilia tutor,
  ) {
    final tickets = estado.motor.tickets
        .where((t) => t.tutorId == tutor.id)
        .toList()
        .reversed
        .toList();
    final candidato = estado.ticketActual;
    final seleccionado = (candidato != null && candidato.tutorId == tutor.id)
        ? candidato
        : (tickets.isNotEmpty ? tickets.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ContenedorTarjetaMovil(
          titulo: 'MIS COMPROBANTES DE PAGO (${tickets.length})',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (tickets.isEmpty)
                Text(
                  'Aún no tienes tickets emitidos.',
                  style: TipografiaDoyang.celda(),
                )
              else
                for (final t in tickets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      key: Key('item-ticket-padre-${t.folio}'),
                      onPressed: () => ctrl.seleccionarTicket(t.id),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              '${t.folio} · ${t.emitidoEnIso.substring(0, 10)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(formatearMxn(t.totalPagadoCentavos)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (seleccionado != null) ...<Widget>[
          const SizedBox(height: 12),
          TicketTermicoWidget(
            ticket: seleccionado,
            academia: estado.motor.academia,
            anchoColumnas: 32,
          ),
        ],
      ],
    );
  }

  // ── PESTAÑA 2: GRADOS, HISTORIAL Y TORNEOS CON RESPONSIVA ────────────────

  Widget _construirPestanaGradosYEventos(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    Alumno hijo,
  ) {
    final gradoActual = estado.motor.obtenerGradoPorId(hijo.gradoActualId);
    final historial = estado.motor.historialGrados
        .where((h) => h.alumnoId == hijo.id)
        .toList();
    final torneo = estado.motor.torneos.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ContenedorTarjetaMovil(
          titulo: 'AVANCE DE CINTA · ${hijo.nombre.toUpperCase()}',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BeltWidget(grado: gradoActual),
              const SizedBox(height: 10),
              Text(
                'Historial de grados certificados (${historial.length}):',
                style: TipografiaDoyang.etiqueta(),
              ),
              const SizedBox(height: 4),
              for (final h in historial)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${estado.motor.obtenerGradoPorId(h.gradoId).codigo} (${estado.motor.obtenerGradoPorId(h.gradoId).nombre}) · ${h.obtenidoEnIso} · ${h.sinodal}',
                    style: TipografiaDoyang.celda(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ContenedorTarjetaMovil(
          titulo: 'CONVOCATORIA A TORNEO · ${torneo.nombre.toUpperCase()}',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Sede: ${torneo.sede}\nFecha: ${torneo.fechaEventoIso} · Cuota: ${formatearMxn(torneo.cuotaCentavos)}',
                style: TipografiaDoyang.celda(),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _responsivaTorneoAceptada,
                onChanged: (v) =>
                    setState(() => _responsivaTorneoAceptada = v ?? false),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Acepto digitalmente la carta responsiva de participación como padre/tutor de ${hijo.nombre}.',
                  style: TipografiaDoyang.metadato(
                    color: ColoresDoyang.tintaCinturonNegro,
                    peso: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton(
                key: Key('btn-inscribir-torneo-padre-${hijo.id}'),
                onPressed: () => ctrl.inscribirATorneo(
                  torneoId: torneo.id,
                  alumnoId: hijo.id,
                  modalidad: ModalidadTorneo.kyorugi,
                  pesoKg: hijo.pesoKgOpcional ?? 34.0,
                  categoriaDivision: 'Infantil Oficial WT',
                  responsivaTutorAceptada: _responsivaTorneoAceptada,
                ),
                child: Text('Inscribir a ${hijo.nombre} al torneo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── PESTAÑA 3: TIENDA DE EQUIPO DEL DOJANG ───────────────────────────────

  Widget _construirPestanaTiendaEquipo(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    Alumno hijo,
  ) {
    final pedidosHijo = estado.motor.pedidosEquipo
        .where((p) => p.alumnoId == hijo.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ContenedorTarjetaMovil(
          titulo: 'SOLICITAR EQUIPO PARA ${hijo.nombre.toUpperCase()}',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final prod in estado.motor.productosEquipo)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColoresDoyang.papelDobok,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    border: Border.all(color: ColoresDoyang.bordePiedra),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        '${prod.nombre} (Talla ${prod.talla})',
                        style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
                      ),
                      Text(
                        '${formatearMxn(prod.precioCentavos)} · Disponibles: ${prod.existencias}',
                        style: TipografiaDoyang.metadato(),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        key: Key('btn-tienda-padre-${prod.id}'),
                        onPressed: prod.existencias <= 0
                            ? null
                            : () => ctrl.solicitarEquipo(
                                  alumnoId: hijo.id,
                                  productoId: prod.id,
                                ),
                        child: Text('Solicitar para ${hijo.nombre}'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ContenedorTarjetaMovil(
          titulo: 'MIS PEDIDOS DE EQUIPO (${pedidosHijo.length})',
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (pedidosHijo.isEmpty)
                Text(
                  'Aún no has solicitado equipo para ${hijo.nombre}.',
                  style: TipografiaDoyang.celda(),
                )
              else
                for (final p in pedidosHijo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• ${p.nombreProductoSnapshot} (${p.tallaSnapshot}): ${_textoEstadoPedidoPadre(p.estadoEntrega)}',
                      style: TipografiaDoyang.celda(peso: FontWeight.w700),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContenedorTarjetaMovil extends StatelessWidget {
  final String titulo;
  final Widget hijo;

  const _ContenedorTarjetaMovil({
    required this.titulo,
    required this.hijo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresDoyang.superficieTatami,
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        border: Border.all(color: ColoresDoyang.bordePiedra),
      ),
      padding: const EdgeInsets.all(12),
      child: Material(
        color: ColoresDoyang.transparente,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(titulo, style: TipografiaDoyang.tituloSeccion()),
            const Divider(height: 14),
            hijo,
          ],
        ),
      ),
    );
  }
}

class _BotonDestinoInferior extends StatelessWidget {
  final Key llave;
  final String etiqueta;
  final IconData icono;
  final bool activo;
  final VoidCallback alTocar;

  const _BotonDestinoInferior({
    required this.llave,
    required this.etiqueta,
    required this.icono,
    required this.activo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final primario = Theme.of(context).colorScheme.primary;
    final color = activo ? primario : ColoresDoyang.tintaGrafito;
    return Expanded(
      child: InkWell(
        key: llave,
        onTap: alTocar,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: DimensionesDoyang.objetivoTactilMinimo,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: activo
                ? primario.withValues(alpha: 0.12)
                : ColoresDoyang.transparente,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icono, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TipografiaDoyang.metadato(
                  color: color,
                  peso: activo ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _textoEstadoPedidoPadre(EstadoEntregaEquipo estado) {
  switch (estado) {
    case EstadoEntregaEquipo.pendientePago:
      return 'Pago pendiente';
    case EstadoEntregaEquipo.pagadoPendienteEntrega:
      return 'Pagado · Listo para recoger';
    case EstadoEntregaEquipo.entregado:
      return 'Pagado y Entregado';
    case EstadoEntregaEquipo.cancelado:
      return 'Cancelado';
  }
}
