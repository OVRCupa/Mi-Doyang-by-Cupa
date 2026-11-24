import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../estado/controlador_doyang.dart';
import '../theme/belt_widget.dart';
import '../theme/logo_mi_doyang.dart';
import '../theme/tema_doyang.dart';

/// Dashboard ejecutivo de Inicio de **Mi Doyang by Cupa**.
///
/// Diseño institucional:
/// - **Encabezado:** Logo corporativo `MI DOYANG / BY CUPA` en la esquina
///   superior izquierda y el nombre de la academia centrado en el encabezado.
/// - **Módulos principales compactos:** 3 tarjetas compactas de acceso rápido
///   (*Recepción y Caja*, *Portal de Padres*, *Instructor en Tatami*).
/// - **Información operativa crítica a la mano:** KPIs en tiempo real, padrón
///   de alumnos en la academia con su cinta Kup/Poom/Dan, historial de ingresos,
///   sección interactiva de gastos operativos y eventos próximos (exámenes y
///   torneos).
class PantallaInicioDoyang extends ConsumerStatefulWidget {
  const PantallaInicioDoyang({super.key});

  @override
  ConsumerState<PantallaInicioDoyang> createState() =>
      _PantallaInicioDoyangState();
}

class _PantallaInicioDoyangState extends ConsumerState<PantallaInicioDoyang> {
  bool _mostrarFormularioGasto = false;
  final TextEditingController _conceptoGastoCtrl = TextEditingController();
  final TextEditingController _montoGastoCtrl = TextEditingController();
  CategoriaGasto _categoriaGasto = CategoriaGasto.equipoYMaterial;
  MetodoPago _metodoGasto = MetodoPago.efectivo;

  @override
  void dispose() {
    _conceptoGastoCtrl.dispose();
    _montoGastoCtrl.dispose();
    super.dispose();
  }

  void _guardarNuevoGasto(ControladorDoyang ctrl) {
    final textoMonto =
        _montoGastoCtrl.text.trim().replaceAll(',', '').replaceAll('\$', '');
    final montoPesos = double.tryParse(textoMonto);
    if (montoPesos == null || montoPesos <= 0) {
      ctrl.registrarNuevoGasto(
        concepto: _conceptoGastoCtrl.text,
        categoria: _categoriaGasto,
        montoCentavos: 0,
        metodoPago: _metodoGasto,
      );
      return;
    }
    final ok = ctrl.registrarNuevoGasto(
      concepto: _conceptoGastoCtrl.text,
      categoria: _categoriaGasto,
      montoCentavos: (montoPesos * 100).round(),
      metodoPago: _metodoGasto,
    );
    if (ok) {
      setState(() {
        _conceptoGastoCtrl.clear();
        _montoGastoCtrl.clear();
        _mostrarFormularioGasto = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(controladorDoyangProvider);
    final ctrl = ref.read(controladorDoyangProvider.notifier);
    final motor = estado.motor;
    final academia = motor.academia;
    final primario =
        ColoresDoyang.primarioAcademiaAccesible(academia.colorPrimarioHex);

    final alumnosActivos = motor.alumnosActivos;
    final dictamenesPorAlumno = <String, DictamenElegibilidad>{
      for (final al in alumnosActivos)
        al.id: motor.evaluarElegibilidadExamen(al.id),
    };
    final alumnosConAdeudo = dictamenesPorAlumno.values
        .where((d) => d.adeudoCentavos > 0)
        .length;
    final alumnosAlCorriente = alumnosActivos.length - alumnosConAdeudo;
    final alumnosElegiblesExamen =
        dictamenesPorAlumno.values.where((d) => d.elegible).length;

    final corte = motor.calcularCorteCaja();
    final porCobrarCentavos = motor.saldoPorCobrarTotalCentavos;
    final gastosVigentes =
        motor.gastos.where((g) => !g.cancelado).toList().reversed.toList();
    final totalGastosCentavos = motor.totalGastosVigentesCentavos;
    final balanceNetoCentavos = motor.balanceNetoCentavos;
    final pendientesOutbox =
        motor.colaOutbox.where((e) => !e.sincronizado).length;
    final cargosPendientesCount = motor.cargos
        .where(
          (c) =>
              (c.estado == EstadoCargo.pendiente ||
                  c.estado == EstadoCargo.abonadoParcial) &&
              c.saldoCentavos > 0,
        )
        .length;

    return Scaffold(
      backgroundColor: ColoresDoyang.papelDobok,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Encabezado institucional: Logo izq. + Academia centrada ──
            _EncabezadoDashboardDoyang(
              nombreAcademia: academia.nombre,
              lemaAcademia: academia.lema,
              colorPrimarioHex: academia.colorPrimarioHex,
              pendientesOutbox: pendientesOutbox,
              alAbrirAjustes: () => ctrl.abrirRecepcionSeccion(5),
            ),

            // ── Avisos de retroalimentación inmediata ────────────────────
            if (estado.avisoExito != null || estado.avisoError != null)
              Container(
                color: estado.avisoError != null
                    ? ColoresDoyang.fondoHongSuave
                    : ColoresDoyang.fondoJadeSuave,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
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

            // ── Cuerpo desplazable del Dashboard ─────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  // 1. Módulos principales compactos (3 accesos rápidos)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Módulos principales',
                          style: TipografiaDoyang.etiqueta(
                            color: ColoresDoyang.tintaCinturonNegro,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, c) {
                      final modulos = <Widget>[
                        _ModuloCompactoAcceso(
                          llave: const Key('inicio-entrar-recepcion'),
                          icono: Icons.point_of_sale_rounded,
                          colorAcento: primario,
                          titulo: 'Recepción y Caja',
                          subtitulo:
                              '$cargosPendientesCount cargo(s) por cobrar · Alumnos y corte',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.dueno);
                            ctrl.salirDeInicio();
                          },
                        ),
                        _ModuloCompactoAcceso(
                          llave: const Key('inicio-entrar-padres'),
                          icono: Icons.family_restroom_rounded,
                          colorAcento: ColoresDoyang.jadeAprobado,
                          titulo: 'Portal de Padres',
                          subtitulo:
                              '${motor.tutores.length} familias · Cintas Kup y tickets QR',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.tutor);
                            ctrl.salirDeInicio();
                          },
                        ),
                        _ModuloCompactoAcceso(
                          llave: const Key('inicio-entrar-instructor'),
                          icono: Icons.sports_martial_arts_rounded,
                          colorAcento: ColoresDoyang.selloHong,
                          titulo: 'Instructor en Tatami',
                          subtitulo:
                              '${alumnosActivos.length} activos · Pase QR y alertas médicas',
                          alTocar: () {
                            ctrl.cambiarRolActivo(RolUsuario.instructor);
                            ctrl.salirDeInicio();
                          },
                        ),
                      ];
                      if (c.maxWidth >= 900) {
                        return Row(
                          children: <Widget>[
                            Expanded(child: modulos[0]),
                            const SizedBox(width: 10),
                            Expanded(child: modulos[1]),
                            const SizedBox(width: 10),
                            Expanded(child: modulos[2]),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          modulos[0],
                          const SizedBox(height: 8),
                          modulos[1],
                          const SizedBox(height: 8),
                          modulos[2],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. Indicadores ejecutivos clave (KPIs de la academia)
                  LayoutBuilder(
                    builder: (context, c) {
                      final kpis = <Widget>[
                        _TarjetaKpiDashboard(
                          etiqueta: 'ALUMNOS EN ACADEMIA',
                          valorPrincipal: '${alumnosActivos.length} activos',
                          detalle:
                              '$alumnosAlCorriente al día · $alumnosConAdeudo con adeudo · $alumnosElegiblesExamen listos examen',
                          colorIndicador: primario,
                        ),
                        _TarjetaKpiDashboard(
                          etiqueta: 'INGRESOS COBRADOS',
                          valorPrincipal:
                              formatearMxn(corte.totalCobradoCentavos),
                          detalle:
                              'Por cobrar: ${formatearMxn(porCobrarCentavos)} (${corte.ticketsVigentesCount} ticket(s))',
                          colorIndicador: ColoresDoyang.jadeAprobado,
                        ),
                        _TarjetaKpiDashboard(
                          etiqueta: 'GASTOS OPERATIVOS',
                          valorPrincipal: formatearMxn(totalGastosCentavos),
                          detalle:
                              '${gastosVigentes.length} egreso(s) registrados en dojang',
                          colorIndicador: ColoresDoyang.selloHong,
                        ),
                        _TarjetaKpiDashboard(
                          etiqueta: 'BALANCE NETO EN CAJA',
                          valorPrincipal: formatearMxn(balanceNetoCentavos),
                          detalle: balanceNetoCentavos >= 0
                              ? 'Flujo operativo positivo (Ingresos − Gastos)'
                              : 'Egresos superan cobros actuales',
                          colorIndicador: balanceNetoCentavos >= 0
                              ? ColoresDoyang.jadeAprobado
                              : ColoresDoyang.selloHong,
                        ),
                      ];

                      if (c.maxWidth >= 980) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: kpis[0]),
                            const SizedBox(width: 10),
                            Expanded(child: kpis[1]),
                            const SizedBox(width: 10),
                            Expanded(child: kpis[2]),
                            const SizedBox(width: 10),
                            Expanded(child: kpis[3]),
                          ],
                        );
                      }
                      if (c.maxWidth >= 600) {
                        return Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(child: kpis[0]),
                                const SizedBox(width: 10),
                                Expanded(child: kpis[1]),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(child: kpis[2]),
                                const SizedBox(width: 10),
                                Expanded(child: kpis[3]),
                              ],
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          kpis[0],
                          const SizedBox(height: 8),
                          kpis[1],
                          const SizedBox(height: 8),
                          kpis[2],
                          const SizedBox(height: 8),
                          kpis[3],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 3. Cuadrícula principal del Dashboard (4 secciones clave)
                  LayoutBuilder(
                    builder: (context, c) {
                      final panelAlumnos = _construirPanelAlumnos(
                        alumnosActivos: alumnosActivos,
                        dictamenes: dictamenesPorAlumno,
                        ctrl: ctrl,
                      );
                      final panelIngresos = _construirPanelIngresos(
                        corte: corte,
                        porCobrarCentavos: porCobrarCentavos,
                        tickets: motor.tickets.reversed.toList(),
                        ctrl: ctrl,
                      );
                      final panelGastos = _construirPanelGastos(
                        gastosVigentes: gastosVigentes,
                        totalGastosCentavos: totalGastosCentavos,
                        ctrl: ctrl,
                      );
                      final panelEventos = _construirPanelEventosProximos(
                        motor: motor,
                        alumnosElegiblesCount: alumnosElegiblesExamen,
                        ctrl: ctrl,
                      );

                      if (c.maxWidth >= 980) {
                        return Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(flex: 11, child: panelAlumnos),
                                const SizedBox(width: 14),
                                Expanded(flex: 9, child: panelIngresos),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(flex: 11, child: panelGastos),
                                const SizedBox(width: 14),
                                Expanded(flex: 9, child: panelEventos),
                              ],
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          panelAlumnos,
                          const SizedBox(height: 12),
                          panelIngresos,
                          const SizedBox(height: 12),
                          panelGastos,
                          const SizedBox(height: 12),
                          panelEventos,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Barra compacta de personalización de color institucional
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
                        const SizedBox(height: 8),
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

  Widget _construirPanelAlumnos({
    required List<Alumno> alumnosActivos,
    required Map<String, DictamenElegibilidad> dictamenes,
    required ControladorDoyang ctrl,
  }) {
    return Container(
      key: const Key('panel-dashboard-alumnos'),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Alumnos en la academia',
                    style: TipografiaDoyang.tituloSeccion(),
                  ),
                  Text(
                    'Cinta actual Kup/Poom/Dan, asistencias y estado de mensualidad',
                    style: TipografiaDoyang.metadato(),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => ctrl.abrirRecepcionSeccion(1),
                child: const Text('Ver padrón'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (alumnosActivos.isEmpty)
            Text(
              'Aún no hay alumnos activos registrados.',
              style: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
            )
          else
            for (var i = 0; i < alumnosActivos.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: 18),
              _FilaAlumnoDashboard(
                alumno: alumnosActivos[i],
                dictamen: dictamenes[alumnosActivos[i].id]!,
              ),
            ],
        ],
      ),
    );
  }

  Widget _construirPanelIngresos({
    required ResumenCorteCaja corte,
    required int porCobrarCentavos,
    required List<TicketPago> tickets,
    required ControladorDoyang ctrl,
  }) {
    return Container(
      key: const Key('panel-dashboard-ingresos'),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Historial de ingresos',
                    style: TipografiaDoyang.tituloSeccion(),
                  ),
                  Text(
                    'Cobros con ticket verificable y desglose de caja',
                    style: TipografiaDoyang.metadato(),
                  ),
                ],
              ),
              FilledButton(
                onPressed: () => ctrl.abrirRecepcionSeccion(0),
                child: const Text('Ir a Caja'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              _EtiquetaMontoResumen(
                etiqueta: 'Efectivo',
                valor: formatearMxn(corte.totalEfectivoCentavos),
                fondo: ColoresDoyang.fondoJadeSuave,
                colorTexto: ColoresDoyang.jadeAprobado,
              ),
              _EtiquetaMontoResumen(
                etiqueta: 'Transferencia',
                valor: formatearMxn(corte.totalTransferenciaCentavos),
                fondo: ColoresDoyang.fondoAzulSuave,
                colorTexto: ColoresDoyang.azulChung,
              ),
              _EtiquetaMontoResumen(
                etiqueta: 'Por cobrar',
                valor: formatearMxn(porCobrarCentavos),
                fondo: ColoresDoyang.fondoAmbarSuave,
                colorTexto: ColoresDoyang.ambarTatami,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tickets.isEmpty)
            Text(
              'Sin tickets emitidos todavía.',
              style: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
            )
          else
            for (var i = 0; i < tickets.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: 14),
              InkWell(
                onTap: () => ctrl.abrirRecepcionSeccion(
                  0,
                  ticketId: tickets[i].id,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              tickets[i].folio,
                              style: TipografiaDoyang.ticketMonoespaciado(
                                peso: FontWeight.w700,
                                compacto: true,
                              ),
                            ),
                            Text(
                              tickets[i].lineas.isNotEmpty
                                  ? tickets[i].lineas.first.concepto
                                  : 'Cobro en recepción',
                              style: TipografiaDoyang.celda(),
                            ),
                            Text(
                              '${tickets[i].metodoPago.name.toUpperCase()} · ${tickets[i].emitidoEnIso.substring(0, 10)}',
                              style: TipografiaDoyang.metadato(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tickets[i].cancelado
                            ? 'CANCELADO'
                            : '+${formatearMxn(tickets[i].totalPagadoCentavos)}',
                        style: TipografiaDoyang.celda(
                          color: tickets[i].cancelado
                              ? ColoresDoyang.selloHong
                              : ColoresDoyang.jadeAprobado,
                          peso: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _construirPanelGastos({
    required List<GastoAcademia> gastosVigentes,
    required int totalGastosCentavos,
    required ControladorDoyang ctrl,
  }) {
    return Container(
      key: const Key('panel-dashboard-gastos'),
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sección de gastos',
                    style: TipografiaDoyang.tituloSeccion(),
                  ),
                  Text(
                    'Renta, instructores, servicios, cintas y mantenimiento',
                    style: TipografiaDoyang.metadato(),
                  ),
                ],
              ),
              OutlinedButton(
                key: const Key('btn-toggle-nuevo-gasto'),
                onPressed: () {
                  setState(() {
                    _mostrarFormularioGasto = !_mostrarFormularioGasto;
                  });
                },
                child: Text(
                  _mostrarFormularioGasto ? 'Cerrar captura' : '+ Registrar gasto',
                ),
              ),
            ],
          ),
          if (_mostrarFormularioGasto) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColoresDoyang.papelDobok,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: ColoresDoyang.bordePiedra),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    key: const Key('input-gasto-concepto'),
                    controller: _conceptoGastoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Concepto del gasto (ej. Renta, luz, cintas)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('input-gasto-monto'),
                    controller: _montoGastoCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto en MXN (ej. 450.00)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CategoriaGasto>(
                    initialValue: _categoriaGasto,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoría operativa',
                    ),
                    items: <DropdownMenuItem<CategoriaGasto>>[
                      for (final cat in CategoriaGasto.values)
                        DropdownMenuItem<CategoriaGasto>(
                          value: cat,
                          child: Text(
                            cat.etiqueta,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() => _categoriaGasto = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: <Widget>[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          for (final m in MetodoPago.values)
                            ChoiceChip(
                              label: Text(m.name.toUpperCase()),
                              selected: _metodoGasto == m,
                              onSelected: (_) =>
                                  setState(() => _metodoGasto = m),
                            ),
                        ],
                      ),
                      FilledButton(
                        key: const Key('btn-guardar-gasto'),
                        onPressed: () => _guardarNuevoGasto(ctrl),
                        child: const Text('Guardar gasto'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _EtiquetaMontoResumen(
            etiqueta: 'Total egresos acumulados',
            valor: '-${formatearMxn(totalGastosCentavos)}',
            fondo: ColoresDoyang.fondoHongSuave,
            colorTexto: ColoresDoyang.selloHong,
          ),
          const SizedBox(height: 10),
          if (gastosVigentes.isEmpty)
            Text(
              'No hay gastos registrados en este periodo.',
              style: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
            )
          else
            for (var i = 0; i < gastosVigentes.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          gastosVigentes[i].concepto,
                          style: TipografiaDoyang.celda(peso: FontWeight.w600),
                        ),
                        Text(
                          '${gastosVigentes[i].categoria.etiqueta} · ${gastosVigentes[i].metodoPago.name.toUpperCase()} · ${gastosVigentes[i].fechaIso}',
                          style: TipografiaDoyang.metadato(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '-${formatearMxn(gastosVigentes[i].montoCentavos)}',
                    style: TipografiaDoyang.celda(
                      color: ColoresDoyang.selloHong,
                      peso: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  Widget _construirPanelEventosProximos({
    required MotorDoyang motor,
    required int alumnosElegiblesCount,
    required ControladorDoyang ctrl,
  }) {
    final convocatoriasAbiertas =
        motor.convocatoriasExamen.where((c) => !c.cerrada).toList();
    final torneosAbiertos = motor.torneos.where((t) => t.abierto).toList();

    return Container(
      key: const Key('panel-dashboard-eventos'),
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
          Text(
            'Eventos próximos',
            style: TipografiaDoyang.tituloSeccion(),
          ),
          Text(
            'Exámenes de cintas Kup/Poom/Dan y torneos oficiales',
            style: TipografiaDoyang.metadato(),
          ),
          const SizedBox(height: 12),
          for (final conv in convocatoriasAbiertas) ...<Widget>[
            _TarjetaEventoDashboard(
              etiquetaTipo: 'EXAMEN DE GRADO',
              colorEtiqueta: ColoresDoyang.azulChung,
              fondoEtiqueta: ColoresDoyang.fondoAzulSuave,
              titulo: conv.titulo,
              fechaTexto: 'Fecha: ${conv.fechaIso}',
              subtitulo:
                  'Sinodal: ${conv.sinodal} · $alumnosElegiblesCount elegible(s) y ${motor.inscripcionesExamen.where((e) => e.convocatoriaId == conv.id).length} inscrito(s)',
              etiquetaAccion: 'Gestionar examen',
              alTocarAccion: () => ctrl.abrirRecepcionSeccion(2),
            ),
            const SizedBox(height: 10),
          ],
          for (final torneo in torneosAbiertos) ...<Widget>[
            _TarjetaEventoDashboard(
              etiquetaTipo: 'TORNEO TKD',
              colorEtiqueta: ColoresDoyang.selloHong,
              fondoEtiqueta: ColoresDoyang.fondoHongSuave,
              titulo: torneo.nombre,
              fechaTexto:
                  'Evento: ${torneo.fechaEventoIso} · Cierre: ${torneo.fechaLimiteInscripcionIso}',
              subtitulo:
                  '${torneo.sede} · Cuota ${formatearMxn(torneo.cuotaCentavos)} · ${motor.inscripcionesTorneo.where((t) => t.torneoId == torneo.id).length} inscrito(s)',
              etiquetaAccion: 'Gestionar torneo',
              alTocarAccion: () => ctrl.abrirRecepcionSeccion(4),
            ),
            const SizedBox(height: 10),
          ],
          if (convocatoriasAbiertas.isEmpty && torneosAbiertos.isEmpty)
            Text(
              'No hay exámenes ni torneos próximos programados.',
              style: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
            ),
        ],
      ),
    );
  }
}

/// Encabezado institucional con imagen de academia de Taekwondo, logo corporativo
/// en la esquina superior izquierda y nombre de la academia centrado.
class _EncabezadoDashboardDoyang extends StatelessWidget {
  final String nombreAcademia;
  final String lemaAcademia;
  final String colorPrimarioHex;
  final int pendientesOutbox;
  final VoidCallback alAbrirAjustes;

  const _EncabezadoDashboardDoyang({
    required this.nombreAcademia,
    required this.lemaAcademia,
    required this.colorPrimarioHex,
    required this.pendientesOutbox,
    required this.alAbrirAjustes,
  });

  @override
  Widget build(BuildContext context) {
    final primario = ColoresDoyang.primarioAcademiaAccesible(colorPrimarioHex);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            'assets/imagenes/fondo_academia_tkd.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              decoration: BoxDecoration(
                gradient: ColoresDoyang.gradienteEncabezado(colorPrimarioHex),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  ColoresDoyang.tintaCinturonNegro.withValues(alpha: 0.84),
                  primario.withValues(alpha: 0.68),
                  ColoresDoyang.tintaCinturonNegro.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bloqueAcademiaCentrado = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    nombreAcademia,
                    textAlign: TextAlign.center,
                    style: TipografiaDoyang.encabezadoPantalla(
                      color: ColoresDoyang.superficieTatami,
                    ),
                  ),
                  if (lemaAcademia.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      lemaAcademia,
                      textAlign: TextAlign.center,
                      style: TipografiaDoyang.metadato(
                        color: ColoresDoyang.papelDobok,
                      ),
                    ),
                  ],
                ],
              );

              final badgeDerecha = InkWell(
                onTap: alAbrirAjustes,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 38),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ColoresDoyang.tintaCinturonNegro
                        .withValues(alpha: 0.55),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      color: ColoresDoyang.superficieTatami
                          .withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: ColoresDoyang.papelDobok,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          pendientesOutbox == 0
                              ? 'En línea · Ajustes'
                              : 'Local ($pendientesOutbox) · Ajustes',
                          overflow: TextOverflow.ellipsis,
                          style: TipografiaDoyang.metadato(
                            color: ColoresDoyang.papelDobok,
                            peso: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (constraints.maxWidth >= 820) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: LogoMiDoyang(
                          compacto: false,
                          sobreOscuro: true,
                          altoPersonalizado: 46,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: bloqueAcademiaCentrado,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: badgeDerecha,
                      ),
                    ),
                  ],
                );
              }

              // Diseño responsivo para pantallas estrechas (360 dp @ 130%):
              // Logo arriba a la izquierda y nombre de la academia centrado debajo.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: <Widget>[
                      const LogoMiDoyang(
                        compacto: true,
                        sobreOscuro: true,
                      ),
                      badgeDerecha,
                    ],
                  ),
                  const SizedBox(height: 10),
                  bloqueAcademiaCentrado,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Módulo principal compacto para acceder en un toque a las 3 áreas operativas.
class _ModuloCompactoAcceso extends StatelessWidget {
  final Key llave;
  final IconData icono;
  final Color colorAcento;
  final String titulo;
  final String subtitulo;
  final VoidCallback alTocar;

  const _ModuloCompactoAcceso({
    required this.llave,
    required this.icono,
    required this.colorAcento,
    required this.titulo,
    required this.subtitulo,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresDoyang.superficieTatami,
      borderRadius: const BorderRadius.all(
        Radius.circular(DimensionesDoyang.radioBoton),
      ),
      child: InkWell(
        key: llave,
        onTap: alTocar,
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioBoton),
        ),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: DimensionesDoyang.altoFilaTactil,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(DimensionesDoyang.radioBoton),
            ),
            border: Border.all(color: ColoresDoyang.bordePiedra),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorAcento.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Icon(icono, color: colorAcento, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titulo,
                      style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
                    ),
                    Text(
                      subtitulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TipografiaDoyang.metadato(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: colorAcento,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaKpiDashboard extends StatelessWidget {
  final String etiqueta;
  final String valorPrincipal;
  final String detalle;
  final Color colorIndicador;

  const _TarjetaKpiDashboard({
    required this.etiqueta,
    required this.valorPrincipal,
    required this.detalle,
    required this.colorIndicador,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorIndicador,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TipografiaDoyang.metadato(peso: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valorPrincipal,
              style: TipografiaDoyang.encabezadoPantalla(
                color: ColoresDoyang.tintaCinturonNegro,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detalle,
            style: TipografiaDoyang.metadato(),
          ),
        ],
      ),
    );
  }
}

class _FilaAlumnoDashboard extends StatelessWidget {
  final Alumno alumno;
  final DictamenElegibilidad dictamen;

  const _FilaAlumnoDashboard({
    required this.alumno,
    required this.dictamen,
  });

  @override
  Widget build(BuildContext context) {
    final alDia = dictamen.adeudoCentavos == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            Text(
              alumno.nombreCompleto,
              style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: alDia
                    ? ColoresDoyang.fondoJadeSuave
                    : ColoresDoyang.fondoHongSuave,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                alDia
                    ? 'Al corriente ✓'
                    : 'Adeudo ${formatearMxn(dictamen.adeudoCentavos)}',
                style: TipografiaDoyang.metadato(
                  color: alDia
                      ? ColoresDoyang.jadeAprobado
                      : ColoresDoyang.selloHong,
                  peso: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${alumno.horarioGrupo} · Asistencias: ${dictamen.asistenciasActuales}/${dictamen.asistenciasRequeridas}${dictamen.elegible ? " · Elegible examen" : ""}',
          style: TipografiaDoyang.metadato(),
        ),
        const SizedBox(height: 6),
        BeltWidget(grado: dictamen.gradoActual, compacto: true),
      ],
    );
  }
}

class _EtiquetaMontoResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color fondo;
  final Color colorTexto;

  const _EtiquetaMontoResumen({
    required this.etiqueta,
    required this.valor,
    required this.fondo,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Text(
        '$etiqueta: $valor',
        style: TipografiaDoyang.metadato(
          color: colorTexto,
          peso: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TarjetaEventoDashboard extends StatelessWidget {
  final String etiquetaTipo;
  final Color colorEtiqueta;
  final Color fondoEtiqueta;
  final String titulo;
  final String fechaTexto;
  final String subtitulo;
  final String etiquetaAccion;
  final VoidCallback alTocarAccion;

  const _TarjetaEventoDashboard({
    required this.etiquetaTipo,
    required this.colorEtiqueta,
    required this.fondoEtiqueta,
    required this.titulo,
    required this.fechaTexto,
    required this.subtitulo,
    required this.etiquetaAccion,
    required this.alTocarAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresDoyang.papelDobok,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: ColoresDoyang.bordePiedra),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: fondoEtiqueta,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                child: Text(
                  etiquetaTipo,
                  style: TipografiaDoyang.metadato(
                    color: colorEtiqueta,
                    peso: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                fechaTexto,
                style: TipografiaDoyang.metadato(peso: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            style: TipografiaDoyang.cuerpo(peso: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: TipografiaDoyang.metadato(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: alTocarAccion,
              child: Text(etiquetaAccion),
            ),
          ),
        ],
      ),
    );
  }
}
