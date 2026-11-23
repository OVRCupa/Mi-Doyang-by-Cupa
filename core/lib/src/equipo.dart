/// M5 · Categorías de artículos deportivos del dojang.
enum CategoriaEquipo {
  dobok,
  peto,
  casco,
  espinilleras,
  antebraceras,
  bucal,
  cinta,
  otro,
}

/// M5 · Estado de liquidación y entrega física de un pedido de equipo.
enum EstadoEntregaEquipo {
  pendientePago,
  pagadoPendienteEntrega,
  entregado,
  cancelado,
}

/// M5 · Producto y variante de talla dentro del inventario del dojang.
class ProductoEquipo {
  final String id;
  final String academiaId;
  final String nombre;
  final CategoriaEquipo categoria;
  final String talla;
  final int precioCentavos;
  final int existencias;
  final bool activo;

  ProductoEquipo({
    required this.id,
    required this.academiaId,
    required this.nombre,
    required this.categoria,
    required this.talla,
    required this.precioCentavos,
    required this.existencias,
    this.activo = true,
  }) {
    if (precioCentavos < 0) {
      throw ArgumentError.value(
        precioCentavos,
        'precioCentavos',
        'El precio no puede ser negativo.',
      );
    }
    if (existencias < 0) {
      throw ArgumentError.value(
        existencias,
        'existencias',
        'Las existencias no pueden ser negativas.',
      );
    }
  }

  ProductoEquipo copyWith({
    String? id,
    String? academiaId,
    String? nombre,
    CategoriaEquipo? categoria,
    String? talla,
    int? precioCentavos,
    int? existencias,
    bool? activo,
  }) {
    return ProductoEquipo(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      talla: talla ?? this.talla,
      precioCentavos: precioCentavos ?? this.precioCentavos,
      existencias: existencias ?? this.existencias,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'nombre': nombre,
        'categoria': categoria.name,
        'talla': talla,
        'precioCentavos': precioCentavos,
        'existencias': existencias,
        'activo': activo,
      };

  factory ProductoEquipo.fromJson(Map<String, dynamic> json) {
    return ProductoEquipo(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      nombre: json['nombre'] as String,
      categoria: CategoriaEquipo.values.byName(json['categoria'] as String),
      talla: json['talla'] as String,
      precioCentavos: json['precioCentavos'] as int,
      existencias: json['existencias'] as int,
      activo: (json['activo'] as bool?) ?? true,
    );
  }
}

/// M5 · Pedido de uniforme o equipo vinculado a un cargo en caja.
///
/// Regla de negocio: al liquidarse el cargo vinculado, [estadoEntrega] pasa
/// automáticamente a [EstadoEntregaEquipo.pagadoPendienteEntrega]. Solo se
/// puede marcar como [EstadoEntregaEquipo.entregado] si está pagado.
class PedidoEquipo {
  final String id;
  final String academiaId;
  final String alumnoId;
  final String tutorId;
  final String productoId;
  final String nombreProductoSnapshot;
  final String tallaSnapshot;
  final int cantidad;
  final int precioUnitarioCentavos;
  final int totalCentavos;
  final String cargoId;
  final EstadoEntregaEquipo estadoEntrega;
  final String creadoEnIso;
  final String? entregadoEnIsoOpcional;

  PedidoEquipo({
    required this.id,
    required this.academiaId,
    required this.alumnoId,
    required this.tutorId,
    required this.productoId,
    required this.nombreProductoSnapshot,
    required this.tallaSnapshot,
    required this.cantidad,
    required this.precioUnitarioCentavos,
    required this.totalCentavos,
    required this.cargoId,
    required this.estadoEntrega,
    required this.creadoEnIso,
    this.entregadoEnIsoOpcional,
  }) {
    if (cantidad <= 0) {
      throw ArgumentError.value(
        cantidad,
        'cantidad',
        'La cantidad del pedido debe ser al menos 1.',
      );
    }
    if (precioUnitarioCentavos < 0 || totalCentavos < 0) {
      throw ArgumentError('Los precios del pedido no pueden ser negativos.');
    }
  }

  PedidoEquipo copyWith({
    String? id,
    String? academiaId,
    String? alumnoId,
    String? tutorId,
    String? productoId,
    String? nombreProductoSnapshot,
    String? tallaSnapshot,
    int? cantidad,
    int? precioUnitarioCentavos,
    int? totalCentavos,
    String? cargoId,
    EstadoEntregaEquipo? estadoEntrega,
    String? creadoEnIso,
    String? entregadoEnIsoOpcional,
  }) {
    return PedidoEquipo(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      alumnoId: alumnoId ?? this.alumnoId,
      tutorId: tutorId ?? this.tutorId,
      productoId: productoId ?? this.productoId,
      nombreProductoSnapshot:
          nombreProductoSnapshot ?? this.nombreProductoSnapshot,
      tallaSnapshot: tallaSnapshot ?? this.tallaSnapshot,
      cantidad: cantidad ?? this.cantidad,
      precioUnitarioCentavos:
          precioUnitarioCentavos ?? this.precioUnitarioCentavos,
      totalCentavos: totalCentavos ?? this.totalCentavos,
      cargoId: cargoId ?? this.cargoId,
      estadoEntrega: estadoEntrega ?? this.estadoEntrega,
      creadoEnIso: creadoEnIso ?? this.creadoEnIso,
      entregadoEnIsoOpcional:
          entregadoEnIsoOpcional ?? this.entregadoEnIsoOpcional,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'alumnoId': alumnoId,
        'tutorId': tutorId,
        'productoId': productoId,
        'nombreProductoSnapshot': nombreProductoSnapshot,
        'tallaSnapshot': tallaSnapshot,
        'cantidad': cantidad,
        'precioUnitarioCentavos': precioUnitarioCentavos,
        'totalCentavos': totalCentavos,
        'cargoId': cargoId,
        'estadoEntrega': estadoEntrega.name,
        'creadoEnIso': creadoEnIso,
        'entregadoEnIsoOpcional': entregadoEnIsoOpcional,
      };

  factory PedidoEquipo.fromJson(Map<String, dynamic> json) {
    return PedidoEquipo(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      alumnoId: json['alumnoId'] as String,
      tutorId: json['tutorId'] as String,
      productoId: json['productoId'] as String,
      nombreProductoSnapshot: json['nombreProductoSnapshot'] as String,
      tallaSnapshot: json['tallaSnapshot'] as String,
      cantidad: json['cantidad'] as int,
      precioUnitarioCentavos: json['precioUnitarioCentavos'] as int,
      totalCentavos: json['totalCentavos'] as int,
      cargoId: json['cargoId'] as String,
      estadoEntrega:
          EstadoEntregaEquipo.values.byName(json['estadoEntrega'] as String),
      creadoEnIso: json['creadoEnIso'] as String,
      entregadoEnIsoOpcional: json['entregadoEnIsoOpcional'] as String?,
    );
  }
}
