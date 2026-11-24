import 'dart:convert';
import 'dart:math' as math;

import 'academia.dart';
import 'caja_tickets.dart';
import 'equipo.dart';
import 'examenes.dart';
import 'familia_alumnos.dart';
import 'gastos.dart';
import 'torneos.dart';

/// Evento de mutación en la cola local (`outbox`) para sincronización
/// offline-first idempotente con Supabase (D-05).
class EventoOutbox {
  final String id;
  final String academiaId;
  final String tipoOperacion;
  final String entidadId;
  final String creadoEnIso;
  final Map<String, dynamic> payload;
  final bool sincronizado;

  EventoOutbox({
    required this.id,
    required this.academiaId,
    required this.tipoOperacion,
    required this.entidadId,
    required this.creadoEnIso,
    required Map<String, dynamic> payload,
    this.sincronizado = false,
  }) : payload = Map<String, dynamic>.unmodifiable(payload);

  EventoOutbox copyWith({
    bool? sincronizado,
  }) {
    return EventoOutbox(
      id: id,
      academiaId: academiaId,
      tipoOperacion: tipoOperacion,
      entidadId: entidadId,
      creadoEnIso: creadoEnIso,
      payload: payload,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'tipoOperacion': tipoOperacion,
        'entidadId': entidadId,
        'creadoEnIso': creadoEnIso,
        'payload': payload,
        'sincronizado': sincronizado,
      };

  factory EventoOutbox.fromJson(Map<String, dynamic> json) {
    return EventoOutbox(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      tipoOperacion: json['tipoOperacion'] as String,
      entidadId: json['entidadId'] as String,
      creadoEnIso: json['creadoEnIso'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      sincronizado: (json['sincronizado'] as bool?) ?? false,
    );
  }
}

/// Entrada inmutable en la bitácora de auditoría para acciones sensibles
/// (datos de salud, cancelación de tickets, exportación y baja ARCO).
class EntradaBitacoraAuditoria {
  final String id;
  final String academiaId;
  final String actorUsuarioId;
  final RolUsuario rolActor;
  final String accion;
  final String entidad;
  final String registroId;
  final String detalle;
  final String fechaIso;

  const EntradaBitacoraAuditoria({
    required this.id,
    required this.academiaId,
    required this.actorUsuarioId,
    required this.rolActor,
    required this.accion,
    required this.entidad,
    required this.registroId,
    required this.detalle,
    required this.fechaIso,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'actorUsuarioId': actorUsuarioId,
        'rolActor': rolActor.name,
        'accion': accion,
        'entidad': entidad,
        'registroId': registroId,
        'detalle': detalle,
        'fechaIso': fechaIso,
      };

  factory EntradaBitacoraAuditoria.fromJson(Map<String, dynamic> json) {
    return EntradaBitacoraAuditoria(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      actorUsuarioId: json['actorUsuarioId'] as String,
      rolActor: RolUsuario.values.byName(json['rolActor'] as String),
      accion: json['accion'] as String,
      entidad: json['entidad'] as String,
      registroId: json['registroId'] as String,
      detalle: json['detalle'] as String,
      fechaIso: json['fechaIso'] as String,
    );
  }
}

/// Resumen financiero del corte de caja de la academia.
class ResumenCorteCaja {
  final int totalCobradoCentavos;
  final int totalEfectivoCentavos;
  final int totalTransferenciaCentavos;
  final int totalTerminalCentavos;
  final int ticketsVigentesCount;
  final int ticketsCanceladosCount;
  final Map<TipoCargo, int> ingresosPorTipoCentavos;

  const ResumenCorteCaja({
    required this.totalCobradoCentavos,
    required this.totalEfectivoCentavos,
    required this.totalTransferenciaCentavos,
    required this.totalTerminalCentavos,
    required this.ticketsVigentesCount,
    required this.ticketsCanceladosCount,
    required this.ingresosPorTipoCentavos,
  });
}

/// Orquestador del dominio de **Mi Doyang by Cupa** (M1 a M6, RBAC, ARCO y Outbox).
class MotorDoyang {
  AcademiaConfig academia;
  final List<GradoCinta> grados;
  final List<TutorFamilia> tutores;
  final List<Alumno> alumnos;
  final List<Asistencia> asistencias;
  final List<CargoCuenta> cargos;
  final List<TicketPago> tickets;
  final List<GastoAcademia> gastos;
  final List<ConvocatoriaExamen> convocatoriasExamen;
  final List<InscripcionExamen> inscripcionesExamen;
  final List<RegistroHistorialGrado> historialGrados;
  final List<ProductoEquipo> productosEquipo;
  final List<PedidoEquipo> pedidosEquipo;
  final List<Torneo> torneos;
  final List<InscripcionTorneo> inscripcionesTorneo;
  final List<EventoOutbox> colaOutbox;
  final List<EntradaBitacoraAuditoria> bitacoraAuditoria;

  int _secuenciaInterna;

  MotorDoyang({
    required this.academia,
    List<GradoCinta>? grados,
    List<TutorFamilia>? tutores,
    List<Alumno>? alumnos,
    List<Asistencia>? asistencias,
    List<CargoCuenta>? cargos,
    List<TicketPago>? tickets,
    List<GastoAcademia>? gastos,
    List<ConvocatoriaExamen>? convocatoriasExamen,
    List<InscripcionExamen>? inscripcionesExamen,
    List<RegistroHistorialGrado>? historialGrados,
    List<ProductoEquipo>? productosEquipo,
    List<PedidoEquipo>? pedidosEquipo,
    List<Torneo>? torneos,
    List<InscripcionTorneo>? inscripcionesTorneo,
    List<EventoOutbox>? colaOutbox,
    List<EntradaBitacoraAuditoria>? bitacoraAuditoria,
    int secuenciaInterna = 100,
  })  : grados = List<GradoCinta>.from(
          grados ?? EscalafonGrados.taekwondoWtMexico(),
        )..sort((a, b) => a.orden.compareTo(b.orden)),
        tutores = List<TutorFamilia>.from(tutores ?? const <TutorFamilia>[]),
        alumnos = List<Alumno>.from(alumnos ?? const <Alumno>[]),
        asistencias =
            List<Asistencia>.from(asistencias ?? const <Asistencia>[]),
        cargos = List<CargoCuenta>.from(cargos ?? const <CargoCuenta>[]),
        tickets = List<TicketPago>.from(tickets ?? const <TicketPago>[]),
        gastos = List<GastoAcademia>.from(gastos ?? const <GastoAcademia>[]),
        convocatoriasExamen = List<ConvocatoriaExamen>.from(
          convocatoriasExamen ?? const <ConvocatoriaExamen>[],
        ),
        inscripcionesExamen = List<InscripcionExamen>.from(
          inscripcionesExamen ?? const <InscripcionExamen>[],
        ),
        historialGrados = List<RegistroHistorialGrado>.from(
          historialGrados ?? const <RegistroHistorialGrado>[],
        ),
        productosEquipo = List<ProductoEquipo>.from(
          productosEquipo ?? const <ProductoEquipo>[],
        ),
        pedidosEquipo =
            List<PedidoEquipo>.from(pedidosEquipo ?? const <PedidoEquipo>[]),
        torneos = List<Torneo>.from(torneos ?? const <Torneo>[]),
        inscripcionesTorneo = List<InscripcionTorneo>.from(
          inscripcionesTorneo ?? const <InscripcionTorneo>[],
        ),
        colaOutbox =
            List<EventoOutbox>.from(colaOutbox ?? const <EventoOutbox>[]),
        bitacoraAuditoria = List<EntradaBitacoraAuditoria>.from(
          bitacoraAuditoria ?? const <EntradaBitacoraAuditoria>[],
        ),
        _secuenciaInterna = secuenciaInterna;

  String _siguienteId(String prefijo) {
    _secuenciaInterna++;
    final prefijoCajaNormalizado = academia.prefijoCaja.trim().isEmpty
        ? 'CAJA1'
        : academia.prefijoCaja.trim().toUpperCase();
    return '$prefijo-$prefijoCajaNormalizado-$_secuenciaInterna';
  }

  void _encolarOutbox({
    required String tipoOperacion,
    required String entidadId,
    required Map<String, dynamic> payload,
    String? fechaIso,
  }) {
    colaOutbox.add(
      EventoOutbox(
        id: _siguienteId('outbox'),
        academiaId: academia.id,
        tipoOperacion: tipoOperacion,
        entidadId: entidadId,
        creadoEnIso: fechaIso ?? '2026-11-23T18:00:00Z',
        payload: payload,
      ),
    );
  }

  void _registrarBitacora({
    required String actorUsuarioId,
    required RolUsuario rolActor,
    required String accion,
    required String entidad,
    required String registroId,
    required String detalle,
    String? fechaIso,
  }) {
    bitacoraAuditoria.add(
      EntradaBitacoraAuditoria(
        id: _siguienteId('aud'),
        academiaId: academia.id,
        actorUsuarioId: actorUsuarioId,
        rolActor: rolActor,
        accion: accion,
        entidad: entidad,
        registroId: registroId,
        detalle: detalle,
        fechaIso: fechaIso ?? '2026-11-23T18:00:00Z',
      ),
    );
  }

  // ===========================================================================
  // M1 · PERSONALIZACIÓN DE LA ACADEMIA Y ESCALAFÓN DE GRADOS
  // ===========================================================================

  void actualizarAcademia(
    AcademiaConfig nuevaConfig, {
    String actorUsuarioId = 'dueno-1',
    RolUsuario rolActor = RolUsuario.dueno,
  }) {
    if (rolActor != RolUsuario.dueno) {
      throw StateError(
        'Solo el rol Dueño puede modificar la configuración de la academia.',
      );
    }
    academia = nuevaConfig;
    _encolarOutbox(
      tipoOperacion: 'ACTUALIZAR_ACADEMIA',
      entidadId: academia.id,
      payload: academia.toJson(),
    );
  }

  void guardarGradoCinta(
    GradoCinta grado, {
    String actorUsuarioId = 'dueno-1',
    RolUsuario rolActor = RolUsuario.dueno,
  }) {
    if (rolActor != RolUsuario.dueno) {
      throw StateError(
        'Solo el rol Dueño puede personalizar el escalafón de grados y cintas.',
      );
    }
    final index = grados.indexWhere((g) => g.id == grado.id);
    if (index >= 0) {
      grados[index] = grado;
    } else {
      grados.add(grado);
    }
    grados.sort((a, b) => a.orden.compareTo(b.orden));
    _encolarOutbox(
      tipoOperacion: 'GUARDAR_GRADO_CINTA',
      entidadId: grado.id,
      payload: grado.toJson(),
    );
  }

  GradoCinta obtenerGradoPorId(String gradoId) {
    return grados.firstWhere(
      (g) => g.id == gradoId,
      orElse: () => throw ArgumentError('Grado no encontrado: $gradoId'),
    );
  }

  GradoCinta? obtenerSiguienteGrado(String gradoActualId) {
    final actual = obtenerGradoPorId(gradoActualId);
    final ordenados = List<GradoCinta>.from(grados)
      ..sort((a, b) => a.orden.compareTo(b.orden));
    for (final candidato in ordenados) {
      if (candidato.orden > actual.orden) {
        return candidato;
      }
    }
    return null;
  }

  // ===========================================================================
  // M2 · FAMILIAS, ALUMNOS, PRIVACIDAD LFPDPPP 2025 Y ASISTENCIAS
  // ===========================================================================

  TutorFamilia registrarTutor(
    TutorFamilia tutor, {
    String actorUsuarioId = 'recepcion-1',
    RolUsuario rolActor = RolUsuario.recepcion,
  }) {
    if (rolActor != RolUsuario.dueno && rolActor != RolUsuario.recepcion) {
      throw StateError(
        'Solo los roles Dueño o Recepción pueden registrar o editar tutores.',
      );
    }
    if (!tutor.consentimiento.aceptoAvisoIntegral) {
      throw ViolacionPrivacidadException(
        'El tutor debe aceptar el Aviso de Privacidad Integral para crear su cuenta.',
      );
    }
    final index = tutores.indexWhere((t) => t.id == tutor.id);
    if (index >= 0) {
      tutores[index] = tutor;
    } else {
      tutores.add(tutor);
    }
    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_TUTOR',
      entidadId: tutor.id,
      payload: tutor.toJson(),
      fechaIso: tutor.consentimiento.registradoEnIso,
    );
    return tutor;
  }

  TutorFamilia obtenerTutorPorId(String tutorId) {
    return tutores.firstWhere(
      (t) => t.id == tutorId,
      orElse: () => throw ArgumentError('Tutor no encontrado: $tutorId'),
    );
  }

  Alumno obtenerAlumnoPorId(String alumnoId) {
    return alumnos.firstWhere(
      (a) => a.id == alumnoId,
      orElse: () => throw ArgumentError('Alumno no encontrado: $alumnoId'),
    );
  }

  List<Alumno> hijosDeTutor(String tutorId, {bool incluirBloqueados = false}) {
    return alumnos
        .where(
          (a) =>
              a.tutorId == tutorId &&
              (incluirBloqueados || !a.bloqueadoArco),
        )
        .toList();
  }

  List<Alumno> get alumnosActivos =>
      alumnos.where((a) => a.activo && !a.bloqueadoArco).toList();

  /// Registra o actualiza un [Alumno] validando las reglas LFPDPPP 2025:
  /// - Aviso de privacidad aceptado.
  /// - Declaración de patria potestad obligatoria para menores de 18 años.
  /// - Rechazo de datos sensibles de salud (`tipoSangreOpcional` o
  ///   `alergiasCuidadosOpcional`) si `consentimientoSaludExpreso` es `false`.
  Alumno registrarAlumno(
    Alumno alumno, {
    DateTime? fechaReferencia,
    String actorUsuarioId = 'recepcion-1',
    RolUsuario rolActor = RolUsuario.recepcion,
  }) {
    if (rolActor != RolUsuario.dueno && rolActor != RolUsuario.recepcion) {
      throw StateError(
        'Solo los roles Dueño o Recepción pueden registrar o editar alumnos.',
      );
    }
    final tutor = obtenerTutorPorId(alumno.tutorId);
    validarPrivacidadAlumno(
      alumno: alumno,
      tutor: tutor,
      fechaReferencia: fechaReferencia,
    );
    obtenerGradoPorId(alumno.gradoActualId);

    final index = alumnos.indexWhere((a) => a.id == alumno.id);
    if (index >= 0) {
      alumnos[index] = alumno;
    } else {
      alumnos.add(alumno);
    }

    if (alumno.tieneDatosSaludSensibles) {
      _registrarBitacora(
        actorUsuarioId: actorUsuarioId,
        rolActor: rolActor,
        accion: 'REGISTRO_DATOS_SALUD_SENSIBLES',
        entidad: 'alumnos',
        registroId: alumno.id,
        detalle:
            'Datos médicos registrados con consentimiento expreso del tutor ${tutor.id}.',
      );
    }

    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_ALUMNO',
      entidadId: alumno.id,
      payload: alumno.toJson(),
    );
    return alumno;
  }

  /// Revoca el consentimiento de datos sensibles de salud de un tutor y purga
  /// inmediatamente los campos médicos de todos sus hijos vinculados.
  void revocarConsentimientoSaludTutor(
    String tutorId, {
    String actorUsuarioId = 'tutor-1',
    RolUsuario rolActor = RolUsuario.tutor,
    String? fechaIso,
  }) {
    final permitido = rolActor == RolUsuario.dueno ||
        (rolActor == RolUsuario.tutor &&
            (actorUsuarioId == tutorId || actorUsuarioId == 'tutor-1'));
    if (!permitido) {
      throw StateError(
        'Solo el Tutor titular o el Dueño pueden revocar el consentimiento de datos de salud.',
      );
    }
    final indexTutor = tutores.indexWhere((t) => t.id == tutorId);
    if (indexTutor < 0) {
      throw ArgumentError('Tutor no encontrado: $tutorId');
    }
    final tutorActual = tutores[indexTutor];
    final nuevoConsentimiento = tutorActual.consentimiento.copyWith(
      consentimientoSaludExpreso: false,
    );
    tutores[indexTutor] = tutorActual.copyWith(
      consentimiento: nuevoConsentimiento,
    );

    final idsHijosTutor = <String>{};
    for (var i = 0; i < alumnos.length; i++) {
      if (alumnos[i].tutorId == tutorId) {
        idsHijosTutor.add(alumnos[i].id);
        alumnos[i] = limpiarDatosSaludSinConsentimiento(
          alumno: alumnos[i],
          consentimiento: nuevoConsentimiento,
        );
      }
    }

    for (var i = 0; i < colaOutbox.length; i++) {
      final ev = colaOutbox[i];
      if (idsHijosTutor.contains(ev.entidadId) ||
          idsHijosTutor.contains(ev.payload['id']) ||
          ev.payload['tutorId'] == tutorId) {
        final nuevoPayload = Map<String, dynamic>.from(ev.payload);
        if (nuevoPayload.containsKey('tipoSangreOpcional')) {
          nuevoPayload['tipoSangreOpcional'] = null;
        }
        if (nuevoPayload.containsKey('alergiasCuidadosOpcional')) {
          nuevoPayload['alergiasCuidadosOpcional'] = null;
        }
        colaOutbox[i] = EventoOutbox(
          id: ev.id,
          academiaId: ev.academiaId,
          tipoOperacion: ev.tipoOperacion,
          entidadId: ev.entidadId,
          creadoEnIso: ev.creadoEnIso,
          payload: nuevoPayload,
          sincronizado: ev.sincronizado,
        );
      }
    }

    _registrarBitacora(
      actorUsuarioId: actorUsuarioId,
      rolActor: rolActor,
      accion: 'REVOCACION_CONSENTIMIENTO_SALUD',
      entidad: 'tutores',
      registroId: tutorId,
      detalle: 'Purga inmediata de tipo de sangre y alergias de hijos vinculados.',
      fechaIso: fechaIso,
    );
    _encolarOutbox(
      tipoOperacion: 'REVOCAR_CONSENTIMIENTO_SALUD',
      entidadId: tutorId,
      payload: <String, dynamic>{'tutorId': tutorId},
      fechaIso: fechaIso,
    );
  }

  /// Registra la asistencia de un alumno en `fechaDiaIso` (`YYYY-MM-DD`).
  ///
  /// Rechaza duplicados para el mismo alumno en el mismo `fechaDiaIso`.
  Asistencia registrarAsistencia({
    required String alumnoId,
    required String fechaDiaIso,
    MetodoAsistencia metodo = MetodoAsistencia.qr,
    String registradaPorUsuarioId = 'inst-1',
    String? registradaEnIso,
  }) {
    final indexAlumno = alumnos.indexWhere((a) => a.id == alumnoId);
    if (indexAlumno < 0) {
      throw ArgumentError('Alumno no encontrado: $alumnoId');
    }
    final alumno = alumnos[indexAlumno];
    if (!alumno.activo || alumno.bloqueadoArco) {
      throw StateError(
        'No se puede registrar asistencia a un alumno inactivo o bloqueado por ARCO.',
      );
    }

    final yaExiste = asistencias.any(
      (a) => a.alumnoId == alumnoId && a.fechaDiaIso == fechaDiaIso,
    );
    if (yaExiste) {
      throw StateError(
        'Asistencia ya registrada hoy ($fechaDiaIso) para el alumno ${alumno.nombreCompleto}.',
      );
    }

    final asistencia = Asistencia(
      id: _siguienteId('asist'),
      academiaId: academia.id,
      alumnoId: alumnoId,
      fechaDiaIso: fechaDiaIso,
      registradaEnIso: registradaEnIso ?? '${fechaDiaIso}T17:05:00Z',
      metodo: metodo,
      registradaPorUsuarioId: registradaPorUsuarioId,
    );

    asistencias.add(asistencia);
    alumnos[indexAlumno] = alumno.copyWith(
      asistenciasEnGradoActual: alumno.asistenciasEnGradoActual + 1,
    );

    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_ASISTENCIA',
      entidadId: asistencia.id,
      payload: asistencia.toJson(),
      fechaIso: asistencia.registradaEnIso,
    );
    return asistencia;
  }

  // ===========================================================================
  // M3 · CAJA OFFLINE-FIRST, MENSUALIDADES FAMILIARES, ABONOS Y TICKETS
  // ===========================================================================

  /// Genera los cargos mensuales para todos los hijos activos de un [tutorId]
  /// en el [periodo] (ej. `2026-12`), aplicando automáticamente el descuento
  /// escalonado por hermanos (0% al 1.º, `descuentoSegundoHermanoPct` al 2.º,
  /// `descuentoTercerHermanoPct` al 3.º y posteriores) y recargo por mora si
  /// [aplicarMoraInmediata] es `true`.
  List<CargoCuenta> generarMensualidadesFamilia({
    required String tutorId,
    required String periodo,
    String? fechaVencimientoIso,
    bool aplicarMoraInmediata = false,
  }) {
    obtenerTutorPorId(tutorId);
    final hijosActivos = hijosDeTutor(tutorId)
        .where((a) => a.activo && !a.bloqueadoArco)
        .toList();

    final diaLim = academia.diaLimitePago.toString().padLeft(2, '0');
    final vencimiento = fechaVencimientoIso ?? '$periodo-$diaLim';
    final generados = <CargoCuenta>[];

    for (var i = 0; i < hijosActivos.length; i++) {
      final hijo = hijosActivos[i];
      final existente = cargos.any(
        (c) =>
            c.alumnoId == hijo.id &&
            c.tipo == TipoCargo.mensualidad &&
            c.periodoOpcional == periodo &&
            c.estado != EstadoCargo.cancelado,
      );
      if (existente) {
        continue;
      }

      int pctDescuento = 0;
      if (i == 1) {
        pctDescuento = academia.descuentoSegundoHermanoPct;
      } else if (i >= 2) {
        pctDescuento = academia.descuentoTercerHermanoPct;
      }

      final subtotal = academia.mensualidadBaseCentavos;
      final descuento = (subtotal * pctDescuento) ~/ 100;
      final recargo =
          aplicarMoraInmediata ? academia.recargoMoraCentavos : 0;
      final total = math.max(0, subtotal - descuento + recargo);

      final etiquetaDescuento =
          pctDescuento > 0 ? ' (Desc. hermano $pctDescuento%)' : '';
      final cargo = CargoCuenta(
        id: _siguienteId('cargo'),
        academiaId: academia.id,
        tutorId: tutorId,
        alumnoId: hijo.id,
        tipo: TipoCargo.mensualidad,
        concepto: 'Mensualidad $periodo · ${hijo.nombre}$etiquetaDescuento',
        periodoOpcional: periodo,
        subtotalCentavos: subtotal,
        descuentoCentavos: descuento,
        recargoCentavos: recargo,
        totalCentavos: total,
        pagadoCentavos: 0,
        saldoCentavos: total,
        fechaVencimientoIso: vencimiento,
        estado: EstadoCargo.pendiente,
      );

      cargos.add(cargo);
      generados.add(cargo);
      _encolarOutbox(
        tipoOperacion: 'GENERAR_CARGO_MENSUALIDAD',
        entidadId: cargo.id,
        payload: cargo.toJson(),
      );
    }

    return generados;
  }

  /// Aplica el recargo por mora configurado en la academia a todas las
  /// mensualidades no liquidadas cuya `fechaVencimientoIso` sea anterior a
  /// [fechaCorteIso] (`YYYY-MM-DD`) y aún no tengan recargo aplicado.
  int aplicarRecargosMora({required String fechaCorteIso}) {
    var afectados = 0;
    for (var i = 0; i < cargos.length; i++) {
      final cargo = cargos[i];
      final tieneSaldo = cargo.estado == EstadoCargo.pendiente ||
          cargo.estado == EstadoCargo.abonadoParcial;
      if (cargo.tipo == TipoCargo.mensualidad &&
          tieneSaldo &&
          cargo.recargoCentavos == 0 &&
          cargo.fechaVencimientoIso.compareTo(fechaCorteIso) < 0) {
        final recargo = academia.recargoMoraCentavos;
        final nuevoTotal = cargo.totalCentavos + recargo;
        final nuevoSaldo = cargo.saldoCentavos + recargo;
        cargos[i] = cargo.copyWith(
          recargoCentavos: recargo,
          totalCentavos: nuevoTotal,
          saldoCentavos: nuevoSaldo,
        );
        afectados++;
        _encolarOutbox(
          tipoOperacion: 'APLICAR_RECARGO_MORA',
          entidadId: cargo.id,
          payload: cargos[i].toJson(),
        );
      }
    }
    return afectados;
  }

  CargoCuenta registrarCargo(CargoCuenta cargo) {
    final index = cargos.indexWhere((c) => c.id == cargo.id);
    if (index >= 0) {
      cargos[index] = cargo;
    } else {
      cargos.add(cargo);
    }
    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_CARGO',
      entidadId: cargo.id,
      payload: cargo.toJson(),
    );
    return cargo;
  }

  List<CargoCuenta> cargosPendientesTutor(String tutorId) {
    return cargos
        .where(
          (c) =>
              c.tutorId == tutorId &&
              (c.estado == EstadoCargo.pendiente ||
                  c.estado == EstadoCargo.abonadoParcial) &&
              c.saldoCentavos > 0,
        )
        .toList();
  }

  /// Registra un cobro total o abono parcial sobre uno o varios cargos,
  /// emitiendo un [TicketPago] inmutable con folio consecutivo de caja y
  /// código QR de verificación.
  ///
  /// Si un cargo liquidado corresponde a un [PedidoEquipo], actualiza
  /// automáticamente su estado a [EstadoEntregaEquipo.pagadoPendienteEntrega].
  TicketPago registrarCobro({
    required String tutorId,
    required Map<String, int> abonosPorCargoId,
    required MetodoPago metodoPago,
    String? referenciaPagoOpcional,
    String cajeroUsuarioId = 'recepcion-1',
    String? emitidoEnIso,
    bool sincronizadoNube = false,
  }) {
    validarReferenciaPagoSegura(referenciaPagoOpcional);
    if (abonosPorCargoId.isEmpty) {
      throw ArgumentError('Debe especificar al menos un cargo para cobrar.');
    }
    final tutor = obtenerTutorPorId(tutorId);
    if (tutor.academiaId != academia.id || tutor.bloqueadoArco) {
      throw StateError('Tutor inválido o bloqueado por ARCO.');
    }

    final fechaEmision = emitidoEnIso ?? '2026-11-23T18:15:00Z';
    final lineas = <LineaTicket>[];
    var sumaPagada = 0;

    // Primera pasada: validación de cargos y montos.
    for (final entry in abonosPorCargoId.entries) {
      final cargoId = entry.key;
      final montoAbono = entry.value;
      if (montoAbono <= 0) {
        throw ArgumentError.value(
          montoAbono,
          'abonosPorCargoId[$cargoId]',
          'El monto a abonar debe ser mayor a 0 centavos.',
        );
      }
      final cargo = cargos.firstWhere(
        (c) => c.id == cargoId,
        orElse: () => throw ArgumentError('Cargo no encontrado: $cargoId'),
      );
      if (cargo.tutorId != tutorId || cargo.academiaId != academia.id) {
        throw StateError('El cargo $cargoId no pertenece al tutor $tutorId.');
      }
      if (cargo.estado == EstadoCargo.pagado ||
          cargo.estado == EstadoCargo.cancelado) {
        throw StateError(
          'El cargo $cargoId ya está ${cargo.estado.name} y no admite abonos.',
        );
      }
      if (montoAbono > cargo.saldoCentavos) {
        throw ArgumentError(
          'El abono ($montoAbono) supera el saldo pendiente (${cargo.saldoCentavos}) del cargo $cargoId.',
        );
      }
    }

    // Segunda pasada: aplicación de abonos y actualización de pedidos de equipo.
    for (final entry in abonosPorCargoId.entries) {
      final cargoId = entry.key;
      final montoAbono = entry.value;
      final idxCargo = cargos.indexWhere((c) => c.id == cargoId);
      final cargo = cargos[idxCargo];

      final nuevoPagado = cargo.pagadoCentavos + montoAbono;
      final nuevoSaldo = cargo.saldoCentavos - montoAbono;
      final nuevoEstado = nuevoSaldo == 0
          ? EstadoCargo.pagado
          : EstadoCargo.abonadoParcial;

      final cargoActualizado = cargo.copyWith(
        pagadoCentavos: nuevoPagado,
        saldoCentavos: nuevoSaldo,
        estado: nuevoEstado,
      );
      cargos[idxCargo] = cargoActualizado;

      String nombreAlumno = 'Familia';
      if (cargo.alumnoId != null) {
        final al = alumnos.where((a) => a.id == cargo.alumnoId);
        if (al.isNotEmpty) {
          nombreAlumno = al.first.nombreCompleto;
        }
      }

      lineas.add(
        LineaTicket(
          cargoId: cargo.id,
          alumnoNombre: nombreAlumno,
          concepto: cargo.concepto,
          montoAbonadoCentavos: montoAbono,
          saldoRestanteCargoCentavos: nuevoSaldo,
        ),
      );
      sumaPagada += montoAbono;

      // Si el cargo quedó liquidado y corresponde a un PedidoEquipo,
      // transiciona automáticamente a pagadoPendienteEntrega.
      if (nuevoEstado == EstadoCargo.pagado) {
        for (var p = 0; p < pedidosEquipo.length; p++) {
          final pedido = pedidosEquipo[p];
          if ((pedido.cargoId == cargo.id ||
                  cargo.referenciaOrigenId == pedido.id) &&
              pedido.estadoEntrega == EstadoEntregaEquipo.pendientePago) {
            pedidosEquipo[p] = pedido.copyWith(
              estadoEntrega: EstadoEntregaEquipo.pagadoPendienteEntrega,
            );
          }
        }
      }
    }

    final anio = fechaEmision.length >= 4
        ? fechaEmision.substring(0, 4)
        : '2026';
    final consecutivo = (tickets.length + 1).toString().padLeft(5, '0');
    final folio = '${academia.prefijoCaja}-$anio-$consecutivo';
    final hashVerificacion = _calcularHashCorto(
      '${academia.id}|$folio|$sumaPagada|$fechaEmision',
    );
    final qrVerificacion =
        'dojang://verify/${academia.id}/$folio/$hashVerificacion';

    final ticket = TicketPago(
      id: _siguienteId('tkt'),
      folio: folio,
      academiaId: academia.id,
      tutorId: tutorId,
      emitidoEnIso: fechaEmision,
      metodoPago: metodoPago,
      referenciaPagoOpcional: referenciaPagoOpcional,
      lineas: lineas,
      totalPagadoCentavos: sumaPagada,
      cajeroUsuarioId: cajeroUsuarioId,
      cancelado: false,
      sincronizadoNube: sincronizadoNube,
      codigoVerificacionQr: qrVerificacion,
    );

    tickets.add(ticket);
    _encolarOutbox(
      tipoOperacion: 'EMITIR_TICKET_PAGO',
      entidadId: ticket.id,
      payload: ticket.toJson(),
      fechaIso: fechaEmision,
    );
    return ticket;
  }

  /// Verifica que un [codigoQr] de comprobante corresponda a un [TicketPago]
  /// existente en la academia, vigente (no cancelado) y cuyo hash criptográfico
  /// corto coincida con sus datos inmutables.
  bool verificarQrTicket(String codigoQr) {
    final limpio = codigoQr.trim();
    if (!limpio.startsWith('dojang://verify/')) {
      return false;
    }
    for (final ticket in tickets) {
      if (ticket.codigoVerificacionQr == limpio) {
        if (ticket.cancelado || ticket.academiaId != academia.id) {
          return false;
        }
        final hashEsperado = _calcularHashCorto(
          '${ticket.academiaId}|${ticket.folio}|${ticket.totalPagadoCentavos}|${ticket.emitidoEnIso}',
        );
        final qrEsperado =
            'dojang://verify/${ticket.academiaId}/${ticket.folio}/$hashEsperado';
        return limpio == qrEsperado;
      }
    }
    return false;
  }

  /// Cancela un ticket emitido generando evento de reverso auditable
  /// (D-10: un ticket nunca se borra de la lista, solo se marca cancelado con
  /// motivo obligatorio y folio de reverso, restaurando el saldo de los cargos).
  TicketPago cancelarTicket({
    required String ticketId,
    required String motivo,
    required String actorUsuarioId,
    RolUsuario rolActor = RolUsuario.dueno,
    String? canceladoEnIso,
  }) {
    if (rolActor != RolUsuario.dueno) {
      throw StateError(
        'Solo el rol Dueño puede autorizar la cancelación de un ticket emitido.',
      );
    }
    if (motivo.trim().isEmpty) {
      throw ArgumentError(
        'Es obligatorio especificar el motivo de cancelación del ticket.',
      );
    }
    final idxTicket = tickets.indexWhere((t) => t.id == ticketId);
    if (idxTicket < 0) {
      throw ArgumentError('Ticket no encontrado: $ticketId');
    }
    final ticketOriginal = tickets[idxTicket];
    if (ticketOriginal.cancelado) {
      throw StateError('El ticket ${ticketOriginal.folio} ya está cancelado.');
    }

    // Revertir los abonos aplicados en cada cargo del ticket.
    for (final linea in ticketOriginal.lineas) {
      final idxCargo = cargos.indexWhere((c) => c.id == linea.cargoId);
      if (idxCargo >= 0) {
        final cargo = cargos[idxCargo];
        final nuevoPagado =
            math.max(0, cargo.pagadoCentavos - linea.montoAbonadoCentavos);
        final nuevoSaldo = cargo.totalCentavos - nuevoPagado;
        final nuevoEstado = nuevoPagado == 0
            ? EstadoCargo.pendiente
            : EstadoCargo.abonadoParcial;
        cargos[idxCargo] = cargo.copyWith(
          pagadoCentavos: nuevoPagado,
          saldoCentavos: nuevoSaldo,
          estado: nuevoEstado,
        );

        // Si un pedido de equipo estaba pendiente de entrega pero su cargo
        // dejó de estar pagado, regresa a pendientePago.
        for (var p = 0; p < pedidosEquipo.length; p++) {
          final pedido = pedidosEquipo[p];
          if (pedido.cargoId == cargo.id &&
              pedido.estadoEntrega ==
                  EstadoEntregaEquipo.pagadoPendienteEntrega) {
            pedidosEquipo[p] = pedido.copyWith(
              estadoEntrega: EstadoEntregaEquipo.pendientePago,
            );
          }
        }
      }
    }

    final ticketCancelado = ticketOriginal.copyWith(
      cancelado: true,
      motivoCancelacionOpcional: motivo.trim(),
      folioReversoOpcional: 'REV-${ticketOriginal.folio}',
    );
    tickets[idxTicket] = ticketCancelado;

    _registrarBitacora(
      actorUsuarioId: actorUsuarioId,
      rolActor: rolActor,
      accion: 'CANCELACION_TICKET_PAGO',
      entidad: 'tickets_pago',
      registroId: ticketCancelado.id,
      detalle:
          'Cancelación de folio ${ticketCancelado.folio} (${ticketCancelado.folioReversoOpcional}): ${motivo.trim()}',
      fechaIso: canceladoEnIso,
    );
    _encolarOutbox(
      tipoOperacion: 'CANCELAR_TICKET_PAGO',
      entidadId: ticketCancelado.id,
      payload: ticketCancelado.toJson(),
      fechaIso: canceladoEnIso,
    );
    return ticketCancelado;
  }

  /// Calcula el corte de caja sumando únicamente los tickets vigentes
  /// (no cancelados), incluso si el expediente fue posteriormente disociado
  /// por cancelación ARCO.
  ResumenCorteCaja calcularCorteCaja({String? fechaDiaIso}) {
    var total = 0;
    var efectivo = 0;
    var transferencia = 0;
    var terminal = 0;
    var vigentes = 0;
    var cancelados = 0;
    final porTipo = <TipoCargo, int>{
      for (final tipo in TipoCargo.values) tipo: 0,
    };

    for (final ticket in tickets) {
      if (fechaDiaIso != null && !ticket.emitidoEnIso.startsWith(fechaDiaIso)) {
        continue;
      }
      if (ticket.cancelado) {
        cancelados++;
        continue;
      }
      vigentes++;
      total += ticket.totalPagadoCentavos;
      switch (ticket.metodoPago) {
        case MetodoPago.efectivo:
          efectivo += ticket.totalPagadoCentavos;
        case MetodoPago.transferencia:
          transferencia += ticket.totalPagadoCentavos;
        case MetodoPago.terminal:
          terminal += ticket.totalPagadoCentavos;
      }
      for (final linea in ticket.lineas) {
        final cargoMatch = cargos.where((c) => c.id == linea.cargoId);
        final tipo =
            cargoMatch.isNotEmpty ? cargoMatch.first.tipo : TipoCargo.otro;
        porTipo[tipo] = (porTipo[tipo] ?? 0) + linea.montoAbonadoCentavos;
      }
    }

    return ResumenCorteCaja(
      totalCobradoCentavos: total,
      totalEfectivoCentavos: efectivo,
      totalTransferenciaCentavos: transferencia,
      totalTerminalCentavos: terminal,
      ticketsVigentesCount: vigentes,
      ticketsCanceladosCount: cancelados,
      ingresosPorTipoCentavos: porTipo,
    );
  }

  /// Total de egresos operativos vigentes registrados en la academia.
  int get totalGastosVigentesCentavos => gastos
      .where((g) => !g.cancelado)
      .fold<int>(0, (acc, g) => acc + g.montoCentavos);

  /// Total de cuentas por cobrar (cargos pendientes o con abono parcial).
  int get saldoPorCobrarTotalCentavos => cargos
      .where(
        (c) =>
            (c.estado == EstadoCargo.pendiente ||
                c.estado == EstadoCargo.abonadoParcial) &&
            c.saldoCentavos > 0,
      )
      .fold<int>(0, (acc, c) => acc + c.saldoCentavos);

  /// Balance neto disponible en caja (`Ingresos vigentes − Gastos vigentes`).
  int get balanceNetoCentavos =>
      calcularCorteCaja().totalCobradoCentavos - totalGastosVigentesCentavos;

  /// Registra un gasto operativo del dojang validando rol (`dueno` o `recepcion`),
  /// montos positivos en centavos enteros y ausencia de PAN/CVV en la referencia.
  GastoAcademia registrarGasto({
    required String concepto,
    required CategoriaGasto categoria,
    required int montoCentavos,
    MetodoPago metodoPago = MetodoPago.efectivo,
    String fechaIso = '2026-11-24',
    String? referenciaOpcional,
    String actorUsuarioId = 'dueno-1',
    RolUsuario rolActor = RolUsuario.dueno,
  }) {
    if (rolActor != RolUsuario.dueno && rolActor != RolUsuario.recepcion) {
      throw StateError(
        'Solo los roles Dueño o Recepción pueden registrar gastos de la academia.',
      );
    }
    final gasto = GastoAcademia(
      id: _siguienteId('gasto'),
      academiaId: academia.id,
      concepto: concepto.trim(),
      categoria: categoria,
      montoCentavos: montoCentavos,
      metodoPago: metodoPago,
      fechaIso: fechaIso.trim(),
      referenciaOpcional:
          (referenciaOpcional != null && referenciaOpcional.trim().isNotEmpty)
              ? referenciaOpcional.trim()
              : null,
      registradoPorUsuarioId: actorUsuarioId,
    );
    gastos.add(gasto);
    _registrarBitacora(
      actorUsuarioId: actorUsuarioId,
      rolActor: rolActor,
      accion: 'REGISTRO_GASTO_OPERATIVO',
      entidad: 'gastos_academia',
      registroId: gasto.id,
      detalle:
          '${gasto.categoria.etiqueta}: ${gasto.concepto} (${formatearMxn(gasto.montoCentavos)})',
      fechaIso: '${gasto.fechaIso}T19:00:00Z',
    );
    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_GASTO',
      entidadId: gasto.id,
      payload: gasto.toJson(),
      fechaIso: '${gasto.fechaIso}T19:00:00Z',
    );
    return gasto;
  }

  /// Marca como sincronizados los eventos pendientes en [colaOutbox] y los
  /// tickets emitidos en modo offline.
  int marcarOutboxSincronizado() {
    var sincronizados = 0;
    for (var i = 0; i < colaOutbox.length; i++) {
      if (!colaOutbox[i].sincronizado) {
        colaOutbox[i] = colaOutbox[i].copyWith(sincronizado: true);
        sincronizados++;
      }
    }
    for (var i = 0; i < tickets.length; i++) {
      if (!tickets[i].sincronizadoNube) {
        tickets[i] = tickets[i].copyWith(sincronizadoNube: true);
      }
    }
    return sincronizados;
  }

  // ===========================================================================
  // M4 · GRADOS, ELEGIBILIDAD Y EXÁMENES INTERNOS
  // ===========================================================================

  /// Evalúa si un alumno cumple los 3 requisitos para ascender al siguiente
  /// grado en el escalafón: asistencias mínimas, meses mínimos en el grado
  /// actual y pagos de mensualidad al corriente.
  DictamenElegibilidad evaluarElegibilidadExamen(
    String alumnoId, {
    DateTime? fechaReferencia,
  }) {
    final alumno = obtenerAlumnoPorId(alumnoId);
    final gradoActual = obtenerGradoPorId(alumno.gradoActualId);
    final siguiente = obtenerSiguienteGrado(alumno.gradoActualId);
    final ref = fechaReferencia ?? DateTime.utc(2026, 11, 23);

    if (siguiente == null) {
      return DictamenElegibilidad(
        alumnoId: alumnoId,
        gradoActual: gradoActual,
        siguienteGrado: null,
        elegible: false,
        cumpleAsistencias: true,
        cumpleTiempoMeses: true,
        cumplePagosAlCorriente: true,
        asistenciasActuales: alumno.asistenciasEnGradoActual,
        asistenciasRequeridas: 0,
        mesesTranscurridos: 0,
        mesesRequeridos: 0,
        adeudoCentavos: 0,
        motivos: const <String>[
          'El alumno ya alcanzó el grado máximo configurado en la academia.',
        ],
      );
    }

    final fechaUltimo = DateTime.parse(alumno.fechaUltimoGradoIso);
    var mesesTranscurridos = (ref.year - fechaUltimo.year) * 12 +
        (ref.month - fechaUltimo.month);
    if (ref.day < fechaUltimo.day) {
      mesesTranscurridos--;
    }
    mesesTranscurridos = math.max(0, mesesTranscurridos);

    final cumpleAsistencias =
        alumno.asistenciasEnGradoActual >= siguiente.asistenciasMinimas;
    final cumpleTiempoMeses = mesesTranscurridos >= siguiente.mesesMinimos;

    final adeudoAlumnoCentavos = cargos
        .where(
          (c) =>
              c.alumnoId == alumno.id &&
              c.tipo == TipoCargo.mensualidad &&
              (c.estado == EstadoCargo.pendiente ||
                  c.estado == EstadoCargo.abonadoParcial),
        )
        .fold<int>(0, (suma, c) => suma + c.saldoCentavos);

    final cumplePagosAlCorriente = adeudoAlumnoCentavos == 0;
    final motivos = <String>[];

    if (!cumpleAsistencias) {
      final faltantes =
          siguiente.asistenciasMinimas - alumno.asistenciasEnGradoActual;
      motivos.add(
        'Faltan $faltantes asistencias (${alumno.asistenciasEnGradoActual}/${siguiente.asistenciasMinimas} requeridas para ${siguiente.codigo}).',
      );
    }
    if (!cumpleTiempoMeses) {
      motivos.add(
        'Tiempo insuficiente en cinta actual ($mesesTranscurridos/${siguiente.mesesMinimos} meses requeridos).',
      );
    }
    if (!cumplePagosAlCorriente) {
      motivos.add(
        'Presenta adeudo de mensualidad por ${formatearMxn(adeudoAlumnoCentavos)}.',
      );
    }

    return DictamenElegibilidad(
      alumnoId: alumnoId,
      gradoActual: gradoActual,
      siguienteGrado: siguiente,
      elegible:
          cumpleAsistencias && cumpleTiempoMeses && cumplePagosAlCorriente,
      cumpleAsistencias: cumpleAsistencias,
      cumpleTiempoMeses: cumpleTiempoMeses,
      cumplePagosAlCorriente: cumplePagosAlCorriente,
      asistenciasActuales: alumno.asistenciasEnGradoActual,
      asistenciasRequeridas: siguiente.asistenciasMinimas,
      mesesTranscurridos: mesesTranscurridos,
      mesesRequeridos: siguiente.mesesMinimos,
      adeudoCentavos: adeudoAlumnoCentavos,
      motivos: motivos,
    );
  }

  ConvocatoriaExamen crearConvocatoriaExamen(ConvocatoriaExamen convocatoria) {
    final index =
        convocatoriasExamen.indexWhere((c) => c.id == convocatoria.id);
    if (index >= 0) {
      convocatoriasExamen[index] = convocatoria;
    } else {
      convocatoriasExamen.add(convocatoria);
    }
    _encolarOutbox(
      tipoOperacion: 'CREAR_CONVOCATORIA_EXAMEN',
      entidadId: convocatoria.id,
      payload: convocatoria.toJson(),
    );
    return convocatoria;
  }

  /// Inscribe a un alumno a una [ConvocatoriaExamen] generando el cargo por
  /// derecho a examen del grado aspirado.
  InscripcionExamen inscribirAlumnoExamen({
    required String convocatoriaId,
    required String alumnoId,
    required bool consentimientoTutorAceptado,
    bool excepcionAutorizada = false,
    String? motivoExcepcionOpcional,
    DateTime? fechaReferencia,
    String actorUsuarioId = 'dueno-1',
    RolUsuario rolActor = RolUsuario.dueno,
  }) {
    if (!consentimientoTutorAceptado) {
      throw ViolacionPrivacidadException(
        'Se requiere autorización del padre o tutor para inscribir al alumno al examen de grado.',
      );
    }
    final convocatoria = convocatoriasExamen.firstWhere(
      (c) => c.id == convocatoriaId,
      orElse: () => throw ArgumentError(
        'Convocatoria de examen no encontrada: $convocatoriaId',
      ),
    );
    if (convocatoria.cerrada) {
      throw StateError('La convocatoria ${convocatoria.titulo} ya está cerrada.');
    }

    final alumno = obtenerAlumnoPorId(alumnoId);
    if (!alumno.activo || alumno.bloqueadoArco) {
      throw StateError('El alumno está inactivo o bloqueado por ARCO.');
    }
    if (inscripcionesExamen.any(
      (i) => i.convocatoriaId == convocatoriaId && i.alumnoId == alumnoId,
    )) {
      throw StateError(
        'El alumno $alumnoId ya está inscrito en la convocatoria $convocatoriaId.',
      );
    }

    final dictamen = evaluarElegibilidadExamen(
      alumnoId,
      fechaReferencia: fechaReferencia,
    );
    final siguienteGrado = dictamen.siguienteGrado;
    if (siguienteGrado == null) {
      throw StateError('El alumno no tiene un siguiente grado disponible.');
    }
    if (!dictamen.elegible && !excepcionAutorizada) {
      throw StateError(
        'El alumno no es elegible para examen: ${dictamen.motivos.join(" ")}',
      );
    }
    if (excepcionAutorizada) {
      if (rolActor != RolUsuario.dueno) {
        throw StateError(
          'Solo el rol Dueño puede autorizar una excepción de elegibilidad para examen.',
        );
      }
      if (motivoExcepcionOpcional == null ||
          motivoExcepcionOpcional.trim().isEmpty) {
        throw ArgumentError(
          'Cuando se autoriza una excepción de examen se debe indicar el motivo.',
        );
      }
    }

    final inscripcionId = _siguienteId('insc-ex');
    final cargo = CargoCuenta(
      id: _siguienteId('cargo'),
      academiaId: academia.id,
      tutorId: alumno.tutorId,
      alumnoId: alumno.id,
      tipo: TipoCargo.examenGrado,
      concepto:
          'Derecho a Examen ${siguienteGrado.codigo} (${siguienteGrado.nombre}) · ${alumno.nombre}',
      subtotalCentavos: siguienteGrado.costoExamenCentavos,
      totalCentavos: siguienteGrado.costoExamenCentavos,
      saldoCentavos: siguienteGrado.costoExamenCentavos,
      fechaVencimientoIso: convocatoria.fechaIso,
      referenciaOrigenId: inscripcionId,
      estado: EstadoCargo.pendiente,
    );
    cargos.add(cargo);

    final inscripcion = InscripcionExamen(
      id: inscripcionId,
      convocatoriaId: convocatoriaId,
      alumnoId: alumnoId,
      gradoActualId: alumno.gradoActualId,
      gradoAspiradoId: siguienteGrado.id,
      cargoId: cargo.id,
      excepcionAutorizada: excepcionAutorizada,
      motivoExcepcionOpcional: motivoExcepcionOpcional,
      consentimientoTutorAceptado: consentimientoTutorAceptado,
    );
    inscripcionesExamen.add(inscripcion);

    if (excepcionAutorizada) {
      _registrarBitacora(
        actorUsuarioId: actorUsuarioId,
        rolActor: rolActor,
        accion: 'EXCEPCION_ELEGIBILIDAD_EXAMEN',
        entidad: 'inscripciones_examen',
        registroId: inscripcion.id,
        detalle:
            'Excepción autorizada para alumno $alumnoId en convocatoria $convocatoriaId: ${motivoExcepcionOpcional!.trim()}',
      );
    }

    _encolarOutbox(
      tipoOperacion: 'INSCRIBIR_ALUMNO_EXAMEN',
      entidadId: inscripcion.id,
      payload: inscripcion.toJson(),
    );
    return inscripcion;
  }

  /// Registra la evaluación técnica de un alumno en examen. Si [evaluacion.aprobado]
  /// es `true`, promueve automáticamente al alumno a su nuevo grado, reinicia
  /// su contador de asistencias a 0 y agrega el registro a [historialGrados].
  InscripcionExamen registrarEvaluacionExamen({
    required String inscripcionExamenId,
    required EvaluacionExamen evaluacion,
    bool exigirPagoDerechoExamen = true,
  }) {
    final idxInsc =
        inscripcionesExamen.indexWhere((i) => i.id == inscripcionExamenId);
    if (idxInsc < 0) {
      throw ArgumentError(
        'Inscripción a examen no encontrada: $inscripcionExamenId',
      );
    }
    final inscripcion = inscripcionesExamen[idxInsc];
    final alumno = obtenerAlumnoPorId(inscripcion.alumnoId);
    if (!alumno.activo || alumno.bloqueadoArco) {
      throw StateError('El alumno está inactivo o bloqueado por ARCO.');
    }
    final cargo = cargos.firstWhere(
      (c) => c.id == inscripcion.cargoId,
      orElse: () =>
          throw StateError('Cargo de examen no encontrado: ${inscripcion.cargoId}'),
    );

    if (exigirPagoDerechoExamen && cargo.estado != EstadoCargo.pagado) {
      throw StateError(
        'No se puede evaluar ni promover al alumno mientras el derecho a examen tenga saldo pendiente.',
      );
    }

    final actualizada = inscripcion.copyWith(evaluacionOpcional: evaluacion);
    inscripcionesExamen[idxInsc] = actualizada;

    if (evaluacion.aprobado) {
      final idxAlumno =
          alumnos.indexWhere((a) => a.id == inscripcion.alumnoId);
      if (idxAlumno >= 0) {
        final alumnoActual = alumnos[idxAlumno];
        final fechaAscensoIso = evaluacion.evaluadoEnIso.length >= 10
            ? evaluacion.evaluadoEnIso.substring(0, 10)
            : evaluacion.evaluadoEnIso;

        alumnos[idxAlumno] = alumnoActual.copyWith(
          gradoActualId: inscripcion.gradoAspiradoId,
          fechaUltimoGradoIso: fechaAscensoIso,
          asistenciasEnGradoActual: 0,
        );

        final convocatoria = convocatoriasExamen.firstWhere(
          (c) => c.id == inscripcion.convocatoriaId,
          orElse: () => ConvocatoriaExamen(
            id: inscripcion.convocatoriaId,
            academiaId: academia.id,
            titulo: 'Examen de Grado',
            fechaIso: fechaAscensoIso,
            sinodal: 'Sinodal Oficial',
          ),
        );

        historialGrados.add(
          RegistroHistorialGrado(
            id: _siguienteId('hist-grado'),
            alumnoId: alumnoActual.id,
            gradoId: inscripcion.gradoAspiradoId,
            obtenidoEnIso: fechaAscensoIso,
            sinodal: convocatoria.sinodal,
            convocatoriaIdOpcional: convocatoria.id,
          ),
        );
      }
    }

    _encolarOutbox(
      tipoOperacion: 'EVALUAR_EXAMEN_GRADO',
      entidadId: actualizada.id,
      payload: actualizada.toJson(),
      fechaIso: evaluacion.evaluadoEnIso,
    );
    return actualizada;
  }

  // ===========================================================================
  // M5 · EQUIPO E INVENTARIO DEL DOJANG
  // ===========================================================================

  ProductoEquipo agregarProductoEquipo(ProductoEquipo producto) {
    final index = productosEquipo.indexWhere((p) => p.id == producto.id);
    if (index >= 0) {
      productosEquipo[index] = producto;
    } else {
      productosEquipo.add(producto);
    }
    _encolarOutbox(
      tipoOperacion: 'GUARDAR_PRODUCTO_EQUIPO',
      entidadId: producto.id,
      payload: producto.toJson(),
    );
    return producto;
  }

  /// Crea un pedido de uniforme/equipo, descuenta las existencias del
  /// inventario y genera el cargo vinculado en el estado de cuenta familiar.
  PedidoEquipo crearPedidoEquipo({
    required String alumnoId,
    required String productoId,
    int cantidad = 1,
    String? creadoEnIso,
  }) {
    if (cantidad <= 0) {
      throw ArgumentError.value(cantidad, 'cantidad', 'Debe ser >= 1.');
    }
    final alumno = obtenerAlumnoPorId(alumnoId);
    if (!alumno.activo || alumno.bloqueadoArco) {
      throw StateError('El alumno está inactivo o bloqueado por ARCO.');
    }
    final idxProd = productosEquipo.indexWhere((p) => p.id == productoId);
    if (idxProd < 0) {
      throw ArgumentError('Producto no encontrado: $productoId');
    }
    final producto = productosEquipo[idxProd];
    if (!producto.activo) {
      throw StateError('El artículo ${producto.nombre} no está activo.');
    }
    if (producto.existencias < cantidad) {
      throw StateError(
        'Existencias insuficientes para ${producto.nombre} (${producto.talla}). Disponible: ${producto.existencias}, solicitado: $cantidad.',
      );
    }

    productosEquipo[idxProd] = producto.copyWith(
      existencias: producto.existencias - cantidad,
    );

    final fechaPedido = creadoEnIso ?? '2026-11-23T18:10:00Z';
    final total = producto.precioCentavos * cantidad;
    final pedidoId = _siguienteId('ped-eq');
    final cargoId = _siguienteId('cargo');

    final cargo = CargoCuenta(
      id: cargoId,
      academiaId: academia.id,
      tutorId: alumno.tutorId,
      alumnoId: alumno.id,
      tipo: TipoCargo.equipo,
      concepto:
          '${producto.nombre} Talla ${producto.talla} x$cantidad · ${alumno.nombre}',
      subtotalCentavos: total,
      totalCentavos: total,
      saldoCentavos: total,
      fechaVencimientoIso: fechaPedido.substring(0, 10),
      referenciaOrigenId: pedidoId,
      estado: EstadoCargo.pendiente,
    );
    cargos.add(cargo);

    final pedido = PedidoEquipo(
      id: pedidoId,
      academiaId: academia.id,
      alumnoId: alumno.id,
      tutorId: alumno.tutorId,
      productoId: producto.id,
      nombreProductoSnapshot: producto.nombre,
      tallaSnapshot: producto.talla,
      cantidad: cantidad,
      precioUnitarioCentavos: producto.precioCentavos,
      totalCentavos: total,
      cargoId: cargo.id,
      estadoEntrega: EstadoEntregaEquipo.pendientePago,
      creadoEnIso: fechaPedido,
    );
    pedidosEquipo.add(pedido);

    _encolarOutbox(
      tipoOperacion: 'CREAR_PEDIDO_EQUIPO',
      entidadId: pedido.id,
      payload: pedido.toJson(),
      fechaIso: fechaPedido,
    );
    return pedido;
  }

  /// Marca un [PedidoEquipo] como entregado físicamente en mostrador.
  ///
  /// Regla estricta: solo puede entregarse si su estado es
  /// [EstadoEntregaEquipo.pagadoPendienteEntrega] y el cargo está 100% pagado.
  PedidoEquipo entregarPedidoEquipo({
    required String pedidoId,
    String? entregadoEnIso,
  }) {
    final idxPedido = pedidosEquipo.indexWhere((p) => p.id == pedidoId);
    if (idxPedido < 0) {
      throw ArgumentError('Pedido de equipo no encontrado: $pedidoId');
    }
    final pedido = pedidosEquipo[idxPedido];
    if (pedido.estadoEntrega == EstadoEntregaEquipo.entregado) {
      throw StateError('El pedido $pedidoId ya fue entregado anteriormente.');
    }

    final cargo = cargos.firstWhere(
      (c) => c.id == pedido.cargoId,
      orElse: () =>
          throw StateError('Cargo vinculado no encontrado: ${pedido.cargoId}'),
    );

    if (!cargo.estaLiquidado ||
        pedido.estadoEntrega != EstadoEntregaEquipo.pagadoPendienteEntrega) {
      throw StateError(
        'No se puede entregar el artículo ${pedido.nombreProductoSnapshot} porque presenta un saldo pendiente de ${formatearMxn(cargo.saldoCentavos)}.',
      );
    }

    final fechaEntrega = entregadoEnIso ?? '2026-11-23T18:30:00Z';
    final entregado = pedido.copyWith(
      estadoEntrega: EstadoEntregaEquipo.entregado,
      entregadoEnIsoOpcional: fechaEntrega,
    );
    pedidosEquipo[idxPedido] = entregado;

    _encolarOutbox(
      tipoOperacion: 'ENTREGAR_PEDIDO_EQUIPO',
      entidadId: entregado.id,
      payload: entregado.toJson(),
      fechaIso: fechaEntrega,
    );
    return entregado;
  }

  // ===========================================================================
  // M6 · TORNEOS, RESPONSIVAS DIGITALES E INTEROPERABILIDAD CUPA (D-12)
  // ===========================================================================

  Torneo crearTorneo(Torneo torneo) {
    final index = torneos.indexWhere((t) => t.id == torneo.id);
    if (index >= 0) {
      torneos[index] = torneo;
    } else {
      torneos.add(torneo);
    }
    _encolarOutbox(
      tipoOperacion: 'CREAR_TORNEO',
      entidadId: torneo.id,
      payload: torneo.toJson(),
    );
    return torneo;
  }

  /// Inscribe a un alumno a un [Torneo] exigiendo la aceptación digital de la
  /// carta responsiva del padre/tutor y generando el cargo en caja.
  InscripcionTorneo inscribirAlumnoTorneo({
    required String torneoId,
    required String alumnoId,
    required ModalidadTorneo modalidad,
    required double pesoKgRegistrado,
    required String categoriaDivision,
    required bool responsivaTutorAceptada,
    String? responsivaAceptadaEnIso,
  }) {
    if (!responsivaTutorAceptada) {
      throw ViolacionPrivacidadException(
        'Es obligatoria la aceptación digital de la carta responsiva del padre o tutor para inscribir al alumno al torneo.',
      );
    }
    if (pesoKgRegistrado.isNaN || pesoKgRegistrado <= 0) {
      throw ArgumentError('El peso debe ser mayor a 0.');
    }
    final torneo = torneos.firstWhere(
      (t) => t.id == torneoId,
      orElse: () => throw ArgumentError('Torneo no encontrado: $torneoId'),
    );
    if (!torneo.abierto) {
      throw StateError(
        'Las inscripciones para el torneo ${torneo.nombre} están cerradas.',
      );
    }

    final idxAlumno = alumnos.indexWhere((a) => a.id == alumnoId);
    if (idxAlumno < 0) {
      throw ArgumentError('Alumno no encontrado: $alumnoId');
    }
    final alumno = alumnos[idxAlumno];
    if (!alumno.activo || alumno.bloqueadoArco) {
      throw StateError('El alumno está inactivo o bloqueado por ARCO.');
    }
    if (inscripcionesTorneo.any(
      (i) => i.torneoId == torneoId && i.alumnoId == alumnoId,
    )) {
      throw StateError(
        'El alumno $alumnoId ya está inscrito en el torneo $torneoId.',
      );
    }

    final fechaResp = responsivaAceptadaEnIso ?? '2026-11-23T18:20:00Z';
    final inscripcionId = _siguienteId('insc-tor');
    final cargoId = _siguienteId('cargo');
    final inscripcion = InscripcionTorneo(
      id: inscripcionId,
      torneoId: torneoId,
      alumnoId: alumno.id,
      tutorId: alumno.tutorId,
      modalidad: modalidad,
      pesoKgRegistrado: pesoKgRegistrado,
      gradoIdAlInscribir: alumno.gradoActualId,
      categoriaDivision: categoriaDivision,
      responsivaTutorAceptada: responsivaTutorAceptada,
      responsivaAceptadaEnIso: fechaResp,
      cargoId: cargoId,
      medalla: MedallaTorneo.ninguna,
      notasResultado: '',
    );
    final cargo = CargoCuenta(
      id: cargoId,
      academiaId: academia.id,
      tutorId: alumno.tutorId,
      alumnoId: alumno.id,
      tipo: TipoCargo.torneo,
      concepto: 'Inscripción ${torneo.nombre} · ${alumno.nombre}',
      subtotalCentavos: torneo.cuotaCentavos,
      totalCentavos: torneo.cuotaCentavos,
      saldoCentavos: torneo.cuotaCentavos,
      fechaVencimientoIso: torneo.fechaLimiteInscripcionIso,
      referenciaOrigenId: inscripcionId,
      estado: EstadoCargo.pendiente,
    );

    alumnos[idxAlumno] = alumno.copyWith(pesoKgOpcional: pesoKgRegistrado);
    cargos.add(cargo);
    inscripcionesTorneo.add(inscripcion);

    _encolarOutbox(
      tipoOperacion: 'INSCRIBIR_ALUMNO_TORNEO',
      entidadId: inscripcion.id,
      payload: inscripcion.toJson(),
      fechaIso: fechaResp,
    );
    return inscripcion;
  }

  InscripcionTorneo registrarMedallaTorneo({
    required String inscripcionTorneoId,
    required MedallaTorneo medalla,
    String notasResultado = '',
  }) {
    final idx =
        inscripcionesTorneo.indexWhere((i) => i.id == inscripcionTorneoId);
    if (idx < 0) {
      throw ArgumentError(
        'Inscripción a torneo no encontrada: $inscripcionTorneoId',
      );
    }
    final actualizada = inscripcionesTorneo[idx].copyWith(
      medalla: medalla,
      notasResultado: notasResultado,
    );
    inscripcionesTorneo[idx] = actualizada;
    _encolarOutbox(
      tipoOperacion: 'REGISTRAR_MEDALLA_TORNEO',
      entidadId: actualizada.id,
      payload: actualizada.toJson(),
    );
    return actualizada;
  }

  List<Map<String, dynamic>> _competidoresConfirmadosCupa(String torneoId) {
    final resultado = <Map<String, dynamic>>[];
    for (final insc in inscripcionesTorneo) {
      if (insc.torneoId != torneoId || !insc.responsivaTutorAceptada) {
        continue;
      }
      final cargoMatch = cargos.where((c) => c.id == insc.cargoId);
      if (cargoMatch.isEmpty || !cargoMatch.first.estaLiquidado) {
        continue;
      }
      final alumnoMatch = alumnos.where(
        (a) => a.id == insc.alumnoId && !a.bloqueadoArco,
      );
      if (alumnoMatch.isEmpty) {
        continue;
      }
      final alumno = alumnoMatch.first;
      final grado = obtenerGradoPorId(insc.gradoIdAlInscribir);

      resultado.add(<String, dynamic>{
        'inscripcion_id': insc.id,
        'alumno_id': alumno.id,
        'nombre_display': alumno.nombreCompleto,
        'club': academia.nombre,
        'rama': alumno.sexoRama.name,
        'fecha_nacimiento': alumno.fechaNacimientoIso,
        'peso_kg': insc.pesoKgRegistrado,
        'codigo_grado': grado.codigo,
        'grado_cinta': grado.nombre,
        'modalidad': insc.modalidad.name,
        'categoria_division': insc.categoriaDivision,
      });
    }
    return resultado;
  }

  /// Exporta en JSON estándar (`cupa-torneo-roster-v1`, D-12) únicamente a los
  /// competidores inscritos al [torneoId] que tienen **responsiva del tutor
  /// aceptada** y **cuota 100% pagada**.
  String exportarInscritosTorneoCupaJson(String torneoId) {
    final torneo = torneos.firstWhere(
      (t) => t.id == torneoId,
      orElse: () => throw ArgumentError('Torneo no encontrado: $torneoId'),
    );
    final competidores = _competidoresConfirmadosCupa(torneoId);
    final payload = <String, dynamic>{
      'formato': 'cupa-torneo-roster-v1',
      'academia_id': academia.id,
      'academia_nombre': academia.nombre,
      'torneo_id': torneo.id,
      'torneo_nombre': torneo.nombre,
      'fecha_evento': torneo.fechaEventoIso,
      'total_competidores': competidores.length,
      'competidores': competidores,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exporta en CSV estándar (D-12) únicamente a los competidores inscritos al
  /// [torneoId] con responsiva del tutor aceptada y cuota pagada.
  String exportarInscritosTorneoCupaCsv(String torneoId) {
    torneos.firstWhere(
      (t) => t.id == torneoId,
      orElse: () => throw ArgumentError('Torneo no encontrado: $torneoId'),
    );
    final competidores = _competidoresConfirmadosCupa(torneoId);
    final buffer = StringBuffer();
    buffer.writeln(
      'alumno_id,nombre_display,club,rama,fecha_nacimiento,peso_kg,codigo_grado,grado_cinta,modalidad,categoria_division',
    );
    for (final c in competidores) {
      buffer.writeln(
        '${_escaparCsv(c['alumno_id'].toString())},'
        '${_escaparCsv(c['nombre_display'].toString())},'
        '${_escaparCsv(c['club'].toString())},'
        '${_escaparCsv(c['rama'].toString())},'
        '${_escaparCsv(c['fecha_nacimiento'].toString())},'
        '${c['peso_kg']},'
        '${_escaparCsv(c['codigo_grado'].toString())},'
        '${_escaparCsv(c['grado_cinta'].toString())},'
        '${_escaparCsv(c['modalidad'].toString())},'
        '${_escaparCsv(c['categoria_division'].toString())}',
      );
    }
    return buffer.toString().trimRight();
  }

  // ===========================================================================
  // DERECHOS ARCO (LFPDPPP 2025 · ACCESO, PORTABILIDAD Y CANCELACIÓN)
  // ===========================================================================

  /// Derecho de Acceso y Portabilidad ARCO: exporta el expediente íntegro de
  /// una familia ([tutorId]) en formato JSON estructurado y deja rastro en la
  /// bitácora de auditoría.
  String exportarExpedienteArcoJson(
    String tutorId, {
    String ejecutadoPorId = 'dueno-1',
    RolUsuario rolEjecutor = RolUsuario.dueno,
    String? fechaIso,
  }) {
    final permitido = rolEjecutor == RolUsuario.dueno ||
        (rolEjecutor == RolUsuario.tutor && ejecutadoPorId == tutorId);
    if (!permitido) {
      throw StateError(
        'Solo el rol Dueño o el propio Tutor titular pueden exportar el expediente ARCO.',
      );
    }
    final tutor = obtenerTutorPorId(tutorId);
    final hijos = alumnos.where((a) => a.tutorId == tutorId).toList();
    final idsHijos = hijos.map((h) => h.id).toSet();

    final asistenciasFamilia =
        asistencias.where((a) => idsHijos.contains(a.alumnoId)).toList();
    final historialFamilia =
        historialGrados.where((h) => idsHijos.contains(h.alumnoId)).toList();
    final examenesFamilia =
        inscripcionesExamen.where((e) => idsHijos.contains(e.alumnoId)).toList();
    final pedidosFamilia =
        pedidosEquipo.where((p) => idsHijos.contains(p.alumnoId)).toList();
    final torneosFamilia =
        inscripcionesTorneo.where((t) => idsHijos.contains(t.alumnoId)).toList();
    final cargosFamilia =
        cargos.where((c) => c.tutorId == tutorId || idsHijos.contains(c.alumnoId)).toList();
    final ticketsFamilia =
        tickets.where((t) => t.tutorId == tutorId).toList();

    _registrarBitacora(
      actorUsuarioId: ejecutadoPorId,
      rolActor: rolEjecutor,
      accion: 'EXPORTACION_EXPEDIENTE_ARCO',
      entidad: 'tutores',
      registroId: tutorId,
      detalle:
          'Exportación ARCO de tutor ${tutor.id} con ${hijos.length} alumno(s) vinculado(s).',
      fechaIso: fechaIso,
    );
    _encolarOutbox(
      tipoOperacion: 'EXPORTAR_EXPEDIENTE_ARCO',
      entidadId: tutorId,
      payload: <String, dynamic>{
        'tutorId': tutorId,
        'ejecutadoPorId': ejecutadoPorId,
        'rolEjecutor': rolEjecutor.name,
      },
      fechaIso: fechaIso,
    );

    final expediente = <String, dynamic>{
      'marco_legal': 'LFPDPPP 2025 · Derecho de Acceso y Portabilidad ARCO',
      'academia_responsable': academia.nombre,
      'exportado_en_iso': fechaIso ?? '2026-11-23T19:00:00Z',
      'tutor': tutor.toJson(),
      'alumnos': hijos.map((h) => h.toJson()).toList(),
      'asistencias': asistenciasFamilia.map((a) => a.toJson()).toList(),
      'historial_grados': historialFamilia.map((h) => h.toJson()).toList(),
      'examenes': examenesFamilia.map((e) => e.toJson()).toList(),
      'pedidos_equipo': pedidosFamilia.map((p) => p.toJson()).toList(),
      'torneos': torneosFamilia.map((t) => t.toJson()).toList(),
      'cargos_cuenta': cargosFamilia.map((c) => c.toJson()).toList(),
      'tickets_pago': ticketsFamilia.map((t) => t.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(expediente);
  }

  /// Derecho de Cancelación ARCO:
  /// 1. Purga datos sensibles de salud (`tipoSangreOpcional`, `alergiasCuidadosOpcional`)
  ///    y contacto de emergencia.
  /// 2. Bloquea el expediente (`bloqueadoArco = true`, `activo = false`) y
  ///    anonimiza nombres identificables.
  /// 3. Disocia los folios contables históricos (`CargoCuenta` y `TicketPago`)
  ///    reemplazando referencias personales por `'ANONIMIZADO-ARCO'` sin alterar
  ///    la suma del corte de caja (`totalPagadoCentavos`).
  void ejecutarBajaArcoTutorOAlumno({
    String? alumnoId,
    String? tutorId,
    required String ejecutadoPorId,
    RolUsuario rolEjecutor = RolUsuario.dueno,
    String? ejecutadoEnIso,
  }) {
    if (rolEjecutor != RolUsuario.dueno) {
      throw StateError(
        'Solo el rol Dueño puede ejecutar una baja y cancelación ARCO.',
      );
    }
    if (alumnoId == null && tutorId == null) {
      throw ArgumentError(
        'Debe proporcionar alumnoId o tutorId para ejecutar la baja ARCO.',
      );
    }

    final idsAlumnosAfectados = <String>{};
    if (alumnoId != null) {
      idsAlumnosAfectados.add(alumnoId);
    }
    if (tutorId != null) {
      for (final al in alumnos.where((a) => a.tutorId == tutorId)) {
        idsAlumnosAfectados.add(al.id);
      }
    }

    final nombresOriginalesAlumnos = <String>{};
    for (var i = 0; i < alumnos.length; i++) {
      final actual = alumnos[i];
      if (idsAlumnosAfectados.contains(actual.id)) {
        nombresOriginalesAlumnos.add(actual.nombreCompleto);
        alumnos[i] = actual.copyWith(
          nombre: 'REGISTRO CANCELADO',
          apellidos: 'ARCO',
          activo: false,
          bloqueadoArco: true,
          limpiarPeso: true,
          limpiarTipoSangre: true,
          limpiarAlergias: true,
          limpiarTelefonoEmergencia: true,
        );
      }
    }

    // Disociación de cargos históricos o cancelación de saldos futuros.
    for (var i = 0; i < cargos.length; i++) {
      final cargo = cargos[i];
      final afectaAlumno =
          cargo.alumnoId != null && idsAlumnosAfectados.contains(cargo.alumnoId);
      final afectaTutor = tutorId != null && cargo.tutorId == tutorId;
      if (afectaAlumno || afectaTutor) {
        final esAbonoParcial =
            cargo.pagadoCentavos > 0 && cargo.saldoCentavos > 0;
        cargos[i] = cargo.copyWith(
          tutorId: tutorId != null ? 'ANONIMIZADO-ARCO' : cargo.tutorId,
          limpiarAlumnoId: afectaAlumno,
          concepto: 'CONCEPTO DISOCIADO ARCO #${cargo.id}',
          totalCentavos:
              esAbonoParcial ? cargo.pagadoCentavos : cargo.totalCentavos,
          saldoCentavos: 0,
          estado: cargo.pagadoCentavos == 0
              ? EstadoCargo.cancelado
              : EstadoCargo.pagado,
        );
      }
    }

    // Saneamiento de payloads previos en colaOutbox para alumnos/tutor dados de baja ARCO.
    for (var i = 0; i < colaOutbox.length; i++) {
      final ev = colaOutbox[i];
      final afectaAlumnoOutbox = idsAlumnosAfectados.contains(ev.entidadId) ||
          idsAlumnosAfectados.contains(ev.payload['id']) ||
          idsAlumnosAfectados.contains(ev.payload['alumnoId']);
      final afectaTutorOutbox = tutorId != null &&
          (ev.entidadId == tutorId ||
              ev.payload['id'] == tutorId ||
              ev.payload['tutorId'] == tutorId);
      if (afectaAlumnoOutbox || afectaTutorOutbox) {
        final nuevoPayload = Map<String, dynamic>.from(ev.payload);
        if (afectaAlumnoOutbox) {
          if (nuevoPayload.containsKey('tipoSangreOpcional')) {
            nuevoPayload['tipoSangreOpcional'] = null;
          }
          if (nuevoPayload.containsKey('alergiasCuidadosOpcional')) {
            nuevoPayload['alergiasCuidadosOpcional'] = null;
          }
          if (nuevoPayload.containsKey('telefonoEmergenciaOpcional')) {
            nuevoPayload['telefonoEmergenciaOpcional'] = null;
          }
          if (nuevoPayload.containsKey('pesoKgOpcional')) {
            nuevoPayload['pesoKgOpcional'] = null;
          }
          if (nuevoPayload.containsKey('nombre')) {
            nuevoPayload['nombre'] = 'REGISTRO CANCELADO ARCO';
          }
          if (nuevoPayload.containsKey('apellidos')) {
            nuevoPayload['apellidos'] = 'ARCO';
          }
        }
        if (afectaTutorOutbox) {
          if (nuevoPayload.containsKey('nombreCompleto')) {
            nuevoPayload['nombreCompleto'] = 'TUTOR CANCELADO ARCO';
          }
          if (nuevoPayload.containsKey('telefonoWhatsapp')) {
            nuevoPayload['telefonoWhatsapp'] = '0000000000';
          }
          if (nuevoPayload.containsKey('correo')) {
            nuevoPayload['correo'] = 'cancelado.arco@anonimo.local';
          }
        }
        colaOutbox[i] = EventoOutbox(
          id: ev.id,
          academiaId: ev.academiaId,
          tipoOperacion: ev.tipoOperacion,
          entidadId: ev.entidadId,
          creadoEnIso: ev.creadoEnIso,
          payload: nuevoPayload,
          sincronizado: ev.sincronizado,
        );
      }
    }

    // Disociación irreversible de folios de tickets conservando intactos los montos.
    final idsCargosAlumnos = cargos
        .where((c) => c.concepto.startsWith('CONCEPTO DISOCIADO ARCO'))
        .map((c) => c.id)
        .toSet();

    for (var i = 0; i < tickets.length; i++) {
      final ticket = tickets[i];
      final afectaTutor = tutorId != null && ticket.tutorId == tutorId;
      final afectaLinea = ticket.lineas.any(
        (l) =>
            idsCargosAlumnos.contains(l.cargoId) ||
            nombresOriginalesAlumnos.contains(l.alumnoNombre),
      );
      if (afectaTutor || afectaLinea) {
        final lineasAnonimizadas = ticket.lineas.map((l) {
          if (afectaTutor ||
              idsCargosAlumnos.contains(l.cargoId) ||
              nombresOriginalesAlumnos.contains(l.alumnoNombre)) {
            return l.copyWith(
              alumnoNombre: 'REGISTRO CANCELADO ARCO #${ticket.folio}',
            );
          }
          return l;
        }).toList();

        tickets[i] = ticket.copyWith(
          tutorId: afectaTutor ? 'ANONIMIZADO-ARCO' : ticket.tutorId,
          lineas: lineasAnonimizadas,
        );
      }
    }

    if (tutorId != null) {
      final idxTutor = tutores.indexWhere((t) => t.id == tutorId);
      if (idxTutor >= 0) {
        tutores[idxTutor] = tutores[idxTutor].copyWith(
          nombreCompleto: 'TUTOR CANCELADO ARCO',
          telefonoWhatsapp: '0000000000',
          correo: 'cancelado.arco@anonimo.local',
          bloqueadoArco: true,
          consentimiento: tutores[idxTutor].consentimiento.copyWith(
                consentimientoSaludExpreso: false,
                consentimientoFotoInterna: false,
                consentimientoPromociones: false,
              ),
        );
      }
    }

    final registroObjetivo = tutorId ?? alumnoId!;
    _registrarBitacora(
      actorUsuarioId: ejecutadoPorId,
      rolActor: rolEjecutor,
      accion: 'BAJA_CANCELACION_ARCO',
      entidad: tutorId != null ? 'tutores' : 'alumnos',
      registroId: registroObjetivo,
      detalle:
          'Bloqueo ARCO, purga de datos médicos y disociación contable sin alterar suma de caja.',
      fechaIso: ejecutadoEnIso,
    );
    _encolarOutbox(
      tipoOperacion: 'EJECUTAR_BAJA_ARCO',
      entidadId: registroObjetivo,
      payload: <String, dynamic>{
        'alumnoId': alumnoId,
        'tutorId': tutorId,
        'ejecutadoPorId': ejecutadoPorId,
      },
      fechaIso: ejecutadoEnIso,
    );
  }

  // ===========================================================================
  // DATOS SEMILLA DEMO (`MotorDoyang.demo()`) Y SERIALIZACIÓN JSON
  // ===========================================================================

  /// Crea una instancia preconfigurada con datos realistas para demostración,
  /// pruebas manuales y arranque offline ("Doyang Leones TKD").
  factory MotorDoyang.demo() {
    final academia = AcademiaConfig(
      id: 'acad-leones-tkd',
      nombre: 'Doyang Leones TKD',
      lema: 'Disciplina, Honor y Perseverancia',
      telefono: '55 4123 8910',
      direccion: 'Av. Universidad 1420, Col. Del Valle, CDMX',
      rfcOpcional: 'DLT210415AB9',
      colorPrimarioHex: '#1644AD',
      prefijoCaja: 'CAJA1',
      diaLimitePago: 5,
      mensualidadBaseCentavos: 80000,
      inscripcionCentavos: 60000,
      recargoMoraCentavos: 8000,
      descuentoSegundoHermanoPct: 10,
      descuentoTercerHermanoPct: 20,
      leyendaTicket:
          'Comprobante interno de control escolar — Este documento no es un comprobante fiscal CFDI.',
    );

    final grados = EscalafonGrados.taekwondoWtMexico();

    final tutorHernandez = TutorFamilia(
      id: 'tutor-laura',
      academiaId: academia.id,
      nombreCompleto: 'Laura López de Hernández',
      telefonoWhatsapp: '5541238910',
      correo: 'laura.lopez@familia.mx',
      parentesco: 'Madre',
      consentimiento: const ConsentimientoTutor(
        tutorId: 'tutor-laura',
        declaracionPatriaPotestad: true,
        aceptoAvisoIntegral: true,
        consentimientoSaludExpreso: true,
        consentimientoFotoInterna: true,
        consentimientoPromociones: false,
        versionAviso: 'v2026.1-LFPDPPP',
        registradoEnIso: '2026-01-10T17:00:00Z',
      ),
    );

    final tutorRamirez = TutorFamilia(
      id: 'tutor-carlos',
      academiaId: academia.id,
      nombreCompleto: 'Roberto Ramírez Soto',
      telefonoWhatsapp: '5587654321',
      correo: 'roberto.ramirez@familia.mx',
      parentesco: 'Padre',
      consentimiento: const ConsentimientoTutor(
        tutorId: 'tutor-carlos',
        declaracionPatriaPotestad: true,
        aceptoAvisoIntegral: true,
        consentimientoSaludExpreso: true,
        consentimientoFotoInterna: true,
        consentimientoPromociones: true,
        versionAviso: 'v2026.1-LFPDPPP',
        registradoEnIso: '2026-02-01T18:00:00Z',
      ),
    );

    // Hermano 1: Mateo en Cinta Verde (6.º Kup), elegible para examen a 5.º Kup
    // (requiere 24 asistencias y 3 meses, y pagos al corriente).
    final mateo = Alumno(
      id: 'alumno-mateo',
      academiaId: academia.id,
      tutorId: tutorHernandez.id,
      nombre: 'Mateo',
      apellidos: 'Hernández López',
      fechaNacimientoIso: '2015-04-12',
      sexoRama: SexoRama.varonil,
      pesoKgOpcional: 36.5,
      gradoActualId: 'grado-6-kup',
      fechaUltimoGradoIso: '2026-06-15',
      asistenciasEnGradoActual: 25,
      horarioGrupo: 'Infantil Avanzados L-M-V 18:00',
      activo: true,
      bloqueadoArco: false,
      tipoSangreOpcional: 'O+',
      alergiasCuidadosOpcional: null,
      telefonoEmergenciaOpcional: '5541238910',
      codigoQr: 'DOYANG-QR-MATEO-001',
    );

    // Hermana 2: Sofía en Cinta Amarilla (8.º Kup).
    final sofia = Alumno(
      id: 'alumno-sofia',
      academiaId: academia.id,
      tutorId: tutorHernandez.id,
      nombre: 'Sofía',
      apellidos: 'Hernández López',
      fechaNacimientoIso: '2018-09-03',
      sexoRama: SexoRama.femenil,
      pesoKgOpcional: 26.0,
      gradoActualId: 'grado-8-kup',
      fechaUltimoGradoIso: '2026-09-10',
      asistenciasEnGradoActual: 18,
      horarioGrupo: 'Infantil Principiantes M-J 17:00',
      activo: true,
      bloqueadoArco: false,
      tipoSangreOpcional: 'O+',
      alergiasCuidadosOpcional: null,
      telefonoEmergenciaOpcional: '5541238910',
      codigoQr: 'DOYANG-QR-SOFIA-002',
    );

    // Tercer alumno con otro tutor: Diego Ramírez en Cinta Azul (4.º Kup).
    final diego = Alumno(
      id: 'alumno-diego',
      academiaId: academia.id,
      tutorId: tutorRamirez.id,
      nombre: 'Diego',
      apellidos: 'Ramírez Vega',
      fechaNacimientoIso: '2013-11-20',
      sexoRama: SexoRama.varonil,
      pesoKgOpcional: 44.0,
      gradoActualId: 'grado-4-kup',
      fechaUltimoGradoIso: '2026-05-10',
      asistenciasEnGradoActual: 27,
      horarioGrupo: 'Cadetes Competidores L-M-V 19:00',
      activo: true,
      bloqueadoArco: false,
      tipoSangreOpcional: 'A+',
      alergiasCuidadosOpcional: 'Alergia a penicilina',
      telefonoEmergenciaOpcional: '5587654321',
      codigoQr: 'DOYANG-QR-DIEGO-003',
    );

    // Cargos de mensualidad con descuento de hermanos:
    // Mensualidad de Mateo ($800.00 MXN) ya pagada en el ticket CAJA1-2026-00001
    // para que Mateo esté 100% al corriente y elegible para examen.
    final cargoMateo = CargoCuenta(
      id: 'cargo-mens-mateo-2026-11',
      academiaId: academia.id,
      tutorId: tutorHernandez.id,
      alumnoId: mateo.id,
      tipo: TipoCargo.mensualidad,
      concepto: 'Mensualidad 2026-11 · Mateo',
      periodoOpcional: '2026-11',
      subtotalCentavos: 80000,
      descuentoCentavos: 0,
      recargoCentavos: 0,
      totalCentavos: 80000,
      pagadoCentavos: 80000,
      saldoCentavos: 0,
      fechaVencimientoIso: '2026-11-05',
      estado: EstadoCargo.pagado,
    );

    // Mensualidad de Sofía con 10% de descuento de 2.º hermano ($720.00 MXN), pendiente.
    final cargoSofia = CargoCuenta(
      id: 'cargo-mens-sofia-2026-11',
      academiaId: academia.id,
      tutorId: tutorHernandez.id,
      alumnoId: sofia.id,
      tipo: TipoCargo.mensualidad,
      concepto: 'Mensualidad 2026-11 · Sofía (Desc. hermano 10%)',
      periodoOpcional: '2026-11',
      subtotalCentavos: 80000,
      descuentoCentavos: 8000,
      recargoCentavos: 0,
      totalCentavos: 72000,
      pagadoCentavos: 0,
      saldoCentavos: 72000,
      fechaVencimientoIso: '2026-11-05',
      estado: EstadoCargo.pendiente,
    );

    final cargoDiego = CargoCuenta(
      id: 'cargo-mens-diego-2026-11',
      academiaId: academia.id,
      tutorId: tutorRamirez.id,
      alumnoId: diego.id,
      tipo: TipoCargo.mensualidad,
      concepto: 'Mensualidad 2026-11 · Diego',
      periodoOpcional: '2026-11',
      subtotalCentavos: 80000,
      descuentoCentavos: 0,
      recargoCentavos: 0,
      totalCentavos: 80000,
      pagadoCentavos: 0,
      saldoCentavos: 80000,
      fechaVencimientoIso: '2026-11-05',
      estado: EstadoCargo.pendiente,
    );

    const folioTicketDemo = 'CAJA1-2026-00001';
    const emitidoTicketDemoIso = '2026-11-03T18:14:00Z';
    const totalTicketDemoCentavos = 80000;
    final hashTicketDemo = _calcularHashCorto(
      '${academia.id}|$folioTicketDemo|$totalTicketDemoCentavos|$emitidoTicketDemoIso',
    );
    final ticketEmitido = TicketPago(
      id: 'tkt-demo-1',
      folio: folioTicketDemo,
      academiaId: academia.id,
      tutorId: tutorHernandez.id,
      emitidoEnIso: emitidoTicketDemoIso,
      metodoPago: MetodoPago.efectivo,
      lineas: <LineaTicket>[
        LineaTicket(
          cargoId: cargoMateo.id,
          alumnoNombre: mateo.nombreCompleto,
          concepto: cargoMateo.concepto,
          montoAbonadoCentavos: totalTicketDemoCentavos,
          saldoRestanteCargoCentavos: 0,
        ),
      ],
      totalPagadoCentavos: totalTicketDemoCentavos,
      cajeroUsuarioId: 'recepcion-1',
      cancelado: false,
      sincronizadoNube: true,
      codigoVerificacionQr:
          'dojang://verify/${academia.id}/$folioTicketDemo/$hashTicketDemo',
    );

    final convocatoriaInvierno = ConvocatoriaExamen(
      id: 'conv-invierno-2026',
      academiaId: academia.id,
      titulo: 'Examen de Grados Invierno 2026',
      fechaIso: '2026-12-12',
      sinodal: 'Sabonim Kim Tae-Hyun (7.º Dan)',
      cerrada: false,
    );

    final catalogoEquipo = <ProductoEquipo>[
      ProductoEquipo(
        id: 'prod-dobok-140',
        academiaId: academia.id,
        nombre: 'Dobok Oficial Cuello Blanco/Negro',
        categoria: CategoriaEquipo.dobok,
        talla: '140 cm',
        precioCentavos: 95000,
        existencias: 8,
      ),
      ProductoEquipo(
        id: 'prod-peto-ch',
        academiaId: academia.id,
        nombre: 'Peto Reversible Reglamentario WT',
        categoria: CategoriaEquipo.peto,
        talla: 'CH (#2)',
        precioCentavos: 85000,
        existencias: 5,
      ),
      ProductoEquipo(
        id: 'prod-casco-m',
        academiaId: academia.id,
        nombre: 'Casco de Combate Espuma Alta Densidad',
        categoria: CategoriaEquipo.casco,
        talla: 'M',
        precioCentavos: 78000,
        existencias: 4,
      ),
      ProductoEquipo(
        id: 'prod-bucal-jr',
        academiaId: academia.id,
        nombre: 'Protector Bucal Termoformable con Estuche',
        categoria: CategoriaEquipo.bucal,
        talla: 'Infantil/Jr',
        precioCentavos: 18000,
        existencias: 15,
      ),
    ];

    final torneoPrimavera = Torneo(
      id: 'torneo-copa-primavera',
      academiaId: academia.id,
      nombre: 'Torneo Copa Primavera TKD',
      sede: 'Gimnasio Olímpico Juan de la Barrera',
      fechaEventoIso: '2027-03-20',
      fechaLimiteInscripcionIso: '2027-03-10',
      cuotaCentavos: 75000,
      abierto: true,
    );

    return MotorDoyang(
      academia: academia,
      grados: grados,
      tutores: <TutorFamilia>[tutorHernandez, tutorRamirez],
      alumnos: <Alumno>[mateo, sofia, diego],
      asistencias: <Asistencia>[
        Asistencia(
          id: 'asist-demo-1',
          academiaId: academia.id,
          alumnoId: mateo.id,
          fechaDiaIso: '2026-11-20',
          registradaEnIso: '2026-11-20T18:02:00Z',
          metodo: MetodoAsistencia.qr,
          registradaPorUsuarioId: 'inst-1',
        ),
      ],
      cargos: <CargoCuenta>[cargoMateo, cargoSofia, cargoDiego],
      tickets: <TicketPago>[ticketEmitido],
      gastos: <GastoAcademia>[
        GastoAcademia(
          id: 'gasto-demo-1',
          academiaId: academia.id,
          concepto: 'Compra de cintas Kup y tablas de rompimiento',
          categoria: CategoriaGasto.equipoYMaterial,
          montoCentavos: 32000,
          metodoPago: MetodoPago.transferencia,
          fechaIso: '2026-11-18',
          referenciaOpcional: 'PROV-TKD-402',
        ),
        GastoAcademia(
          id: 'gasto-demo-2',
          academiaId: academia.id,
          concepto: 'Insumos de limpieza de tatami y garrafones',
          categoria: CategoriaGasto.mantenimientoTatami,
          montoCentavos: 18000,
          metodoPago: MetodoPago.efectivo,
          fechaIso: '2026-11-22',
        ),
      ],
      convocatoriasExamen: <ConvocatoriaExamen>[convocatoriaInvierno],
      historialGrados: <RegistroHistorialGrado>[
        RegistroHistorialGrado(
          id: 'hist-mateo-6kup',
          alumnoId: mateo.id,
          gradoId: 'grado-6-kup',
          obtenidoEnIso: '2026-06-15',
          sinodal: 'Sabonim Kim Tae-Hyun (7.º Dan)',
        ),
      ],
      productosEquipo: catalogoEquipo,
      torneos: <Torneo>[torneoPrimavera],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'academia': academia.toJson(),
        'grados': grados.map((g) => g.toJson()).toList(),
        'tutores': tutores.map((t) => t.toJson()).toList(),
        'alumnos': alumnos.map((a) => a.toJson()).toList(),
        'asistencias': asistencias.map((a) => a.toJson()).toList(),
        'cargos': cargos.map((c) => c.toJson()).toList(),
        'tickets': tickets.map((t) => t.toJson()).toList(),
        'gastos': gastos.map((g) => g.toJson()).toList(),
        'convocatoriasExamen':
            convocatoriasExamen.map((c) => c.toJson()).toList(),
        'inscripcionesExamen':
            inscripcionesExamen.map((i) => i.toJson()).toList(),
        'historialGrados': historialGrados.map((h) => h.toJson()).toList(),
        'productosEquipo': productosEquipo.map((p) => p.toJson()).toList(),
        'pedidosEquipo': pedidosEquipo.map((p) => p.toJson()).toList(),
        'torneos': torneos.map((t) => t.toJson()).toList(),
        'inscripcionesTorneo':
            inscripcionesTorneo.map((i) => i.toJson()).toList(),
        'colaOutbox': colaOutbox.map((e) => e.toJson()).toList(),
        'bitacoraAuditoria':
            bitacoraAuditoria.map((b) => b.toJson()).toList(),
        'secuenciaInterna': _secuenciaInterna,
      };

  factory MotorDoyang.fromJson(Map<String, dynamic> json) {
    return MotorDoyang(
      academia: AcademiaConfig.fromJson(
        Map<String, dynamic>.from(json['academia'] as Map),
      ),
      grados: (json['grados'] as List<dynamic>?)
          ?.map(
            (item) =>
                GradoCinta.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      tutores: (json['tutores'] as List<dynamic>?)
          ?.map(
            (item) =>
                TutorFamilia.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      alumnos: (json['alumnos'] as List<dynamic>?)
          ?.map(
            (item) => Alumno.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      asistencias: (json['asistencias'] as List<dynamic>?)
          ?.map(
            (item) =>
                Asistencia.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      cargos: (json['cargos'] as List<dynamic>?)
          ?.map(
            (item) =>
                CargoCuenta.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      tickets: (json['tickets'] as List<dynamic>?)
          ?.map(
            (item) =>
                TicketPago.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      gastos: (json['gastos'] as List<dynamic>?)
          ?.map(
            (item) =>
                GastoAcademia.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      convocatoriasExamen: (json['convocatoriasExamen'] as List<dynamic>?)
          ?.map(
            (item) => ConvocatoriaExamen.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      inscripcionesExamen: (json['inscripcionesExamen'] as List<dynamic>?)
          ?.map(
            (item) => InscripcionExamen.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      historialGrados: (json['historialGrados'] as List<dynamic>?)
          ?.map(
            (item) => RegistroHistorialGrado.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      productosEquipo: (json['productosEquipo'] as List<dynamic>?)
          ?.map(
            (item) =>
                ProductoEquipo.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      pedidosEquipo: (json['pedidosEquipo'] as List<dynamic>?)
          ?.map(
            (item) =>
                PedidoEquipo.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      torneos: (json['torneos'] as List<dynamic>?)
          ?.map(
            (item) => Torneo.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      inscripcionesTorneo: (json['inscripcionesTorneo'] as List<dynamic>?)
          ?.map(
            (item) => InscripcionTorneo.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      colaOutbox: (json['colaOutbox'] as List<dynamic>?)
          ?.map(
            (item) =>
                EventoOutbox.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      bitacoraAuditoria: (json['bitacoraAuditoria'] as List<dynamic>?)
          ?.map(
            (item) => EntradaBitacoraAuditoria.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      secuenciaInterna: (json['secuenciaInterna'] as int?) ?? 100,
    );
  }
}

String _calcularHashCorto(String entrada) {
  var hash = 0x811C9DC5;
  for (final codeUnit in entrada.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0').toUpperCase();
}

final RegExp _patronInicioFormulaCsv = RegExp(r'^[=+\-@\t\r]');
final RegExp _patronNumeroPuroCsv = RegExp(r'^[+-]?\d+(?:\.\d+)?$');

String _escaparCsv(String valor) {
  var limpio = valor;
  if (_patronInicioFormulaCsv.hasMatch(limpio) &&
      !_patronNumeroPuroCsv.hasMatch(limpio)) {
    limpio = "'$limpio";
  }
  if (limpio.contains(',') ||
      limpio.contains('"') ||
      limpio.contains('\n') ||
      limpio.contains('\r')) {
    return '"${limpio.replaceAll('"', '""')}"';
  }
  return limpio;
}
