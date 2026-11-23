import 'academia.dart';

/// M4 · Dictamen de elegibilidad de un alumno para presentar examen de grado.
class DictamenElegibilidad {
  final String alumnoId;
  final GradoCinta gradoActual;
  final GradoCinta? siguienteGrado;
  final bool elegible;
  final bool cumpleAsistencias;
  final bool cumpleTiempoMeses;
  final bool cumplePagosAlCorriente;
  final int asistenciasActuales;
  final int asistenciasRequeridas;
  final int mesesTranscurridos;
  final int mesesRequeridos;
  final int adeudoCentavos;
  final List<String> motivos;

  DictamenElegibilidad({
    required this.alumnoId,
    required this.gradoActual,
    required this.siguienteGrado,
    required this.elegible,
    required this.cumpleAsistencias,
    required this.cumpleTiempoMeses,
    required this.cumplePagosAlCorriente,
    required this.asistenciasActuales,
    required this.asistenciasRequeridas,
    required this.mesesTranscurridos,
    required this.mesesRequeridos,
    required this.adeudoCentavos,
    required List<String> motivos,
  }) : motivos = List<String>.unmodifiable(motivos);

  /// Alias descriptivo de los motivos por los que no cumple elegibilidad.
  List<String> get motivosNoElegible => motivos;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'alumnoId': alumnoId,
        'gradoActual': gradoActual.toJson(),
        'siguienteGrado': siguienteGrado?.toJson(),
        'elegible': elegible,
        'cumpleAsistencias': cumpleAsistencias,
        'cumpleTiempoMeses': cumpleTiempoMeses,
        'cumplePagosAlCorriente': cumplePagosAlCorriente,
        'asistenciasActuales': asistenciasActuales,
        'asistenciasRequeridas': asistenciasRequeridas,
        'mesesTranscurridos': mesesTranscurridos,
        'mesesRequeridos': mesesRequeridos,
        'adeudoCentavos': adeudoCentavos,
        'motivos': motivos,
      };
}

/// M4 · Convocatoria oficial de examen interno de grados del dojang.
class ConvocatoriaExamen {
  final String id;
  final String academiaId;
  final String titulo;
  final String fechaIso;
  final String sinodal;
  final bool cerrada;

  const ConvocatoriaExamen({
    required this.id,
    required this.academiaId,
    required this.titulo,
    required this.fechaIso,
    required this.sinodal,
    this.cerrada = false,
  });

  ConvocatoriaExamen copyWith({
    String? id,
    String? academiaId,
    String? titulo,
    String? fechaIso,
    String? sinodal,
    bool? cerrada,
  }) {
    return ConvocatoriaExamen(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      titulo: titulo ?? this.titulo,
      fechaIso: fechaIso ?? this.fechaIso,
      sinodal: sinodal ?? this.sinodal,
      cerrada: cerrada ?? this.cerrada,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'titulo': titulo,
        'fechaIso': fechaIso,
        'sinodal': sinodal,
        'cerrada': cerrada,
      };

  factory ConvocatoriaExamen.fromJson(Map<String, dynamic> json) {
    return ConvocatoriaExamen(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      titulo: json['titulo'] as String,
      fechaIso: json['fechaIso'] as String,
      sinodal: json['sinodal'] as String,
      cerrada: (json['cerrada'] as bool?) ?? false,
    );
  }
}

/// M4 · Calificaciones técnicas obtenidas por el alumno en su examen de grado.
class EvaluacionExamen {
  final int poomsae;
  final int kyorugi;
  final int rompimiento;
  final int teoria;
  final bool aprobado;
  final String observaciones;
  final String evaluadoEnIso;

  EvaluacionExamen({
    required this.poomsae,
    required this.kyorugi,
    required this.rompimiento,
    required this.teoria,
    required this.aprobado,
    this.observaciones = '',
    required this.evaluadoEnIso,
  }) {
    for (final entry in <String, int>{
      'poomsae': poomsae,
      'kyorugi': kyorugi,
      'rompimiento': rompimiento,
      'teoria': teoria,
    }.entries) {
      if (entry.value < 0 || entry.value > 100) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'La calificación debe estar entre 0 y 100.',
        );
      }
    }
  }

  double get promedio => (poomsae + kyorugi + rompimiento + teoria) / 4.0;

  EvaluacionExamen copyWith({
    int? poomsae,
    int? kyorugi,
    int? rompimiento,
    int? teoria,
    bool? aprobado,
    String? observaciones,
    String? evaluadoEnIso,
  }) {
    return EvaluacionExamen(
      poomsae: poomsae ?? this.poomsae,
      kyorugi: kyorugi ?? this.kyorugi,
      rompimiento: rompimiento ?? this.rompimiento,
      teoria: teoria ?? this.teoria,
      aprobado: aprobado ?? this.aprobado,
      observaciones: observaciones ?? this.observaciones,
      evaluadoEnIso: evaluadoEnIso ?? this.evaluadoEnIso,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'poomsae': poomsae,
        'kyorugi': kyorugi,
        'rompimiento': rompimiento,
        'teoria': teoria,
        'aprobado': aprobado,
        'observaciones': observaciones,
        'evaluadoEnIso': evaluadoEnIso,
      };

  factory EvaluacionExamen.fromJson(Map<String, dynamic> json) {
    return EvaluacionExamen(
      poomsae: json['poomsae'] as int,
      kyorugi: json['kyorugi'] as int,
      rompimiento: json['rompimiento'] as int,
      teoria: json['teoria'] as int,
      aprobado: json['aprobado'] as bool,
      observaciones: (json['observaciones'] as String?) ?? '',
      evaluadoEnIso: json['evaluadoEnIso'] as String,
    );
  }
}

/// M4 · Inscripción de un alumno a una [ConvocatoriaExamen].
class InscripcionExamen {
  final String id;
  final String convocatoriaId;
  final String alumnoId;
  final String gradoActualId;
  final String gradoAspiradoId;
  final String cargoId;
  final bool excepcionAutorizada;
  final String? motivoExcepcionOpcional;
  final bool consentimientoTutorAceptado;
  final EvaluacionExamen? evaluacionOpcional;

  const InscripcionExamen({
    required this.id,
    required this.convocatoriaId,
    required this.alumnoId,
    required this.gradoActualId,
    required this.gradoAspiradoId,
    required this.cargoId,
    this.excepcionAutorizada = false,
    this.motivoExcepcionOpcional,
    required this.consentimientoTutorAceptado,
    this.evaluacionOpcional,
  });

  InscripcionExamen copyWith({
    String? id,
    String? convocatoriaId,
    String? alumnoId,
    String? gradoActualId,
    String? gradoAspiradoId,
    String? cargoId,
    bool? excepcionAutorizada,
    String? motivoExcepcionOpcional,
    bool? consentimientoTutorAceptado,
    EvaluacionExamen? evaluacionOpcional,
  }) {
    return InscripcionExamen(
      id: id ?? this.id,
      convocatoriaId: convocatoriaId ?? this.convocatoriaId,
      alumnoId: alumnoId ?? this.alumnoId,
      gradoActualId: gradoActualId ?? this.gradoActualId,
      gradoAspiradoId: gradoAspiradoId ?? this.gradoAspiradoId,
      cargoId: cargoId ?? this.cargoId,
      excepcionAutorizada: excepcionAutorizada ?? this.excepcionAutorizada,
      motivoExcepcionOpcional:
          motivoExcepcionOpcional ?? this.motivoExcepcionOpcional,
      consentimientoTutorAceptado:
          consentimientoTutorAceptado ?? this.consentimientoTutorAceptado,
      evaluacionOpcional: evaluacionOpcional ?? this.evaluacionOpcional,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'convocatoriaId': convocatoriaId,
        'alumnoId': alumnoId,
        'gradoActualId': gradoActualId,
        'gradoAspiradoId': gradoAspiradoId,
        'cargoId': cargoId,
        'excepcionAutorizada': excepcionAutorizada,
        'motivoExcepcionOpcional': motivoExcepcionOpcional,
        'consentimientoTutorAceptado': consentimientoTutorAceptado,
        'evaluacionOpcional': evaluacionOpcional?.toJson(),
      };

  factory InscripcionExamen.fromJson(Map<String, dynamic> json) {
    return InscripcionExamen(
      id: json['id'] as String,
      convocatoriaId: json['convocatoriaId'] as String,
      alumnoId: json['alumnoId'] as String,
      gradoActualId: json['gradoActualId'] as String,
      gradoAspiradoId: json['gradoAspiradoId'] as String,
      cargoId: json['cargoId'] as String,
      excepcionAutorizada: (json['excepcionAutorizada'] as bool?) ?? false,
      motivoExcepcionOpcional: json['motivoExcepcionOpcional'] as String?,
      consentimientoTutorAceptado: json['consentimientoTutorAceptado'] as bool,
      evaluacionOpcional: json['evaluacionOpcional'] == null
          ? null
          : EvaluacionExamen.fromJson(
              Map<String, dynamic>.from(json['evaluacionOpcional'] as Map),
            ),
    );
  }
}

/// M4 · Registro histórico de ascenso de cinta/grado de un alumno.
class RegistroHistorialGrado {
  final String id;
  final String alumnoId;
  final String gradoId;
  final String obtenidoEnIso;
  final String sinodal;
  final String? convocatoriaIdOpcional;

  const RegistroHistorialGrado({
    required this.id,
    required this.alumnoId,
    required this.gradoId,
    required this.obtenidoEnIso,
    required this.sinodal,
    this.convocatoriaIdOpcional,
  });

  RegistroHistorialGrado copyWith({
    String? id,
    String? alumnoId,
    String? gradoId,
    String? obtenidoEnIso,
    String? sinodal,
    String? convocatoriaIdOpcional,
  }) {
    return RegistroHistorialGrado(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      gradoId: gradoId ?? this.gradoId,
      obtenidoEnIso: obtenidoEnIso ?? this.obtenidoEnIso,
      sinodal: sinodal ?? this.sinodal,
      convocatoriaIdOpcional:
          convocatoriaIdOpcional ?? this.convocatoriaIdOpcional,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'alumnoId': alumnoId,
        'gradoId': gradoId,
        'obtenidoEnIso': obtenidoEnIso,
        'sinodal': sinodal,
        'convocatoriaIdOpcional': convocatoriaIdOpcional,
      };

  factory RegistroHistorialGrado.fromJson(Map<String, dynamic> json) {
    return RegistroHistorialGrado(
      id: json['id'] as String,
      alumnoId: json['alumnoId'] as String,
      gradoId: json['gradoId'] as String,
      obtenidoEnIso: json['obtenidoEnIso'] as String,
      sinodal: json['sinodal'] as String,
      convocatoriaIdOpcional: json['convocatoriaIdOpcional'] as String?,
    );
  }
}
