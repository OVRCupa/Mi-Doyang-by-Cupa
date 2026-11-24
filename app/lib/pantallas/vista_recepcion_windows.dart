import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/belt_widget.dart';
import '../theme/tema_doyang.dart';
import '../theme/ticket_termico_widget.dart';

/// Vista 1 · Escritorio Windows — Recepción, Caja Offline-First y Administración
/// (`docs/diseno.md` §6.1 y §6.2).
///
/// Cuando el ancho lógico efectivo es `< 1100 dp` (ej. `1366×768` al 125%/150%
/// o texto escalado al 130%), la navegación lateral colapsa automáticamente a
/// un riel compacto de `76 dp` para preservar el área de trabajo sin desbordes.
class VistaRecepcionWindows extends ConsumerStatefulWidget {
  const VistaRecepcionWindows({super.key});

  @override
  ConsumerState<VistaRecepcionWindows> createState() =>
      _VistaRecepcionWindowsState();
}

class _VistaRecepcionWindowsState extends ConsumerState<VistaRecepcionWindows> {
  MetodoPago _metodoPago = MetodoPago.efectivo;
  final TextEditingController _referenciaPagoCtrl = TextEditingController();
  final TextEditingController _abonoParcialCtrl = TextEditingController();

  // Campos de alta de familia y alumno (M2 + LFPDPPP 2025)
  final TextEditingController _nombreTutorCtrl = TextEditingController();
  final TextEditingController _telefonoTutorCtrl = TextEditingController();
  final TextEditingController _correoTutorCtrl = TextEditingController();
  final TextEditingController _nombreAlumnoCtrl = TextEditingController();
  final TextEditingController _apellidosAlumnoCtrl = TextEditingController();
  final TextEditingController _fechaNacAlumnoCtrl =
      TextEditingController(text: '2016-08-15');
  final TextEditingController _tipoSangreCtrl = TextEditingController();
  final TextEditingController _alergiasCtrl = TextEditingController();
  bool _patriaPotestad = true;
  bool _avisoIntegral = true;
  // Casillas opcionales desmarcadas por defecto (LFPDPPP 2025)
  bool _consentimientoSalud = false;
  bool _consentimientoFoto = false;
  bool _consentimientoPromociones = false;

  // Campos de personalización de la academia (M1)
  late TextEditingController _nombreAcadCtrl;
  late TextEditingController _lemaAcadCtrl;
  late TextEditingController _colorAcadCtrl;
  late TextEditingController _mensualidadAcadCtrl;
  late TextEditingController _desc2HermanoCtrl;
  late TextEditingController _desc3HermanoCtrl;

  @override
  void initState() {
    super.initState();
    final acad = ref.read(controladorDoyangProvider).motor.academia;
    _nombreAcadCtrl = TextEditingController(text: acad.nombre);
    _lemaAcadCtrl = TextEditingController(text: acad.lema);
    _colorAcadCtrl = TextEditingController(text: acad.colorPrimarioHex);
    _mensualidadAcadCtrl = TextEditingController(
      text: (acad.mensualidadBaseCentavos ~/ 100).toString(),
    );
    _desc2HermanoCtrl = TextEditingController(
      text: acad.descuentoSegundoHermanoPct.toString(),
    );
    _desc3HermanoCtrl = TextEditingController(
      text: acad.descuentoTercerHermanoPct.toString(),
    );
  }

  @override
  void dispose() {
    _referenciaPagoCtrl.dispose();
    _abonoParcialCtrl.dispose();
    _nombreTutorCtrl.dispose();
    _telefonoTutorCtrl.dispose();
    _correoTutorCtrl.dispose();
    _nombreAlumnoCtrl.dispose();
    _apellidosAlumnoCtrl.dispose();
    _fechaNacAlumnoCtrl.dispose();
    _tipoSangreCtrl.dispose();
    _alergiasCtrl.dispose();
    _nombreAcadCtrl.dispose();
    _lemaAcadCtrl.dispose();
    _colorAcadCtrl.dispose();
    _mensualidadAcadCtrl.dispose();
    _desc2HermanoCtrl.dispose();
    _desc3HermanoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovilEstrecho = constraints.maxWidth < 600;
        final usarRailCompacto = constraints.maxWidth <
            DimensionesDoyang.puntoQuiebreEscritorioCompacto;

        if (esMovilEstrecho) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _BarraNavegacionHorizontalMovil(
                indiceActivo: estado.seccionRecepcionIndex,
                alSeleccionar: ctrl.cambiarSeccionRecepcion,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _construirSeccionActiva(
                    context,
                    estado,
                    ctrl,
                    constraints.maxWidth,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _BarraNavegacionLateral(
              compacto: usarRailCompacto,
              indiceActivo: estado.seccionRecepcionIndex,
              pendientesOutbox: estado.motor.colaOutbox
                  .where((e) => !e.sincronizado)
                  .length,
              alSeleccionar: ctrl.cambiarSeccionRecepcion,
              alSincronizar: ctrl.sincronizarColaOutbox,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _construirSeccionActiva(
                  context,
                  estado,
                  ctrl,
                  constraints.maxWidth,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construirSeccionActiva(
    BuildContext context,
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    double anchoDisponible,
  ) {
    switch (estado.seccionRecepcionIndex) {
      case 0:
        return _construirSeccionCajaYTickets(
          estado,
          ctrl,
          anchoDisponible,
        );
      case 1:
        return _construirSeccionAlumnosYPrivacidadArco(estado, ctrl);
      case 2:
        return _construirSeccionExamenesYGrados(estado, ctrl);
      case 3:
        return _construirSeccionEquipoEInventario(estado, ctrl);
      case 4:
        return _construirSeccionTorneosYCupa(estado, ctrl);
      case 5:
        return _construirSeccionPersonalizacionDojang(estado, ctrl);
      default:
        return _construirSeccionCajaYTickets(
          estado,
          ctrl,
          anchoDisponible,
        );
    }
  }

  // ── SECCIÓN 0: M3 · CAJA, COBROS Y TICKETS TÉRMICOS ──────────────────────

  Widget _construirSeccionCajaYTickets(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
    double anchoDisponible,
  ) {
    final tutor = estado.tutorActual;
    final hijos = estado.hijosTutorActual;
    final cargosPendientes = estado.motor.cargosPendientesTutor(tutor.id);
    final totalPendienteCentavos =
        cargosPendientes.fold<int>(0, (s, c) => s + c.saldoCentavos);
    final corte = estado.motor.calcularCorteCaja();
    final ticketActual = estado.ticketActual;

    final panelCobro = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TarjetaSeccion(
          titulo: 'FAMILIA Y ESTADO DE CUENTA EN MOSTRADOR',
          accionEncabezado: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final t in estado.motor.tutores.where((x) => !x.bloqueadoArco))
                t.id == tutor.id
                    ? FilledButton(
                        onPressed: () => ctrl.seleccionarTutor(t.id),
                        child: Text(t.nombreCompleto),
                      )
                    : OutlinedButton(
                        onPressed: () => ctrl.seleccionarTutor(t.id),
                        child: Text(t.nombreCompleto),
                      ),
            ],
          ),
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Tutor titular: ${tutor.nombreCompleto} · WhatsApp: ${tutor.telefonoWhatsapp} · ${hijos.length} hijo(s)',
                style: TipografiaDoyang.celda(
                  color: ColoresDoyang.tintaGrafito,
                  peso: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              for (final al in hijos) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${al.nombreCompleto} (${al.calcularEdadAnios()} años)',
                            style: TipografiaDoyang.cuerpo(
                              peso: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${al.horarioGrupo} · Asistencias en grado: ${al.asistenciasEnGradoActual}',
                            style: TipografiaDoyang.metadato(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: BeltWidget(
                        grado: estado.motor.obtenerGradoPorId(al.gradoActualId),
                        compacto: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _TarjetaSeccion(
          titulo: 'CARGOS POR COBRAR (${cargosPendientes.length})',
          accionEncabezado: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => ctrl.generarMensualidadesFamiliaSeleccionada(
                  periodo: '2026-12',
                ),
                child: const Text('+ Mensualidades Dic'),
              ),
              OutlinedButton(
                onPressed: () => ctrl.aplicarMoraVencidos(),
                child: const Text('Aplicar mora'),
              ),
            ],
          ),
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (cargosPendientes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'La familia está al corriente. No hay cargos con saldo pendiente.',
                    style: TipografiaDoyang.cuerpo(
                      color: ColoresDoyang.jadeAprobado,
                      peso: FontWeight.w600,
                    ),
                  ),
                )
              else
                for (final cargo in cargosPendientes)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.papelDobok,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              cargo.concepto,
                              style: TipografiaDoyang.cuerpo(
                                peso: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Vence: ${cargo.fechaVencimientoIso} · Total: ${formatearMxn(cargo.totalCentavos)} · Pagado: ${formatearMxn(cargo.pagadoCentavos)}',
                              style: TipografiaDoyang.metadato(),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              'Saldo: ${formatearMxn(cargo.saldoCentavos)}',
                              style: TipografiaDoyang.cuerpo(
                                color: ColoresDoyang.selloHong,
                                peso: FontWeight.w700,
                              ),
                            ),
                            FilledButton(
                              key: Key('btn-cobrar-cargo-${cargo.id}'),
                              onPressed: () {
                                ctrl.cobrarCargos(
                                  tutorId: tutor.id,
                                  abonosPorCargoId: <String, int>{
                                    cargo.id: cargo.saldoCentavos,
                                  },
                                  metodoPago: _metodoPago,
                                  referenciaPagoOpcional:
                                      _referenciaPagoCtrl.text,
                                );
                              },
                              child: const Text('Liquidar cargo'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              const Divider(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Método de pago:',
                    style: TipografiaDoyang.etiqueta(),
                  ),
                  for (final m in MetodoPago.values)
                    _metodoPago == m
                        ? FilledButton(
                            onPressed: () => setState(() => _metodoPago = m),
                            child: Text(m.name.toUpperCase()),
                          )
                        : OutlinedButton(
                            onPressed: () => setState(() => _metodoPago = m),
                            child: Text(m.name.toUpperCase()),
                          ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _referenciaPagoCtrl,
                      decoration: const InputDecoration(
                        labelText:
                            'Referencia SPEI / Autorización terminal (sin PAN ni CVV)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _abonoParcialCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Abono parcial al primer cargo (MXN)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'GRAN TOTAL PENDIENTE DE LA FAMILIA',
                        style: TipografiaDoyang.etiqueta(),
                      ),
                      Text(
                        formatearMxn(totalPendienteCentavos),
                        style: TipografiaDoyang.granTotal(
                          color: totalPendienteCentavos > 0
                              ? ColoresDoyang.tintaCinturonNegro
                              : ColoresDoyang.jadeAprobado,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (cargosPendientes.isNotEmpty)
                        OutlinedButton(
                          onPressed: () {
                            final pesos =
                                int.tryParse(_abonoParcialCtrl.text.trim()) ??
                                    300;
                            final saldo = cargosPendientes.first.saldoCentavos;
                            final minimo = saldo < 100 ? saldo : 100;
                            final centavos =
                                (pesos * 100).clamp(minimo, saldo);
                            ctrl.cobrarCargos(
                              tutorId: tutor.id,
                              abonosPorCargoId: <String, int>{
                                cargosPendientes.first.id: centavos,
                              },
                              metodoPago: _metodoPago,
                              referenciaPagoOpcional: _referenciaPagoCtrl.text,
                            );
                          },
                          child: const Text('Registrar abono parcial'),
                        ),
                      FilledButton(
                        key: const Key('btn-cobrar-todo-familia'),
                        onPressed: cargosPendientes.isEmpty
                            ? null
                            : () {
                                final mapa = <String, int>{
                                  for (final c in cargosPendientes)
                                    c.id: c.saldoCentavos,
                                };
                                ctrl.cobrarCargos(
                                  tutorId: tutor.id,
                                  abonosPorCargoId: mapa,
                                  metodoPago: _metodoPago,
                                  referenciaPagoOpcional:
                                      _referenciaPagoCtrl.text,
                                );
                              },
                        child: const Text(
                          '[F2] Cobrar e imprimir',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _TarjetaSeccion(
          titulo: 'CORTE DE CAJA DEL DÍA',
          hijo: Wrap(
            spacing: 24,
            runSpacing: 10,
            children: <Widget>[
              _IndicadorResumen(
                etiqueta: 'Total cobrado',
                valor: formatearMxn(corte.totalCobradoCentavos),
                destacado: true,
              ),
              _IndicadorResumen(
                etiqueta: 'Efectivo',
                valor: formatearMxn(corte.totalEfectivoCentavos),
              ),
              _IndicadorResumen(
                etiqueta: 'Transferencia SPEI',
                valor: formatearMxn(corte.totalTransferenciaCentavos),
              ),
              _IndicadorResumen(
                etiqueta: 'Terminal externa',
                valor: formatearMxn(corte.totalTerminalCentavos),
              ),
              _IndicadorResumen(
                etiqueta: 'Tickets vigentes / cancelados',
                valor:
                    '${corte.ticketsVigentesCount} / ${corte.ticketsCanceladosCount}',
              ),
            ],
          ),
        ),
      ],
    );

    final panelTicket = _TarjetaSeccion(
      titulo: 'TICKET DE COMPROBANTE · VISTA PREVIA',
      accionEncabezado: Wrap(
        spacing: 6,
        children: <Widget>[
          estado.anchoTicketColumnas == 48
              ? FilledButton(
                  onPressed: () => ctrl.cambiarAnchoTicket(48),
                  child: const Text('80 mm (48 col)'),
                )
              : OutlinedButton(
                  onPressed: () => ctrl.cambiarAnchoTicket(48),
                  child: const Text('80 mm (48 col)'),
                ),
          estado.anchoTicketColumnas == 32
              ? FilledButton(
                  onPressed: () => ctrl.cambiarAnchoTicket(32),
                  child: const Text('58 mm (32 col)'),
                )
              : OutlinedButton(
                  onPressed: () => ctrl.cambiarAnchoTicket(32),
                  child: const Text('58 mm (32 col)'),
                ),
        ],
      ),
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (ticketActual != null) ...<Widget>[
            TicketTermicoWidget(
              ticket: ticketActual,
              academia: estado.motor.academia,
              anchoColumnas: estado.anchoTicketColumnas,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => ctrl.exportarTicketEscPos(ticketActual),
                  child: const Text('Generar térmico ESC/POS'),
                ),
                OutlinedButton(
                  onPressed: () => ctrl.exportarTicketImprimible(ticketActual),
                  child: const Text('Guardar HTML / PDF'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!ticketActual.cancelado)
              OutlinedButton(
                onPressed: () => ctrl.cancelarTicketConReverso(
                  ticketId: ticketActual.id,
                  motivo: 'Cancelación y reverso autorizado en mostrador',
                ),
                child: Text('Cancelar ticket ${ticketActual.folio} (Reverso)'),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            'HISTORIAL DE TICKETS EMITIDOS (${estado.motor.tickets.length})',
            style: TipografiaDoyang.etiqueta(),
          ),
          const SizedBox(height: 6),
          for (final t in estado.motor.tickets.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: OutlinedButton(
                onPressed: () => ctrl.seleccionarTicket(t.id),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        '${t.folio} · ${t.cancelado ? "CANCELADO" : "PAGADO"}',
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
    );

    if (anchoDisponible >= 980) {
      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 6, child: panelCobro),
            const SizedBox(width: 14),
            Expanded(flex: 5, child: panelTicket),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          panelCobro,
          const SizedBox(height: 14),
          panelTicket,
        ],
      ),
    );
  }

  // ── SECCIÓN 1: M2 · ALUMNOS, FAMILIAS Y PRIVACIDAD ARCO (LFPDPPP 2025) ──

  Widget _construirSeccionAlumnosYPrivacidadArco(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TarjetaSeccion(
            titulo:
                'PADRÓN DE ALUMNOS Y DERECHOS ARCO (${estado.motor.alumnos.length})',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final al in estado.motor.alumnos)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.papelDobok,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
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
                                  '${al.nombreCompleto} · QR: ${al.codigoQr}',
                                  style: TipografiaDoyang.cuerpo(
                                    peso: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Grupo: ${al.horarioGrupo} · Asistencias: ${al.asistenciasEnGradoActual} · Estado: ${al.bloqueadoArco ? "BLOQUEADO ARCO" : "ACTIVO"}',
                                  style: TipografiaDoyang.metadato(),
                                ),
                                if (al.tieneDatosSaludSensibles)
                                  Text(
                                    '[!] Alerta médica autorizada: Sangre ${al.tipoSangreOpcional ?? "-"} · ${al.alergiasCuidadosOpcional ?? "Sin alergias"}',
                                    style: TipografiaDoyang.metadato(
                                      color: ColoresDoyang.selloHong,
                                      peso: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                OutlinedButton(
                                  onPressed: () =>
                                      ctrl.exportarExpedienteArco(al.tutorId),
                                  child: const Text('Exportar expediente ARCO'),
                                ),
                                if (!al.bloqueadoArco)
                                  OutlinedButton(
                                    onPressed: () =>
                                        ctrl.ejecutarBajaArco(alumnoId: al.id),
                                    child: const Text('Baja / Bloqueo ARCO'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BeltWidget(
                          grado:
                              estado.motor.obtenerGradoPorId(al.gradoActualId),
                          compacto: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TarjetaSeccion(
            titulo:
                'ALTA DE FAMILIA Y ALUMNO · AVISO DE PRIVACIDAD SIMPLIFICADO (LFPDPPP 2025)',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColoresDoyang.fondoAzulSuave,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: ColoresDoyang.azulChung),
                  ),
                  child: Text(
                    'AVISO DE PRIVACIDAD SIMPLIFICADO: "${estado.motor.academia.nombre}" es Responsable del tratamiento de los datos personales del alumno y su padre/tutor para gestión escolar, control de grados, cobranza y seguridad en el tatami. CUPA (Mi Doyang by Cupa) actúa como Encargada tecnológica. Nunca solicitamos ni almacenamos números de tarjeta bancaria ni CVV.',
                    style: TipografiaDoyang.celda(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _nombreTutorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo del Padre/Tutor',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _telefonoTutorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp Tutor',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _correoTutorCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Correo del Tutor',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _nombreAlumnoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre(s) del Alumno',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _apellidosAlumnoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Apellidos del Alumno',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _fechaNacAlumnoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nacimiento (YYYY-MM-DD)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: _patriaPotestad,
                  onChanged: (v) => setState(() => _patriaPotestad = v ?? false),
                  title: Text(
                    '[Obligatorio menores] Declaro bajo protesta de decir verdad ejercer la patria potestad o tutela legal del menor.',
                    style: TipografiaDoyang.celda(peso: FontWeight.w600),
                  ),
                ),
                CheckboxListTile(
                  value: _avisoIntegral,
                  onChanged: (v) => setState(() => _avisoIntegral = v ?? false),
                  title: Text(
                    '[Obligatorio] He leído y acepto el Aviso de Privacidad Integral de la Academia.',
                    style: TipografiaDoyang.celda(peso: FontWeight.w600),
                  ),
                ),
                CheckboxListTile(
                  value: _consentimientoSalud,
                  onChanged: (v) =>
                      setState(() => _consentimientoSalud = v ?? false),
                  title: Text(
                    '[Opcional — Datos Sensibles] Otorgo consentimiento expreso y separado para tratar tipo de sangre y alergias para emergencias en el tatami.',
                    style: TipografiaDoyang.celda(),
                  ),
                ),
                if (_consentimientoSalud)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _tipoSangreCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de sangre (opcional)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _alergiasCtrl,
                            decoration: const InputDecoration(
                              labelText:
                                  'Alergias o cuidados en tatami (opcional)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                CheckboxListTile(
                  value: _consentimientoFoto,
                  onChanged: (v) =>
                      setState(() => _consentimientoFoto = v ?? false),
                  title: Text(
                    '[Opcional] Autorizo el uso de fotografía exclusivamente para credencial interna del dojang.',
                    style: TipografiaDoyang.celda(),
                  ),
                ),
                CheckboxListTile(
                  value: _consentimientoPromociones,
                  onChanged: (v) =>
                      setState(() => _consentimientoPromociones = v ?? false),
                  title: Text(
                    '[Opcional] Deseo recibir avisos promocionales y descuentos en equipo deportivo.',
                    style: TipografiaDoyang.celda(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      ctrl.registrarFamiliaYAlumno(
                        nombreTutor: _nombreTutorCtrl.text.isEmpty
                            ? 'Tutor Nuevo'
                            : _nombreTutorCtrl.text,
                        telefonoWhatsapp: _telefonoTutorCtrl.text.isEmpty
                            ? '5500001111'
                            : _telefonoTutorCtrl.text,
                        correoTutor: _correoTutorCtrl.text.isEmpty
                            ? 'tutor@familia.mx'
                            : _correoTutorCtrl.text,
                        parentesco: 'Tutor legal',
                        declaracionPatriaPotestad: _patriaPotestad,
                        aceptoAvisoIntegral: _avisoIntegral,
                        consentimientoSaludExpreso: _consentimientoSalud,
                        consentimientoFotoInterna: _consentimientoFoto,
                        consentimientoPromociones: _consentimientoPromociones,
                        nombreAlumno: _nombreAlumnoCtrl.text.isEmpty
                            ? 'Nuevo'
                            : _nombreAlumnoCtrl.text,
                        apellidosAlumno: _apellidosAlumnoCtrl.text.isEmpty
                            ? 'Alumno'
                            : _apellidosAlumnoCtrl.text,
                        fechaNacimientoIso: _fechaNacAlumnoCtrl.text,
                        sexoRama: SexoRama.varonil,
                        gradoActualId: 'grado-10-kup',
                        horarioGrupo: 'Infantil Principiantes 17:00',
                        tipoSangreOpcional: _tipoSangreCtrl.text,
                        alergiasCuidadosOpcional: _alergiasCtrl.text,
                      );
                    },
                    child: const Text('Guardar expediente con consentimientos'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN 2: M4 · GRADOS, ELEGIBILIDAD Y EXÁMENES INTERNOS ─────────────

  Widget _construirSeccionExamenesYGrados(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
  ) {
    final convocatoria = estado.motor.convocatoriasExamen.first;
    final alumnos = estado.motor.alumnosActivos;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TarjetaSeccion(
            titulo:
                'CONVOCATORIA ACTIVA: ${convocatoria.titulo.toUpperCase()} (${convocatoria.fechaIso})',
            accionEncabezado: Text(
              'Sinodal: ${convocatoria.sinodal}',
              style: TipografiaDoyang.etiqueta(
                color: ColoresDoyang.tintaCinturonNegro,
              ),
            ),
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final al in alumnos) ...<Widget>[
                  _FilaCandidatoExamen(
                    alumno: al,
                    convocatoria: convocatoria,
                    estado: estado,
                    ctrl: ctrl,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN 3: M5 · EQUIPO E INVENTARIO DEL DOJANG ───────────────────────

  Widget _construirSeccionEquipoEInventario(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
  ) {
    final hijoSeleccionado =
        estado.hijoActual ?? estado.motor.alumnosActivos.first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TarjetaSeccion(
            titulo:
                'CATÁLOGO E INVENTARIO DEL DOJANG (${estado.motor.productosEquipo.length})',
            accionEncabezado: Text(
              'Alumno activo para pedido: ${hijoSeleccionado.nombreCompleto}',
              style: TipografiaDoyang.etiqueta(
                color: ColoresDoyang.tintaCinturonNegro,
              ),
            ),
            hijo: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final prod in estado.motor.productosEquipo)
                  Container(
                    width: 280,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.papelDobok,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          prod.nombre,
                          style: TipografiaDoyang.cuerpo(
                            peso: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Talla: ${prod.talla} · Stock: ${prod.existencias} disponibles',
                          style: TipografiaDoyang.metadato(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatearMxn(prod.precioCentavos),
                          style: TipografiaDoyang.tituloSeccion(
                            color: ColoresDoyang.azulChung,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          key: Key('btn-pedir-recepcion-${prod.id}'),
                          onPressed: prod.existencias <= 0
                              ? null
                              : () => ctrl.solicitarEquipo(
                                    alumnoId: hijoSeleccionado.id,
                                    productoId: prod.id,
                                  ),
                          child: const Text('Vender / Apartar'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TarjetaSeccion(
            titulo:
                'PEDIDOS DE EQUIPO Y CONTROL DE ENTREGA (${estado.motor.pedidosEquipo.length})',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (estado.motor.pedidosEquipo.isEmpty)
                  Text(
                    'Aún no hay pedidos de equipo registrados.',
                    style: TipografiaDoyang.celda(),
                  )
                else
                  for (final ped in estado.motor.pedidosEquipo)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColoresDoyang.papelDobok,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(color: ColoresDoyang.bordePiedra),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${ped.nombreProductoSnapshot} (${ped.tallaSnapshot}) · ${formatearMxn(ped.totalCentavos)}',
                                style: TipografiaDoyang.cuerpo(
                                  peso: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Estado: ${_etiquetaEstadoEquipo(ped.estadoEntrega)}',
                                style: TipografiaDoyang.metadato(
                                  color: ped.estadoEntrega ==
                                          EstadoEntregaEquipo.entregado
                                      ? ColoresDoyang.jadeAprobado
                                      : ColoresDoyang.ambarTatami,
                                  peso: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (ped.estadoEntrega !=
                              EstadoEntregaEquipo.entregado)
                            FilledButton(
                              key: Key('btn-entregar-pedido-${ped.id}'),
                              onPressed: () =>
                                  ctrl.entregarEquipoEnMostrador(ped.id),
                              child: const Text('Entregar equipo en mostrador'),
                            ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN 4: M6 · TORNEOS E INTEROPERABILIDAD CUPA (D-12) ──────────────

  Widget _construirSeccionTorneosYCupa(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
  ) {
    final torneo = estado.motor.torneos.first;
    final inscritos = estado.motor.inscripcionesTorneo
        .where((i) => i.torneoId == torneo.id)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TarjetaSeccion(
            titulo:
                '${torneo.nombre.toUpperCase()} · ${torneo.sede} (${torneo.fechaEventoIso})',
            accionEncabezado: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () => ctrl.exportarTorneoCupaJson(torneo.id),
                  child: const Text('Exportar inscritos JSON CUPA'),
                ),
                OutlinedButton(
                  onPressed: () => ctrl.exportarTorneoCupaCsv(torneo.id),
                  child: const Text('Exportar inscritos CSV CUPA'),
                ),
              ],
            ),
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Cuota de inscripción: ${formatearMxn(torneo.cuotaCentavos)} · Fecha límite: ${torneo.fechaLimiteInscripcionIso}',
                  style: TipografiaDoyang.celda(peso: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final al in estado.motor.alumnosActivos)
                      OutlinedButton(
                        onPressed: () => ctrl.inscribirATorneo(
                          torneoId: torneo.id,
                          alumnoId: al.id,
                          modalidad: ModalidadTorneo.ambas,
                          pesoKg: al.pesoKgOpcional ?? 35.0,
                          categoriaDivision: 'División Oficial WT',
                          responsivaTutorAceptada: true,
                        ),
                        child: Text(
                          '+ Inscribir a ${al.nombre} (con responsiva)',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final insc in inscritos)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.papelDobok,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: <Widget>[
                        Text(
                          '${estado.motor.obtenerAlumnoPorId(insc.alumnoId).nombreCompleto} · ${insc.pesoKgRegistrado} kg · Modalidad: ${insc.modalidad.name.toUpperCase()} · Medalla: ${insc.medalla.name.toUpperCase()}',
                          style: TipografiaDoyang.cuerpo(peso: FontWeight.w600),
                        ),
                        Wrap(
                          spacing: 6,
                          children: <Widget>[
                            for (final med in <MedallaTorneo>[
                              MedallaTorneo.oro,
                              MedallaTorneo.plata,
                              MedallaTorneo.bronce,
                            ])
                              OutlinedButton(
                                onPressed: () => ctrl.registrarMedalla(
                                  inscripcionTorneoId: insc.id,
                                  medalla: med,
                                ),
                                child: Text(med.name.toUpperCase()),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (estado.textoExportadoReciente != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColoresDoyang.papelDobok,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      border: Border.all(color: ColoresDoyang.bordePiedra),
                    ),
                    child: SelectableText(
                      estado.textoExportadoReciente!,
                      style: TipografiaDoyang.ticketMonoespaciado(
                        compacto: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN 5: M1 · PERSONALIZACIÓN DEL DOJANG ───────────────────────────

  Widget _construirSeccionPersonalizacionDojang(
    EstadoAppDoyang estado,
    ControladorDoyang ctrl,
  ) {
    final acad = estado.motor.academia;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TarjetaSeccion(
            titulo:
                'M1 · IDENTIDAD VISUAL, REGLAS FINANCIERAS Y CONTRASTE WCAG AA',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _nombreAcadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre comercial del Dojang',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 280,
                      child: TextField(
                        controller: _lemaAcadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Lema institucional',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _colorAcadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Color primario Hex (#RRGGBB)',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _mensualidadAcadCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mensualidad base (MXN)',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _desc2HermanoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Desc. 2.º hermano (%)',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _desc3HermanoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Desc. 3.er hermano (%)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Color configurado: ${acad.colorPrimarioHex} → Color ajustado WCAG AA (>= 4.5:1): ${acad.colorPrimarioSobreTextoClaroHex}',
                  style: TipografiaDoyang.celda(peso: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () {
                      final pesos =
                          int.tryParse(_mensualidadAcadCtrl.text.trim()) ?? 800;
                      final d2 =
                          int.tryParse(_desc2HermanoCtrl.text.trim()) ?? 10;
                      final d3 =
                          int.tryParse(_desc3HermanoCtrl.text.trim()) ?? 20;
                      ctrl.actualizarConfiguracionAcademia(
                        acad.copyWith(
                          nombre: _nombreAcadCtrl.text.trim(),
                          lema: _lemaAcadCtrl.text.trim(),
                          colorPrimarioHex: _colorAcadCtrl.text.trim(),
                          mensualidadBaseCentavos: pesos * 100,
                          descuentoSegundoHermanoPct: d2,
                          descuentoTercerHermanoPct: d3,
                        ),
                      );
                    },
                    child: const Text('Guardar personalización del Dojang'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TarjetaSeccion(
            titulo:
                'ESCALAFÓN DE CINTAS Y PUNTAS (${estado.motor.grados.length} GRADOS)',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final g in estado.motor.grados) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: BeltWidget(grado: g, compacto: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Text(
                          'Orden ${g.orden} · Mín: ${g.asistenciasMinimas} clases / ${g.mesesMinimos} meses · Examen: ${formatearMxn(g.costoExamenCentavos)}',
                          style: TipografiaDoyang.celda(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaCandidatoExamen extends StatelessWidget {
  final Alumno alumno;
  final ConvocatoriaExamen convocatoria;
  final EstadoAppDoyang estado;
  final ControladorDoyang ctrl;

  const _FilaCandidatoExamen({
    required this.alumno,
    required this.convocatoria,
    required this.estado,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final dictamen = estado.motor.evaluarElegibilidadExamen(alumno.id);
    final inscExistente = estado.motor.inscripcionesExamen
        .where(
          (i) =>
              i.convocatoriaId == convocatoria.id && i.alumnoId == alumno.id,
        )
        .toList();
    final inscripcion =
        inscExistente.isNotEmpty ? inscExistente.first : null;
    final cargoExamen = inscripcion == null
        ? null
        : estado.motor.cargos
            .where((c) => c.id == inscripcion.cargoId)
            .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresDoyang.papelDobok,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(color: ColoresDoyang.bordePiedra),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${alumno.nombreCompleto} → Aspira a: ${dictamen.siguienteGrado?.codigo ?? "Grado Máximo"} (${dictamen.siguienteGrado?.nombre ?? "-"})',
                    style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
                  ),
                  Text(
                    dictamen.elegible
                        ? 'Dictamen: ELEGIBLE (${dictamen.asistenciasActuales}/${dictamen.asistenciasRequeridas} asistencias · ${dictamen.mesesTranscurridos}/${dictamen.mesesRequeridos} meses · Pagos al día)'
                        : 'Dictamen: NO ELEGIBLE · ${dictamen.motivos.join(" | ")}',
                    style: TipografiaDoyang.metadato(
                      color: dictamen.elegible
                          ? ColoresDoyang.jadeAprobado
                          : ColoresDoyang.selloHong,
                      peso: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  if (inscripcion == null && dictamen.elegible)
                    FilledButton(
                      key: Key('btn-inscribir-examen-${alumno.id}'),
                      onPressed: () => ctrl.inscribirAExamen(
                        convocatoriaId: convocatoria.id,
                        alumnoId: alumno.id,
                      ),
                      child: const Text('Inscribir a examen'),
                    ),
                  if (inscripcion != null &&
                      cargoExamen != null &&
                      !cargoExamen.estaLiquidado)
                    OutlinedButton(
                      key: Key('btn-pagar-examen-${alumno.id}'),
                      onPressed: () => ctrl.cobrarCargos(
                        tutorId: alumno.tutorId,
                        abonosPorCargoId: <String, int>{
                          cargoExamen.id: cargoExamen.saldoCentavos,
                        },
                        metodoPago: MetodoPago.efectivo,
                      ),
                      child: Text(
                        'Cobrar examen (${formatearMxn(cargoExamen.saldoCentavos)})',
                      ),
                    ),
                  if (inscripcion != null &&
                      cargoExamen != null &&
                      cargoExamen.estaLiquidado &&
                      inscripcion.evaluacionOpcional == null)
                    FilledButton(
                      key: Key('btn-aprobar-examen-${alumno.id}'),
                      onPressed: () => ctrl.evaluarAlumnoEnExamen(
                        inscripcionExamenId: inscripcion.id,
                        poomsae: 92,
                        kyorugi: 90,
                        rompimiento: 95,
                        teoria: 90,
                        aprobado: true,
                        observaciones: 'Aprobado en examen oficial de dojang.',
                      ),
                      child: const Text('Aprobar y promover cinta'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          BeltWidget(grado: dictamen.gradoActual, compacto: true),
        ],
      ),
    );
  }
}

class _BarraNavegacionHorizontalMovil extends StatelessWidget {
  final int indiceActivo;
  final ValueChanged<int> alSeleccionar;

  const _BarraNavegacionHorizontalMovil({
    required this.indiceActivo,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColoresDoyang.tintaCinturonNegro,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (var i = 0; i < _BarraNavegacionLateral._destinos.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  key: Key('nav-recepcion-$i'),
                  onTap: () => alSeleccionar(i),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: DimensionesDoyang.objetivoTactilMinimo,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: i == indiceActivo
                          ? ColoresDoyang.azulChung
                          : ColoresDoyang.transparente,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Center(
                      child: Text(
                        _BarraNavegacionLateral._destinos[i].$2,
                        style: TipografiaDoyang.metadato(
                          color: ColoresDoyang.papelDobok,
                          peso: i == indiceActivo
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarraNavegacionLateral extends StatelessWidget {
  final bool compacto;
  final int indiceActivo;
  final int pendientesOutbox;
  final ValueChanged<int> alSeleccionar;
  final VoidCallback alSincronizar;

  const _BarraNavegacionLateral({
    required this.compacto,
    required this.indiceActivo,
    required this.pendientesOutbox,
    required this.alSeleccionar,
    required this.alSincronizar,
  });

  static const _destinos = <(String, String, IconData)>[
    ('[F2] Caja', 'Caja', Icons.point_of_sale),
    ('Alumnos / ARCO', 'Alumnos', Icons.groups),
    ('Exámenes / Cintas', 'Grados', Icons.military_tech),
    ('Equipo / Stock', 'Equipo', Icons.checkroom),
    ('Torneos / CUPA', 'Torneos', Icons.emoji_events),
    ('Ajustes Dojang', 'Ajustes', Icons.tune),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compacto
          ? DimensionesDoyang.anchoRailCompacto
          : DimensionesDoyang.anchoSidebarExpandido,
      color: ColoresDoyang.tintaCinturonNegro,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _destinos.length,
              itemBuilder: (context, i) {
                final activo = i == indiceActivo;
                final destino = _destinos[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    key: Key('nav-recepcion-$i'),
                    onTap: () => alSeleccionar(i),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: DimensionesDoyang.objetivoTactilMinimo,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: activo
                            ? ColoresDoyang.azulChung
                            : ColoresDoyang.transparente,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: compacto
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  destino.$3,
                                  color: ColoresDoyang.papelDobok,
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  destino.$2,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TipografiaDoyang.metadato(
                                    color: ColoresDoyang.papelDobok,
                                    peso: activo
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: <Widget>[
                                Icon(
                                  destino.$3,
                                  color: ColoresDoyang.papelDobok,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    destino.$1,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TipografiaDoyang.celda(
                                      color: ColoresDoyang.papelDobok,
                                      peso: activo
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          InkWell(
            onTap: alSincronizar,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pendientesOutbox > 0
                    ? ColoresDoyang.ambarTatami
                    : ColoresDoyang.jadeAprobado,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
              child: Text(
                compacto
                    ? 'Cola: $pendientesOutbox'
                    : 'Cola Outbox: $pendientesOutbox pendientes',
                textAlign: TextAlign.center,
                style: TipografiaDoyang.metadato(
                  color: ColoresDoyang.papelDobok,
                  peso: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  final String titulo;
  final Widget? accionEncabezado;
  final Widget hijo;

  const _TarjetaSeccion({
    required this.titulo,
    this.accionEncabezado,
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
      padding: const EdgeInsets.all(14),
      child: Material(
        color: ColoresDoyang.transparente,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                Text(
                  titulo,
                  style: TipografiaDoyang.tituloSeccion(),
                ),
                ?accionEncabezado,
              ],
            ),
            const Divider(height: 18),
            hijo,
          ],
        ),
      ),
    );
  }
}

class _IndicadorResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool destacado;

  const _IndicadorResumen({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(etiqueta, style: TipografiaDoyang.metadato()),
        Text(
          valor,
          style: destacado
              ? TipografiaDoyang.tituloSeccion(
                  color: ColoresDoyang.jadeAprobado,
                )
              : TipografiaDoyang.cuerpo(peso: FontWeight.w700),
        ),
      ],
    );
  }
}

String _etiquetaEstadoEquipo(EstadoEntregaEquipo estado) {
  switch (estado) {
    case EstadoEntregaEquipo.pendientePago:
      return 'Pago pendiente · Pendiente de entregar';
    case EstadoEntregaEquipo.pagadoPendienteEntrega:
      return 'Pagado · Listo para recoger en mostrador';
    case EstadoEntregaEquipo.entregado:
      return 'Pagado y Entregado';
    case EstadoEntregaEquipo.cancelado:
      return 'Cancelado';
  }
}
