import 'caja_tickets.dart';

/// Categorías reales de egresos operativos en una academia de Taekwondo.
enum CategoriaGasto {
  rentaLocal,
  nominaInstructores,
  serviciosBasicos,
  equipoYMaterial,
  federacionYTorneos,
  mantenimientoTatami,
  otros;

  String get etiqueta {
    switch (this) {
      case CategoriaGasto.rentaLocal:
        return 'Renta del local';
      case CategoriaGasto.nominaInstructores:
        return 'Honorarios de instructores';
      case CategoriaGasto.serviciosBasicos:
        return 'Luz, agua e internet';
      case CategoriaGasto.equipoYMaterial:
        return 'Equipo, cintas y tablas';
      case CategoriaGasto.federacionYTorneos:
        return 'Federación y eventos';
      case CategoriaGasto.mantenimientoTatami:
        return 'Limpieza y tatami';
      case CategoriaGasto.otros:
        return 'Otros egresos';
    }
  }
}

/// Registro inmutable de un gasto operativo del dojang en centavos enteros MXN.
class GastoAcademia {
  final String id;
  final String academiaId;
  final String concepto;
  final CategoriaGasto categoria;
  final int montoCentavos;
  final MetodoPago metodoPago;
  final String fechaIso;
  final String? referenciaOpcional;
  final String registradoPorUsuarioId;
  final bool cancelado;

  GastoAcademia({
    required this.id,
    required this.academiaId,
    required this.concepto,
    required this.categoria,
    required this.montoCentavos,
    required this.metodoPago,
    required this.fechaIso,
    this.referenciaOpcional,
    this.registradoPorUsuarioId = 'dueno-1',
    this.cancelado = false,
  }) {
    if (concepto.trim().isEmpty) {
      throw ArgumentError('El concepto del gasto no puede estar vacío.');
    }
    if (montoCentavos <= 0) {
      throw ArgumentError.value(
        montoCentavos,
        'montoCentavos',
        'El monto del gasto debe ser mayor a 0 centavos.',
      );
    }
    validarReferenciaPagoSegura(referenciaOpcional);
  }

  GastoAcademia copyWith({
    bool? cancelado,
  }) {
    return GastoAcademia(
      id: id,
      academiaId: academiaId,
      concepto: concepto,
      categoria: categoria,
      montoCentavos: montoCentavos,
      metodoPago: metodoPago,
      fechaIso: fechaIso,
      referenciaOpcional: referenciaOpcional,
      registradoPorUsuarioId: registradoPorUsuarioId,
      cancelado: cancelado ?? this.cancelado,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'concepto': concepto,
        'categoria': categoria.name,
        'montoCentavos': montoCentavos,
        'metodoPago': metodoPago.name,
        'fechaIso': fechaIso,
        'referenciaOpcional': referenciaOpcional,
        'registradoPorUsuarioId': registradoPorUsuarioId,
        'cancelado': cancelado,
      };

  factory GastoAcademia.fromJson(Map<String, dynamic> json) {
    return GastoAcademia(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      concepto: json['concepto'] as String,
      categoria: CategoriaGasto.values.byName(json['categoria'] as String),
      montoCentavos: json['montoCentavos'] as int,
      metodoPago: MetodoPago.values.byName(json['metodoPago'] as String),
      fechaIso: json['fechaIso'] as String,
      referenciaOpcional: json['referenciaOpcional'] as String?,
      registradoPorUsuarioId:
          (json['registradoPorUsuarioId'] as String?) ?? 'dueno-1',
      cancelado: (json['cancelado'] as bool?) ?? false,
    );
  }
}
