/// Excepción lanzada cuando una operación viola las reglas de privacidad
/// por diseño o la LFPDPPP 2025 (menores de edad, datos sensibles de salud,
/// tarjetas bancarias PAN/CVV o responsivas obligatorias).
class ViolacionPrivacidadException extends ArgumentError implements Exception {
  ViolacionPrivacidadException(String super.message);

  @override
  String toString() => 'ViolacionPrivacidadException: $message';
}

/// Roles de acceso del sistema (RBAC conforme a D-10 y políticas RLS).
enum RolUsuario {
  dueno,
  recepcion,
  instructor,
  tutor,
}

/// Rama deportiva del alumno para clasificación en torneos y exámenes.
enum SexoRama {
  femenil,
  varonil,
}

/// Método de registro de asistencia en el tatami.
enum MetodoAsistencia {
  qr,
  manual,
}

/// M2 · Evidencia de consentimiento legal otorgado por el Padre/Tutor
/// conforme a la LFPDPPP 2025 (`docs/privacidad.md`).
class ConsentimientoTutor {
  final String tutorId;
  final bool declaracionPatriaPotestad;
  final bool aceptoAvisoIntegral;
  final bool consentimientoSaludExpreso;
  final bool consentimientoFotoInterna;
  final bool consentimientoPromociones;
  final String versionAviso;
  final String registradoEnIso;

  const ConsentimientoTutor({
    required this.tutorId,
    required this.declaracionPatriaPotestad,
    required this.aceptoAvisoIntegral,
    this.consentimientoSaludExpreso = false,
    this.consentimientoFotoInterna = false,
    this.consentimientoPromociones = false,
    required this.versionAviso,
    required this.registradoEnIso,
  });

  ConsentimientoTutor copyWith({
    String? tutorId,
    bool? declaracionPatriaPotestad,
    bool? aceptoAvisoIntegral,
    bool? consentimientoSaludExpreso,
    bool? consentimientoFotoInterna,
    bool? consentimientoPromociones,
    String? versionAviso,
    String? registradoEnIso,
  }) {
    return ConsentimientoTutor(
      tutorId: tutorId ?? this.tutorId,
      declaracionPatriaPotestad:
          declaracionPatriaPotestad ?? this.declaracionPatriaPotestad,
      aceptoAvisoIntegral: aceptoAvisoIntegral ?? this.aceptoAvisoIntegral,
      consentimientoSaludExpreso:
          consentimientoSaludExpreso ?? this.consentimientoSaludExpreso,
      consentimientoFotoInterna:
          consentimientoFotoInterna ?? this.consentimientoFotoInterna,
      consentimientoPromociones:
          consentimientoPromociones ?? this.consentimientoPromociones,
      versionAviso: versionAviso ?? this.versionAviso,
      registradoEnIso: registradoEnIso ?? this.registradoEnIso,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tutorId': tutorId,
        'declaracionPatriaPotestad': declaracionPatriaPotestad,
        'aceptoAvisoIntegral': aceptoAvisoIntegral,
        'consentimientoSaludExpreso': consentimientoSaludExpreso,
        'consentimientoFotoInterna': consentimientoFotoInterna,
        'consentimientoPromociones': consentimientoPromociones,
        'versionAviso': versionAviso,
        'registradoEnIso': registradoEnIso,
      };

  factory ConsentimientoTutor.fromJson(Map<String, dynamic> json) {
    return ConsentimientoTutor(
      tutorId: json['tutorId'] as String,
      declaracionPatriaPotestad: json['declaracionPatriaPotestad'] as bool,
      aceptoAvisoIntegral: json['aceptoAvisoIntegral'] as bool,
      consentimientoSaludExpreso:
          (json['consentimientoSaludExpreso'] as bool?) ?? false,
      consentimientoFotoInterna:
          (json['consentimientoFotoInterna'] as bool?) ?? false,
      consentimientoPromociones:
          (json['consentimientoPromociones'] as bool?) ?? false,
      versionAviso: json['versionAviso'] as String,
      registradoEnIso: json['registradoEnIso'] as String,
    );
  }
}

/// M2 · Cuenta titular del Padre, Madre o Tutor legal que agrupa a 1..N hijos.
class TutorFamilia {
  final String id;
  final String academiaId;
  final String nombreCompleto;
  final String telefonoWhatsapp;
  final String correo;
  final String parentesco;
  final ConsentimientoTutor consentimiento;
  final bool bloqueadoArco;

  const TutorFamilia({
    required this.id,
    required this.academiaId,
    required this.nombreCompleto,
    required this.telefonoWhatsapp,
    required this.correo,
    required this.parentesco,
    required this.consentimiento,
    this.bloqueadoArco = false,
  });

  TutorFamilia copyWith({
    String? id,
    String? academiaId,
    String? nombreCompleto,
    String? telefonoWhatsapp,
    String? correo,
    String? parentesco,
    ConsentimientoTutor? consentimiento,
    bool? bloqueadoArco,
  }) {
    return TutorFamilia(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefonoWhatsapp: telefonoWhatsapp ?? this.telefonoWhatsapp,
      correo: correo ?? this.correo,
      parentesco: parentesco ?? this.parentesco,
      consentimiento: consentimiento ?? this.consentimiento,
      bloqueadoArco: bloqueadoArco ?? this.bloqueadoArco,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'nombreCompleto': nombreCompleto,
        'telefonoWhatsapp': telefonoWhatsapp,
        'correo': correo,
        'parentesco': parentesco,
        'consentimiento': consentimiento.toJson(),
        'bloqueadoArco': bloqueadoArco,
      };

  factory TutorFamilia.fromJson(Map<String, dynamic> json) {
    return TutorFamilia(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      telefonoWhatsapp: json['telefonoWhatsapp'] as String,
      correo: json['correo'] as String,
      parentesco: json['parentesco'] as String,
      consentimiento: ConsentimientoTutor.fromJson(
        Map<String, dynamic>.from(json['consentimiento'] as Map),
      ),
      bloqueadoArco: (json['bloqueadoArco'] as bool?) ?? false,
    );
  }
}

/// M2 · Expediente integral del alumno vinculado a un [TutorFamilia].
class Alumno {
  final String id;
  final String academiaId;
  final String tutorId;
  final String nombre;
  final String apellidos;
  final String fechaNacimientoIso;
  final SexoRama sexoRama;
  final double? pesoKgOpcional;
  final String gradoActualId;
  final String fechaUltimoGradoIso;
  final int asistenciasEnGradoActual;
  final String horarioGrupo;
  final bool activo;
  final bool bloqueadoArco;
  final String? tipoSangreOpcional;
  final String? alergiasCuidadosOpcional;
  final String? telefonoEmergenciaOpcional;
  final String codigoQr;

  const Alumno({
    required this.id,
    required this.academiaId,
    required this.tutorId,
    required this.nombre,
    required this.apellidos,
    required this.fechaNacimientoIso,
    required this.sexoRama,
    this.pesoKgOpcional,
    required this.gradoActualId,
    required this.fechaUltimoGradoIso,
    required this.asistenciasEnGradoActual,
    required this.horarioGrupo,
    this.activo = true,
    this.bloqueadoArco = false,
    this.tipoSangreOpcional,
    this.alergiasCuidadosOpcional,
    this.telefonoEmergenciaOpcional,
    required this.codigoQr,
  });

  String get nombreCompleto => '$nombre $apellidos'.trim();

  bool get tieneDatosSaludSensibles =>
      (tipoSangreOpcional != null && tipoSangreOpcional!.trim().isNotEmpty) ||
      (alergiasCuidadosOpcional != null &&
          alergiasCuidadosOpcional!.trim().isNotEmpty);

  /// Calcula la edad cumplida en años a la [fechaReferencia] (por defecto `2026-11-23`).
  int calcularEdadAnios({DateTime? fechaReferencia}) {
    final ref = fechaReferencia ?? DateTime.utc(2026, 11, 23);
    final nacimiento = DateTime.parse(fechaNacimientoIso);
    var edad = ref.year - nacimiento.year;
    if (ref.month < nacimiento.month ||
        (ref.month == nacimiento.month && ref.day < nacimiento.day)) {
      edad--;
    }
    return edad;
  }

  bool esMenorDeEdad({DateTime? fechaReferencia}) =>
      calcularEdadAnios(fechaReferencia: fechaReferencia) < 18;

  Alumno copyWith({
    String? id,
    String? academiaId,
    String? tutorId,
    String? nombre,
    String? apellidos,
    String? fechaNacimientoIso,
    SexoRama? sexoRama,
    double? pesoKgOpcional,
    bool limpiarPeso = false,
    String? gradoActualId,
    String? fechaUltimoGradoIso,
    int? asistenciasEnGradoActual,
    String? horarioGrupo,
    bool? activo,
    bool? bloqueadoArco,
    String? tipoSangreOpcional,
    bool limpiarTipoSangre = false,
    String? alergiasCuidadosOpcional,
    bool limpiarAlergias = false,
    String? telefonoEmergenciaOpcional,
    bool limpiarTelefonoEmergencia = false,
    String? codigoQr,
  }) {
    return Alumno(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      tutorId: tutorId ?? this.tutorId,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      fechaNacimientoIso: fechaNacimientoIso ?? this.fechaNacimientoIso,
      sexoRama: sexoRama ?? this.sexoRama,
      pesoKgOpcional:
          limpiarPeso ? null : (pesoKgOpcional ?? this.pesoKgOpcional),
      gradoActualId: gradoActualId ?? this.gradoActualId,
      fechaUltimoGradoIso: fechaUltimoGradoIso ?? this.fechaUltimoGradoIso,
      asistenciasEnGradoActual:
          asistenciasEnGradoActual ?? this.asistenciasEnGradoActual,
      horarioGrupo: horarioGrupo ?? this.horarioGrupo,
      activo: activo ?? this.activo,
      bloqueadoArco: bloqueadoArco ?? this.bloqueadoArco,
      tipoSangreOpcional: limpiarTipoSangre
          ? null
          : (tipoSangreOpcional ?? this.tipoSangreOpcional),
      alergiasCuidadosOpcional: limpiarAlergias
          ? null
          : (alergiasCuidadosOpcional ?? this.alergiasCuidadosOpcional),
      telefonoEmergenciaOpcional: limpiarTelefonoEmergencia
          ? null
          : (telefonoEmergenciaOpcional ?? this.telefonoEmergenciaOpcional),
      codigoQr: codigoQr ?? this.codigoQr,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'tutorId': tutorId,
        'nombre': nombre,
        'apellidos': apellidos,
        'fechaNacimientoIso': fechaNacimientoIso,
        'sexoRama': sexoRama.name,
        'pesoKgOpcional': pesoKgOpcional,
        'gradoActualId': gradoActualId,
        'fechaUltimoGradoIso': fechaUltimoGradoIso,
        'asistenciasEnGradoActual': asistenciasEnGradoActual,
        'horarioGrupo': horarioGrupo,
        'activo': activo,
        'bloqueadoArco': bloqueadoArco,
        'tipoSangreOpcional': tipoSangreOpcional,
        'alergiasCuidadosOpcional': alergiasCuidadosOpcional,
        'telefonoEmergenciaOpcional': telefonoEmergenciaOpcional,
        'codigoQr': codigoQr,
      };

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      tutorId: json['tutorId'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      fechaNacimientoIso: json['fechaNacimientoIso'] as String,
      sexoRama: SexoRama.values.byName(json['sexoRama'] as String),
      pesoKgOpcional: (json['pesoKgOpcional'] as num?)?.toDouble(),
      gradoActualId: json['gradoActualId'] as String,
      fechaUltimoGradoIso: json['fechaUltimoGradoIso'] as String,
      asistenciasEnGradoActual: json['asistenciasEnGradoActual'] as int,
      horarioGrupo: json['horarioGrupo'] as String,
      activo: (json['activo'] as bool?) ?? true,
      bloqueadoArco: (json['bloqueadoArco'] as bool?) ?? false,
      tipoSangreOpcional: json['tipoSangreOpcional'] as String?,
      alergiasCuidadosOpcional: json['alergiasCuidadosOpcional'] as String?,
      telefonoEmergenciaOpcional: json['telefonoEmergenciaOpcional'] as String?,
      codigoQr: json['codigoQr'] as String,
    );
  }
}

/// Valida las reglas estrictas de privacidad LFPDPPP 2025 para el alta o
/// edición de un [Alumno] vinculado a un [TutorFamilia].
///
/// Lanza [ViolacionPrivacidadException] si:
/// 1. `aceptoAvisoIntegral` es `false`.
/// 2. El alumno es menor de 18 años y `declaracionPatriaPotestad` es `false`.
/// 3. `consentimientoSaludExpreso` es `false` pero se intenta guardar
///    `tipoSangreOpcional` o `alergiasCuidadosOpcional` no vacíos.
void validarPrivacidadAlumno({
  required Alumno alumno,
  required TutorFamilia tutor,
  DateTime? fechaReferencia,
}) {
  final consentimiento = tutor.consentimiento;
  if (!consentimiento.aceptoAvisoIntegral) {
    throw ViolacionPrivacidadException(
      'No se puede registrar al alumno sin la aceptación del Aviso de Privacidad Integral.',
    );
  }
  if (alumno.esMenorDeEdad(fechaReferencia: fechaReferencia) &&
      !consentimiento.declaracionPatriaPotestad) {
    throw ViolacionPrivacidadException(
      'Para alumnos menores de 18 años es obligatoria la declaración de patria potestad o tutela legal.',
    );
  }
  if (!consentimiento.consentimientoSaludExpreso &&
      alumno.tieneDatosSaludSensibles) {
    throw ViolacionPrivacidadException(
      'Se requiere consentimiento expreso y separado del tutor para guardar datos sensibles de salud (tipo de sangre o alergias).',
    );
  }
}

/// Limpia los campos sensibles de salud de un [Alumno] cuando el tutor no ha
/// otorgado o ha revocado `consentimientoSaludExpreso`.
Alumno limpiarDatosSaludSinConsentimiento({
  required Alumno alumno,
  required ConsentimientoTutor consentimiento,
}) {
  if (consentimiento.consentimientoSaludExpreso) {
    return alumno;
  }
  return alumno.copyWith(
    limpiarTipoSangre: true,
    limpiarAlergias: true,
  );
}

/// M2 · Registro de asistencia diaria por alumno (máximo 1 por alumno y `fechaDiaIso`).
class Asistencia {
  final String id;
  final String academiaId;
  final String alumnoId;
  final String fechaDiaIso;
  final String registradaEnIso;
  final MetodoAsistencia metodo;
  final String registradaPorUsuarioId;

  const Asistencia({
    required this.id,
    required this.academiaId,
    required this.alumnoId,
    required this.fechaDiaIso,
    required this.registradaEnIso,
    required this.metodo,
    required this.registradaPorUsuarioId,
  });

  Asistencia copyWith({
    String? id,
    String? academiaId,
    String? alumnoId,
    String? fechaDiaIso,
    String? registradaEnIso,
    MetodoAsistencia? metodo,
    String? registradaPorUsuarioId,
  }) {
    return Asistencia(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      alumnoId: alumnoId ?? this.alumnoId,
      fechaDiaIso: fechaDiaIso ?? this.fechaDiaIso,
      registradaEnIso: registradaEnIso ?? this.registradaEnIso,
      metodo: metodo ?? this.metodo,
      registradaPorUsuarioId:
          registradaPorUsuarioId ?? this.registradaPorUsuarioId,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'alumnoId': alumnoId,
        'fechaDiaIso': fechaDiaIso,
        'registradaEnIso': registradaEnIso,
        'metodo': metodo.name,
        'registradaPorUsuarioId': registradaPorUsuarioId,
      };

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      alumnoId: json['alumnoId'] as String,
      fechaDiaIso: json['fechaDiaIso'] as String,
      registradaEnIso: json['registradaEnIso'] as String,
      metodo: MetodoAsistencia.values.byName(json['metodo'] as String),
      registradaPorUsuarioId: json['registradaPorUsuarioId'] as String,
    );
  }
}
