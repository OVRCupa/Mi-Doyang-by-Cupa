import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import '../servicios/servicio_tickets_y_sync.dart';
import 'almacen_doyang.dart';

final almacenDoyangProvider = Provider<AlmacenDoyang>(
  (ref) => AlmacenArchivoDoyang(),
);

/// En la app real siempre arranca en la Pantalla de Inicio amigable.
/// Las pruebas que evalúan directamente una vista pueden sobreescribirlo a `false`.
final iniciarEnPantallaInicioProvider = Provider<bool>((ref) => true);

final controladorDoyangProvider =
    NotifierProvider<ControladorDoyang, EstadoAppDoyang>(
  ControladorDoyang.new,
);

/// Estado reactivo compartido entre las 3 vistas de **Mi Doyang by Cupa**:
/// 1. Escritorio Windows / Recepción y Administración (`dueno` / `recepcion`)
/// 2. App Móvil Android — Portal del Padre de Familia (`tutor`)
/// 3. App Móvil Android — Instructor / Sabonim en Tatami (`instructor`)
class EstadoAppDoyang {
  final MotorDoyang motor;
  final bool mostrarInicio;
  final RolUsuario rolActivo;
  final int seccionRecepcionIndex;
  final int pestanaPadreIndex;
  final String tutorSeleccionadoId;
  final String hijoSeleccionadoId;
  final String? ticketSeleccionadoId;
  final int anchoTicketColumnas;
  final String filtroBusqueda;
  final String filtroExamenes;
  final String? avisoExito;
  final String? avisoError;
  final String? textoExportadoReciente;
  final int revision;

  const EstadoAppDoyang({
    required this.motor,
    this.mostrarInicio = true,
    required this.rolActivo,
    required this.seccionRecepcionIndex,
    required this.pestanaPadreIndex,
    required this.tutorSeleccionadoId,
    required this.hijoSeleccionadoId,
    this.ticketSeleccionadoId,
    required this.anchoTicketColumnas,
    required this.filtroBusqueda,
    required this.filtroExamenes,
    this.avisoExito,
    this.avisoError,
    this.textoExportadoReciente,
    this.revision = 0,
  });

  TutorFamilia get tutorActual {
    final encontrados =
        motor.tutores.where((t) => t.id == tutorSeleccionadoId);
    if (encontrados.isNotEmpty) {
      return encontrados.first;
    }
    return motor.tutores.first;
  }

  List<Alumno> get hijosTutorActual {
    final hijos = motor.hijosDeTutor(
      tutorActual.id,
      incluirBloqueados: false,
    );
    return hijos;
  }

  Alumno? get hijoActual {
    final hijos = hijosTutorActual;
    if (hijos.isEmpty) return null;
    final encontrados = hijos.where((h) => h.id == hijoSeleccionadoId);
    return encontrados.isNotEmpty ? encontrados.first : hijos.first;
  }

  TicketPago? get ticketActual {
    if (motor.tickets.isEmpty) return null;
    if (ticketSeleccionadoId != null) {
      final m = motor.tickets.where((t) => t.id == ticketSeleccionadoId);
      if (m.isNotEmpty) return m.first;
    }
    return motor.tickets.last;
  }

  EstadoAppDoyang copyWith({
    MotorDoyang? motor,
    bool? mostrarInicio,
    RolUsuario? rolActivo,
    int? seccionRecepcionIndex,
    int? pestanaPadreIndex,
    String? tutorSeleccionadoId,
    String? hijoSeleccionadoId,
    String? ticketSeleccionadoId,
    int? anchoTicketColumnas,
    String? filtroBusqueda,
    String? filtroExamenes,
    String? avisoExito,
    bool limpiarAvisoExito = false,
    String? avisoError,
    bool limpiarAvisoError = false,
    String? textoExportadoReciente,
    bool limpiarTextoExportado = false,
  }) {
    return EstadoAppDoyang(
      motor: motor ?? this.motor,
      mostrarInicio: mostrarInicio ?? this.mostrarInicio,
      rolActivo: rolActivo ?? this.rolActivo,
      seccionRecepcionIndex:
          seccionRecepcionIndex ?? this.seccionRecepcionIndex,
      pestanaPadreIndex: pestanaPadreIndex ?? this.pestanaPadreIndex,
      tutorSeleccionadoId: tutorSeleccionadoId ?? this.tutorSeleccionadoId,
      hijoSeleccionadoId: hijoSeleccionadoId ?? this.hijoSeleccionadoId,
      ticketSeleccionadoId: ticketSeleccionadoId ?? this.ticketSeleccionadoId,
      anchoTicketColumnas: anchoTicketColumnas ?? this.anchoTicketColumnas,
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      filtroExamenes: filtroExamenes ?? this.filtroExamenes,
      avisoExito:
          limpiarAvisoExito ? null : (avisoExito ?? this.avisoExito),
      avisoError:
          limpiarAvisoError ? null : (avisoError ?? this.avisoError),
      textoExportadoReciente: limpiarTextoExportado
          ? null
          : (textoExportadoReciente ?? this.textoExportadoReciente),
      revision: revision + 1,
    );
  }
}

class ControladorDoyang extends Notifier<EstadoAppDoyang> {
  @override
  EstadoAppDoyang build() {
    final motor = MotorDoyang.demo();
    final iniciarEnInicio = ref.watch(iniciarEnPantallaInicioProvider);
    unawaited(cargarDesdeAlmacen());
    return EstadoAppDoyang(
      motor: motor,
      mostrarInicio: iniciarEnInicio,
      rolActivo: RolUsuario.dueno,
      seccionRecepcionIndex: 0,
      pestanaPadreIndex: 0,
      tutorSeleccionadoId: 'tutor-laura',
      hijoSeleccionadoId: 'alumno-mateo',
      ticketSeleccionadoId: motor.tickets.first.id,
      anchoTicketColumnas: 48,
      filtroBusqueda: '',
      filtroExamenes: 'todos',
    );
  }

  Future<void> cargarDesdeAlmacen() async {
    final almacen = ref.read(almacenDoyangProvider);
    final json = await almacen.leer();
    if (json == null) return;
    try {
      final motorRestaurado = MotorDoyang.fromJson(json);
      final primerTutor = motorRestaurado.tutores.isNotEmpty
          ? motorRestaurado.tutores.first.id
          : 'tutor-laura';
      final primerHijo = motorRestaurado.alumnos.isNotEmpty
          ? motorRestaurado.alumnos.first.id
          : 'alumno-mateo';
      state = state.copyWith(
        motor: motorRestaurado,
        tutorSeleccionadoId: primerTutor,
        hijoSeleccionadoId: primerHijo,
      );
    } on Object {
      // Si el archivo previo está corrupto, se mantiene el estado semilla limpio.
    }
  }

  void _persistir({
    String? exito,
    String? error,
    String? textoExportado,
    String? ticketId,
  }) {
    state = state.copyWith(
      ticketSeleccionadoId: ticketId ?? state.ticketSeleccionadoId,
      avisoExito: exito,
      limpiarAvisoExito: exito == null,
      avisoError: error,
      limpiarAvisoError: error == null,
      textoExportadoReciente: textoExportado,
    );
    unawaited(
      ref
          .read(almacenDoyangProvider)
          .guardar(state.motor.toJson())
          .catchError((Object _) {}),
    );
  }

  void limpiarAvisos() {
    state = state.copyWith(
      limpiarAvisoExito: true,
      limpiarAvisoError: true,
    );
  }

  // ── Navegación y selectores de vista ────────────────────────────────────

  void irAInicio() {
    state = state.copyWith(
      mostrarInicio: true,
      limpiarAvisoExito: true,
      limpiarAvisoError: true,
    );
  }

  void salirDeInicio() {
    state = state.copyWith(
      mostrarInicio: false,
      limpiarAvisoExito: true,
      limpiarAvisoError: true,
    );
  }

  void actualizarColorPrimarioRapido(String colorHex) {
    try {
      final actual = state.motor.academia;
      state.motor.actualizarAcademia(
        actual.copyWith(colorPrimarioHex: colorHex),
      );
      _persistir(exito: 'Color institucional actualizado.');
    } on Object catch (e) {
      _persistir(error: e.toString());
    }
  }

  void cambiarRolActivo(RolUsuario nuevoRol) {
    state = state.copyWith(
      rolActivo: nuevoRol,
      limpiarAvisoExito: true,
      limpiarAvisoError: true,
    );
  }

  void cambiarSeccionRecepcion(int index) {
    state = state.copyWith(
      seccionRecepcionIndex: index,
      limpiarAvisoError: true,
    );
  }

  void cambiarPestanaPadre(int index) {
    state = state.copyWith(
      pestanaPadreIndex: index,
      limpiarAvisoError: true,
    );
  }

  void seleccionarTutor(String tutorId) {
    final hijos =
        state.motor.hijosDeTutor(tutorId, incluirBloqueados: true);
    state = state.copyWith(
      tutorSeleccionadoId: tutorId,
      hijoSeleccionadoId:
          hijos.isNotEmpty ? hijos.first.id : state.hijoSeleccionadoId,
    );
  }

  void seleccionarHijo(String alumnoId) {
    state = state.copyWith(hijoSeleccionadoId: alumnoId);
  }

  void seleccionarTicket(String ticketId) {
    state = state.copyWith(ticketSeleccionadoId: ticketId);
  }

  void cambiarAnchoTicket(int columnas) {
    state = state.copyWith(anchoTicketColumnas: columnas);
  }

  void actualizarFiltroBusqueda(String texto) {
    state = state.copyWith(filtroBusqueda: texto);
  }

  void actualizarFiltroExamenes(String filtro) {
    state = state.copyWith(filtroExamenes: filtro);
  }

  // ── M1 · Personalización de la academia y grados ─────────────────────────

  bool actualizarConfiguracionAcademia(AcademiaConfig nuevaConfig) {
    try {
      state.motor.actualizarAcademia(
        nuevaConfig,
        rolActor: RolUsuario.dueno,
      );
      _persistir(exito: 'Configuración del dojang actualizada con éxito.');
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  bool guardarGradoPersonalizado(GradoCinta grado) {
    try {
      state.motor.guardarGradoCinta(grado, rolActor: RolUsuario.dueno);
      _persistir(exito: 'Grado ${grado.codigo} (${grado.nombre}) guardado.');
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  // ── M2 · Alta de Familias, Alumnos, Privacidad LFPDPPP 2025 y Asistencia ─

  bool registrarFamiliaYAlumno({
    required String nombreTutor,
    required String telefonoWhatsapp,
    required String correoTutor,
    required String parentesco,
    required bool declaracionPatriaPotestad,
    required bool aceptoAvisoIntegral,
    required bool consentimientoSaludExpreso,
    required bool consentimientoFotoInterna,
    required bool consentimientoPromociones,
    required String nombreAlumno,
    required String apellidosAlumno,
    required String fechaNacimientoIso,
    required SexoRama sexoRama,
    required String gradoActualId,
    required String horarioGrupo,
    String? tipoSangreOpcional,
    String? alergiasCuidadosOpcional,
    String? tutorExistenteId,
  }) {
    try {
      final motor = state.motor;
      late final TutorFamilia tutor;
      if (tutorExistenteId != null && tutorExistenteId.isNotEmpty) {
        final base = motor.obtenerTutorPorId(tutorExistenteId);
        tutor = base.copyWith(
          consentimiento: base.consentimiento.copyWith(
            declaracionPatriaPotestad: declaracionPatriaPotestad,
            aceptoAvisoIntegral: aceptoAvisoIntegral,
            consentimientoSaludExpreso: consentimientoSaludExpreso,
            consentimientoFotoInterna: consentimientoFotoInterna,
            consentimientoPromociones: consentimientoPromociones,
          ),
        );
      } else {
        final nuevoTutorId = 'tutor-${motor.tutores.length + 1}';
        tutor = TutorFamilia(
          id: nuevoTutorId,
          academiaId: motor.academia.id,
          nombreCompleto: nombreTutor.trim(),
          telefonoWhatsapp: telefonoWhatsapp.trim(),
          correo: correoTutor.trim(),
          parentesco: parentesco.trim(),
          consentimiento: ConsentimientoTutor(
            tutorId: nuevoTutorId,
            declaracionPatriaPotestad: declaracionPatriaPotestad,
            aceptoAvisoIntegral: aceptoAvisoIntegral,
            consentimientoSaludExpreso: consentimientoSaludExpreso,
            consentimientoFotoInterna: consentimientoFotoInterna,
            consentimientoPromociones: consentimientoPromociones,
            versionAviso: 'v2026.1-LFPDPPP',
            registradoEnIso: '2026-11-23T18:30:00Z',
          ),
        );
      }

      final nuevoAlumnoId = 'alumno-${motor.alumnos.length + 1}';
      final alumno = Alumno(
        id: nuevoAlumnoId,
        academiaId: motor.academia.id,
        tutorId: tutor.id,
        nombre: nombreAlumno.trim(),
        apellidos: apellidosAlumno.trim(),
        fechaNacimientoIso: fechaNacimientoIso.trim(),
        sexoRama: sexoRama,
        gradoActualId: gradoActualId,
        fechaUltimoGradoIso: '2026-11-23',
        asistenciasEnGradoActual: 0,
        horarioGrupo: horarioGrupo.trim(),
        tipoSangreOpcional:
            (tipoSangreOpcional != null && tipoSangreOpcional.trim().isNotEmpty)
                ? tipoSangreOpcional.trim()
                : null,
        alergiasCuidadosOpcional: (alergiasCuidadosOpcional != null &&
                alergiasCuidadosOpcional.trim().isNotEmpty)
            ? alergiasCuidadosOpcional.trim()
            : null,
        telefonoEmergenciaOpcional: tutor.telefonoWhatsapp,
        codigoQr: 'DOYANG-QR-${nuevoAlumnoId.toUpperCase()}',
      );

      // Validar LFPDPPP 2025 antes de mutar el padrón para evitar tutores huérfanos.
      validarPrivacidadAlumno(alumno: alumno, tutor: tutor);
      motor.registrarTutor(tutor);
      motor.registrarAlumno(alumno);
      state = state.copyWith(
        tutorSeleccionadoId: tutor.id,
        hijoSeleccionadoId: alumno.id,
      );
      _persistir(
        exito:
            'Expediente de ${alumno.nombreCompleto} registrado conforme a LFPDPPP 2025.',
      );
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  bool registrarAsistenciaAlumno({
    required String alumnoId,
    String fechaDiaIso = '2026-11-23',
    MetodoAsistencia metodo = MetodoAsistencia.qr,
  }) {
    try {
      final asistencia = state.motor.registrarAsistencia(
        alumnoId: alumnoId,
        fechaDiaIso: fechaDiaIso,
        metodo: metodo,
      );
      final alumno = state.motor.obtenerAlumnoPorId(alumnoId);
      _persistir(
        exito:
            'Asistencia registrada (${asistencia.metodo.name.toUpperCase()}) para ${alumno.nombreCompleto}.',
      );
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  // ── M3 · Caja Offline-First, Mensualidades, Cobros y Tickets ─────────────

  void generarMensualidadesFamiliaSeleccionada({String periodo = '2026-12'}) {
    try {
      final generados = state.motor.generarMensualidadesFamilia(
        tutorId: state.tutorActual.id,
        periodo: periodo,
      );
      _persistir(
        exito: generados.isEmpty
            ? 'Las mensualidades del periodo $periodo ya estaban generadas.'
            : 'Se generaron ${generados.length} cargo(s) de mensualidad con descuento familiar.',
      );
    } on Object catch (e) {
      _persistir(error: e.toString());
    }
  }

  void aplicarMoraVencidos({String fechaCorteIso = '2026-12-06'}) {
    final aplicados =
        state.motor.aplicarRecargosMora(fechaCorteIso: fechaCorteIso);
    _persistir(
      exito: 'Recargo por mora aplicado a $aplicados mensualidad(es) vencida(s).',
    );
  }

  TicketPago? cobrarCargos({
    required String tutorId,
    required Map<String, int> abonosPorCargoId,
    required MetodoPago metodoPago,
    String? referenciaPagoOpcional,
  }) {
    try {
      final ticket = state.motor.registrarCobro(
        tutorId: tutorId,
        abonosPorCargoId: abonosPorCargoId,
        metodoPago: metodoPago,
        referenciaPagoOpcional: referenciaPagoOpcional,
      );
      _persistir(
        exito:
            'Ticket ${ticket.folio} emitido por ${formatearMxn(ticket.totalPagadoCentavos)}.',
        ticketId: ticket.id,
      );
      return ticket;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return null;
    }
  }

  bool cancelarTicketConReverso({
    required String ticketId,
    required String motivo,
  }) {
    try {
      final cancelado = state.motor.cancelarTicket(
        ticketId: ticketId,
        motivo: motivo,
        actorUsuarioId: 'dueno-1',
        rolActor: RolUsuario.dueno,
      );
      _persistir(
        exito:
            'Ticket ${cancelado.folio} cancelado (${cancelado.folioReversoOpcional}).',
        ticketId: cancelado.id,
      );
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  void sincronizarColaOutbox() {
    final n = state.motor.marcarOutboxSincronizado();
    _persistir(
      exito: 'Sincronización completada: $n evento(s) enviados a la nube.',
    );
  }

  // ── M4 · Grados y Exámenes Internos ──────────────────────────────────────

  InscripcionExamen? inscribirAExamen({
    required String convocatoriaId,
    required String alumnoId,
    bool consentimientoTutorAceptado = true,
    bool excepcionAutorizada = false,
    String? motivoExcepcionOpcional,
  }) {
    try {
      final insc = state.motor.inscribirAlumnoExamen(
        convocatoriaId: convocatoriaId,
        alumnoId: alumnoId,
        consentimientoTutorAceptado: consentimientoTutorAceptado,
        excepcionAutorizada: excepcionAutorizada,
        motivoExcepcionOpcional: motivoExcepcionOpcional,
      );
      _persistir(
        exito:
            'Alumno inscrito a examen. Cargo generado en caja listo para cobro.',
      );
      return insc;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return null;
    }
  }

  bool evaluarAlumnoEnExamen({
    required String inscripcionExamenId,
    required int poomsae,
    required int kyorugi,
    required int rompimiento,
    required int teoria,
    required bool aprobado,
    String observaciones = '',
    bool exigirPagoDerechoExamen = true,
  }) {
    try {
      final evaluacion = EvaluacionExamen(
        poomsae: poomsae,
        kyorugi: kyorugi,
        rompimiento: rompimiento,
        teoria: teoria,
        aprobado: aprobado,
        observaciones: observaciones,
        evaluadoEnIso: '2026-12-12T12:00:00Z',
      );
      final insc = state.motor.registrarEvaluacionExamen(
        inscripcionExamenId: inscripcionExamenId,
        evaluacion: evaluacion,
        exigirPagoDerechoExamen: exigirPagoDerechoExamen,
      );
      final alumno = state.motor.obtenerAlumnoPorId(insc.alumnoId);
      final gradoNuevo = state.motor.obtenerGradoPorId(alumno.gradoActualId);
      _persistir(
        exito: aprobado
            ? '¡Examen aprobado! ${alumno.nombreCompleto} ascendió a ${gradoNuevo.codigo} (${gradoNuevo.nombre}).'
            : 'Evaluación de examen registrada para ${alumno.nombreCompleto}.',
      );
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  // ── M5 · Equipo e Inventario del Dojang ──────────────────────────────────

  PedidoEquipo? solicitarEquipo({
    required String alumnoId,
    required String productoId,
    int cantidad = 1,
  }) {
    try {
      final pedido = state.motor.crearPedidoEquipo(
        alumnoId: alumnoId,
        productoId: productoId,
        cantidad: cantidad,
      );
      _persistir(
        exito:
            'Pedido de ${pedido.nombreProductoSnapshot} registrado. Cargo enviado a caja.',
      );
      return pedido;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return null;
    }
  }

  bool entregarEquipoEnMostrador(String pedidoId) {
    try {
      final pedido = state.motor.entregarPedidoEquipo(pedidoId: pedidoId);
      _persistir(
        exito:
            '${pedido.nombreProductoSnapshot} (${pedido.tallaSnapshot}) marcado como ENTREGADO.',
      );
      return true;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return false;
    }
  }

  // ── M6 · Torneos e Interoperabilidad CUPA (D-12) ─────────────────────────

  InscripcionTorneo? inscribirATorneo({
    required String torneoId,
    required String alumnoId,
    required ModalidadTorneo modalidad,
    required double pesoKg,
    required String categoriaDivision,
    required bool responsivaTutorAceptada,
  }) {
    try {
      final insc = state.motor.inscribirAlumnoTorneo(
        torneoId: torneoId,
        alumnoId: alumnoId,
        modalidad: modalidad,
        pesoKgRegistrado: pesoKg,
        categoriaDivision: categoriaDivision,
        responsivaTutorAceptada: responsivaTutorAceptada,
      );
      _persistir(
        exito:
            'Alumno inscrito al torneo con responsiva digital firmada. Cuota enviada a caja.',
      );
      return insc;
    } on Object catch (e) {
      _persistir(error: e.toString());
      return null;
    }
  }

  void registrarMedalla({
    required String inscripcionTorneoId,
    required MedallaTorneo medalla,
    String notas = '',
  }) {
    try {
      state.motor.registrarMedallaTorneo(
        inscripcionTorneoId: inscripcionTorneoId,
        medalla: medalla,
        notasResultado: notas,
      );
      _persistir(
        exito: 'Resultado de torneo (${medalla.name.toUpperCase()}) guardado.',
      );
    } on Object catch (e) {
      _persistir(error: e.toString());
    }
  }

  String exportarTorneoCupaJson(String torneoId) {
    final json = state.motor.exportarInscritosTorneoCupaJson(torneoId);
    _persistir(
      exito: 'Padrón de competidores pagados exportado en formato CUPA JSON.',
      textoExportado: json,
    );
    return json;
  }

  String exportarTorneoCupaCsv(String torneoId) {
    final csv = state.motor.exportarInscritosTorneoCupaCsv(torneoId);
    _persistir(
      exito: 'Padrón de competidores pagados exportado en formato CUPA CSV.',
      textoExportado: csv,
    );
    return csv;
  }

  Future<void> exportarTicketImprimible(TicketPago ticket) async {
    try {
      final archivo = await ExportadorComprobantesLocal.guardarComprobanteHtml(
        ticket: ticket,
        academia: state.motor.academia,
      );
      _persistir(
        exito: 'Comprobante HTML/PDF guardado: ${archivo.path}',
      );
    } on Object catch (e) {
      _persistir(error: 'No se pudo exportar el comprobante: $e');
    }
  }

  Future<void> exportarTicketEscPos(TicketPago ticket) async {
    try {
      final archivo = await ExportadorComprobantesLocal.guardarComprobanteEscPos(
        ticket: ticket,
        academia: state.motor.academia,
        anchoColumnas: state.anchoTicketColumnas,
      );
      _persistir(
        exito:
            'Archivo térmico ESC/POS (${state.anchoTicketColumnas} col) listo: ${archivo.path}',
      );
    } on Object catch (e) {
      _persistir(error: 'No se pudo generar el ticket ESC/POS: $e');
    }
  }

  Future<void> sincronizarConSupabase() async {
    final sincronizador = SincronizadorSupabase(
      config: ConfigSupabase.desdeEntorno(),
    );
    final res = await sincronizador.sincronizarOutbox(state.motor);
    _persistir(exito: res.mensaje);
  }

  // ── Derechos ARCO (LFPDPPP 2025) ─────────────────────────────────────────

  String exportarExpedienteArco(String tutorId) {
    final json = state.motor.exportarExpedienteArcoJson(tutorId);
    _persistir(
      exito: 'Expediente ARCO completo exportado en JSON (registrado en bitácora).',
      textoExportado: json,
    );
    return json;
  }

  void ejecutarBajaArco({String? alumnoId, String? tutorId}) {
    try {
      state.motor.ejecutarBajaArcoTutorOAlumno(
        alumnoId: alumnoId,
        tutorId: tutorId,
        ejecutadoPorId: 'dueno-1',
      );
      _persistir(
        exito:
            'Baja y bloqueo ARCO ejecutado: datos sensibles purgados y folios contables disociados.',
      );
    } on Object catch (e) {
      _persistir(error: e.toString());
    }
  }
}
