/// M6 · Modalidades de participación en torneos de Taekwondo.
enum ModalidadTorneo {
  kyorugi,
  poomsae,
  ambas,
}

/// M6 · Resultado o presea obtenida por el competidor en el torneo.
enum MedallaTorneo {
  ninguna,
  participacion,
  bronce,
  plata,
  oro,
}

/// M6 · Convocatoria de torneo registrada en la academia.
class Torneo {
  final String id;
  final String academiaId;
  final String nombre;
  final String sede;
  final String fechaEventoIso;
  final String fechaLimiteInscripcionIso;
  final int cuotaCentavos;
  final bool abierto;

  Torneo({
    required this.id,
    required this.academiaId,
    required this.nombre,
    required this.sede,
    required this.fechaEventoIso,
    required this.fechaLimiteInscripcionIso,
    required this.cuotaCentavos,
    this.abierto = true,
  }) {
    if (cuotaCentavos < 0) {
      throw ArgumentError.value(
        cuotaCentavos,
        'cuotaCentavos',
        'La cuota del torneo no puede ser negativa.',
      );
    }
  }

  Torneo copyWith({
    String? id,
    String? academiaId,
    String? nombre,
    String? sede,
    String? fechaEventoIso,
    String? fechaLimiteInscripcionIso,
    int? cuotaCentavos,
    bool? abierto,
  }) {
    return Torneo(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      nombre: nombre ?? this.nombre,
      sede: sede ?? this.sede,
      fechaEventoIso: fechaEventoIso ?? this.fechaEventoIso,
      fechaLimiteInscripcionIso:
          fechaLimiteInscripcionIso ?? this.fechaLimiteInscripcionIso,
      cuotaCentavos: cuotaCentavos ?? this.cuotaCentavos,
      abierto: abierto ?? this.abierto,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'nombre': nombre,
        'sede': sede,
        'fechaEventoIso': fechaEventoIso,
        'fechaLimiteInscripcionIso': fechaLimiteInscripcionIso,
        'cuotaCentavos': cuotaCentavos,
        'abierto': abierto,
      };

  factory Torneo.fromJson(Map<String, dynamic> json) {
    return Torneo(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      nombre: json['nombre'] as String,
      sede: json['sede'] as String,
      fechaEventoIso: json['fechaEventoIso'] as String,
      fechaLimiteInscripcionIso: json['fechaLimiteInscripcionIso'] as String,
      cuotaCentavos: json['cuotaCentavos'] as int,
      abierto: (json['abierto'] as bool?) ?? true,
    );
  }
}

/// M6 · Inscripción de un alumno a un [Torneo] con responsiva digital del tutor.
class InscripcionTorneo {
  final String id;
  final String torneoId;
  final String alumnoId;
  final String tutorId;
  final ModalidadTorneo modalidad;
  final double pesoKgRegistrado;
  final String gradoIdAlInscribir;
  final String categoriaDivision;
  final bool responsivaTutorAceptada;
  final String responsivaAceptadaEnIso;
  final String cargoId;
  final MedallaTorneo medalla;
  final String notasResultado;

  InscripcionTorneo({
    required this.id,
    required this.torneoId,
    required this.alumnoId,
    required this.tutorId,
    required this.modalidad,
    required this.pesoKgRegistrado,
    required this.gradoIdAlInscribir,
    required this.categoriaDivision,
    required this.responsivaTutorAceptada,
    required this.responsivaAceptadaEnIso,
    required this.cargoId,
    this.medalla = MedallaTorneo.ninguna,
    this.notasResultado = '',
  }) {
    if (pesoKgRegistrado <= 0) {
      throw ArgumentError.value(
        pesoKgRegistrado,
        'pesoKgRegistrado',
        'El peso registrado para el torneo debe ser mayor a 0 kg.',
      );
    }
  }

  InscripcionTorneo copyWith({
    String? id,
    String? torneoId,
    String? alumnoId,
    String? tutorId,
    ModalidadTorneo? modalidad,
    double? pesoKgRegistrado,
    String? gradoIdAlInscribir,
    String? categoriaDivision,
    bool? responsivaTutorAceptada,
    String? responsivaAceptadaEnIso,
    String? cargoId,
    MedallaTorneo? medalla,
    String? notasResultado,
  }) {
    return InscripcionTorneo(
      id: id ?? this.id,
      torneoId: torneoId ?? this.torneoId,
      alumnoId: alumnoId ?? this.alumnoId,
      tutorId: tutorId ?? this.tutorId,
      modalidad: modalidad ?? this.modalidad,
      pesoKgRegistrado: pesoKgRegistrado ?? this.pesoKgRegistrado,
      gradoIdAlInscribir: gradoIdAlInscribir ?? this.gradoIdAlInscribir,
      categoriaDivision: categoriaDivision ?? this.categoriaDivision,
      responsivaTutorAceptada:
          responsivaTutorAceptada ?? this.responsivaTutorAceptada,
      responsivaAceptadaEnIso:
          responsivaAceptadaEnIso ?? this.responsivaAceptadaEnIso,
      cargoId: cargoId ?? this.cargoId,
      medalla: medalla ?? this.medalla,
      notasResultado: notasResultado ?? this.notasResultado,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'torneoId': torneoId,
        'alumnoId': alumnoId,
        'tutorId': tutorId,
        'modalidad': modalidad.name,
        'pesoKgRegistrado': pesoKgRegistrado,
        'gradoIdAlInscribir': gradoIdAlInscribir,
        'categoriaDivision': categoriaDivision,
        'responsivaTutorAceptada': responsivaTutorAceptada,
        'responsivaAceptadaEnIso': responsivaAceptadaEnIso,
        'cargoId': cargoId,
        'medalla': medalla.name,
        'notasResultado': notasResultado,
      };

  factory InscripcionTorneo.fromJson(Map<String, dynamic> json) {
    return InscripcionTorneo(
      id: json['id'] as String,
      torneoId: json['torneoId'] as String,
      alumnoId: json['alumnoId'] as String,
      tutorId: json['tutorId'] as String,
      modalidad: ModalidadTorneo.values.byName(json['modalidad'] as String),
      pesoKgRegistrado: (json['pesoKgRegistrado'] as num).toDouble(),
      gradoIdAlInscribir: json['gradoIdAlInscribir'] as String,
      categoriaDivision: json['categoriaDivision'] as String,
      responsivaTutorAceptada: json['responsivaTutorAceptada'] as bool,
      responsivaAceptadaEnIso: json['responsivaAceptadaEnIso'] as String,
      cargoId: json['cargoId'] as String,
      medalla: MedallaTorneo.values.byName(
        (json['medalla'] as String?) ?? MedallaTorneo.ninguna.name,
      ),
      notasResultado: (json['notasResultado'] as String?) ?? '',
    );
  }
}
