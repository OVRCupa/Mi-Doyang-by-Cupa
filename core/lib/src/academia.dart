import 'reglas_color.dart';

/// Formatea un monto expresado en centavos (`int`) al formato oficial
/// de pesos mexicanos de Mi Doyang by Cupa: `$1,250.00 MXN`.
///
/// Todos los importes monetarios del motor se almacenan en centavos enteros
/// para evitar errores de punto flotante.
String formatearMxn(int centavos) {
  final esNegativo = centavos < 0;
  final absoluto = centavos.abs();
  final pesos = absoluto ~/ 100;
  final centavosRestantes = (absoluto % 100).toString().padLeft(2, '0');

  final cadenaPesos = pesos.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < cadenaPesos.length; i++) {
    final indiceDesdeDerecha = cadenaPesos.length - i;
    buffer.write(cadenaPesos[i]);
    if (indiceDesdeDerecha > 1 && indiceDesdeDerecha % 3 == 1) {
      buffer.write(',');
    }
  }

  final signo = esNegativo ? '-' : '';
  return '$signo\$${buffer.toString()}.$centavosRestantes MXN';
}

/// M1 · Configuración e identidad visual/financiera de la academia (Dojang).
class AcademiaConfig {
  final String id;
  final String nombre;
  final String lema;
  final String telefono;
  final String direccion;
  final String? rfcOpcional;
  final String colorPrimarioHex;
  final String prefijoCaja;
  final int diaLimitePago;
  final int mensualidadBaseCentavos;
  final int inscripcionCentavos;
  final int recargoMoraCentavos;
  final int descuentoSegundoHermanoPct;
  final int descuentoTercerHermanoPct;
  final String leyendaTicket;

  AcademiaConfig({
    required this.id,
    required this.nombre,
    required this.lema,
    required this.telefono,
    required this.direccion,
    this.rfcOpcional,
    required this.colorPrimarioHex,
    required this.prefijoCaja,
    required this.diaLimitePago,
    required this.mensualidadBaseCentavos,
    required this.inscripcionCentavos,
    required this.recargoMoraCentavos,
    required this.descuentoSegundoHermanoPct,
    required this.descuentoTercerHermanoPct,
    this.leyendaTicket =
        'Comprobante interno de control escolar — Este documento no es un comprobante fiscal CFDI.',
  }) {
    if (diaLimitePago < 1 || diaLimitePago > 28) {
      throw ArgumentError.value(
        diaLimitePago,
        'diaLimitePago',
        'El día límite de pago debe estar entre 1 y 28.',
      );
    }
    if (mensualidadBaseCentavos < 0 ||
        inscripcionCentavos < 0 ||
        recargoMoraCentavos < 0) {
      throw ArgumentError('Los montos en centavos no pueden ser negativos.');
    }
    if (descuentoSegundoHermanoPct < 0 ||
        descuentoSegundoHermanoPct > 100 ||
        descuentoTercerHermanoPct < 0 ||
        descuentoTercerHermanoPct > 100) {
      throw ArgumentError(
        'Los porcentajes de descuento familiar deben estar entre 0 y 100.',
      );
    }
    // Valida que el color primario sea un hexadecimal válido.
    hexAArgb(colorPrimarioHex);
  }

  /// Devuelve el color primario ajustado automáticamente para cumplir
  /// contraste WCAG 2.1 AA (>= 4.5:1) sobre texto claro `#F7F5F0`.
  String get colorPrimarioSobreTextoClaroHex => asegurarContrasteHexWcagAA(
        colorPrimarioHex,
        fondoHex: '#F7F5F0',
        minimo: 4.5,
      );

  AcademiaConfig copyWith({
    String? id,
    String? nombre,
    String? lema,
    String? telefono,
    String? direccion,
    String? rfcOpcional,
    bool limpiarRfc = false,
    String? colorPrimarioHex,
    String? prefijoCaja,
    int? diaLimitePago,
    int? mensualidadBaseCentavos,
    int? inscripcionCentavos,
    int? recargoMoraCentavos,
    int? descuentoSegundoHermanoPct,
    int? descuentoTercerHermanoPct,
    String? leyendaTicket,
  }) {
    return AcademiaConfig(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      lema: lema ?? this.lema,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rfcOpcional: limpiarRfc ? null : (rfcOpcional ?? this.rfcOpcional),
      colorPrimarioHex: colorPrimarioHex ?? this.colorPrimarioHex,
      prefijoCaja: prefijoCaja ?? this.prefijoCaja,
      diaLimitePago: diaLimitePago ?? this.diaLimitePago,
      mensualidadBaseCentavos:
          mensualidadBaseCentavos ?? this.mensualidadBaseCentavos,
      inscripcionCentavos: inscripcionCentavos ?? this.inscripcionCentavos,
      recargoMoraCentavos: recargoMoraCentavos ?? this.recargoMoraCentavos,
      descuentoSegundoHermanoPct:
          descuentoSegundoHermanoPct ?? this.descuentoSegundoHermanoPct,
      descuentoTercerHermanoPct:
          descuentoTercerHermanoPct ?? this.descuentoTercerHermanoPct,
      leyendaTicket: leyendaTicket ?? this.leyendaTicket,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'nombre': nombre,
        'lema': lema,
        'telefono': telefono,
        'direccion': direccion,
        'rfcOpcional': rfcOpcional,
        'colorPrimarioHex': colorPrimarioHex,
        'prefijoCaja': prefijoCaja,
        'diaLimitePago': diaLimitePago,
        'mensualidadBaseCentavos': mensualidadBaseCentavos,
        'inscripcionCentavos': inscripcionCentavos,
        'recargoMoraCentavos': recargoMoraCentavos,
        'descuentoSegundoHermanoPct': descuentoSegundoHermanoPct,
        'descuentoTercerHermanoPct': descuentoTercerHermanoPct,
        'leyendaTicket': leyendaTicket,
      };

  factory AcademiaConfig.fromJson(Map<String, dynamic> json) {
    return AcademiaConfig(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      lema: json['lema'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      rfcOpcional: json['rfcOpcional'] as String?,
      colorPrimarioHex: json['colorPrimarioHex'] as String,
      prefijoCaja: json['prefijoCaja'] as String,
      diaLimitePago: json['diaLimitePago'] as int,
      mensualidadBaseCentavos: json['mensualidadBaseCentavos'] as int,
      inscripcionCentavos: json['inscripcionCentavos'] as int,
      recargoMoraCentavos: json['recargoMoraCentavos'] as int,
      descuentoSegundoHermanoPct: json['descuentoSegundoHermanoPct'] as int,
      descuentoTercerHermanoPct: json['descuentoTercerHermanoPct'] as int,
      leyendaTicket: (json['leyendaTicket'] as String?) ??
          'Comprobante interno de control escolar — Este documento no es un comprobante fiscal CFDI.',
    );
  }
}

/// M1 · Grado / Cinta del escalafón de Taekwondo configurable por la academia.
class GradoCinta {
  final String id;
  final int orden;
  final String codigo;
  final String nombre;
  final String colorBaseHex;
  final String? colorPuntaHex;
  final bool esPoom;
  final int mesesMinimos;
  final int asistenciasMinimas;
  final int costoExamenCentavos;

  GradoCinta({
    required this.id,
    required this.orden,
    required this.codigo,
    required this.nombre,
    required this.colorBaseHex,
    this.colorPuntaHex,
    this.esPoom = false,
    required this.mesesMinimos,
    required this.asistenciasMinimas,
    required this.costoExamenCentavos,
  }) {
    if (orden < 1) {
      throw ArgumentError.value(orden, 'orden', 'El orden debe ser >= 1.');
    }
    if (mesesMinimos < 0 ||
        asistenciasMinimas < 0 ||
        costoExamenCentavos < 0) {
      throw ArgumentError(
        'Los requisitos y costos del grado no pueden ser negativos.',
      );
    }
    hexAArgb(colorBaseHex);
    if (colorPuntaHex != null) {
      hexAArgb(colorPuntaHex!);
    }
  }

  bool get tienePunta => colorPuntaHex != null && colorPuntaHex!.isNotEmpty;

  /// En el escalafón de Taekwondo Kup, las cintas avanzadas llevan una franja
  /// horizontal por la mitad a lo largo de la cinta con el color de la
  /// siguiente cinta.
  bool get esAvanzada => tienePunta && !esPoom && !codigo.contains('Dan');
  String? get colorFranjaCentralHex => esAvanzada ? colorPuntaHex : null;

  GradoCinta copyWith({
    String? id,
    int? orden,
    String? codigo,
    String? nombre,
    String? colorBaseHex,
    String? colorPuntaHex,
    bool limpiarPunta = false,
    bool? esPoom,
    int? mesesMinimos,
    int? asistenciasMinimas,
    int? costoExamenCentavos,
  }) {
    return GradoCinta(
      id: id ?? this.id,
      orden: orden ?? this.orden,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      colorBaseHex: colorBaseHex ?? this.colorBaseHex,
      colorPuntaHex:
          limpiarPunta ? null : (colorPuntaHex ?? this.colorPuntaHex),
      esPoom: esPoom ?? this.esPoom,
      mesesMinimos: mesesMinimos ?? this.mesesMinimos,
      asistenciasMinimas: asistenciasMinimas ?? this.asistenciasMinimas,
      costoExamenCentavos: costoExamenCentavos ?? this.costoExamenCentavos,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'orden': orden,
        'codigo': codigo,
        'nombre': nombre,
        'colorBaseHex': colorBaseHex,
        'colorPuntaHex': colorPuntaHex,
        'esPoom': esPoom,
        'mesesMinimos': mesesMinimos,
        'asistenciasMinimas': asistenciasMinimas,
        'costoExamenCentavos': costoExamenCentavos,
      };

  factory GradoCinta.fromJson(Map<String, dynamic> json) {
    return GradoCinta(
      id: json['id'] as String,
      orden: json['orden'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      colorBaseHex: json['colorBaseHex'] as String,
      colorPuntaHex: json['colorPuntaHex'] as String?,
      esPoom: (json['esPoom'] as bool?) ?? false,
      mesesMinimos: json['mesesMinimos'] as int,
      asistenciasMinimas: json['asistenciasMinimas'] as int,
      costoExamenCentavos: json['costoExamenCentavos'] as int,
    );
  }
}

/// Presets y utilidades de escalafón de grados de Taekwondo.
class EscalafonGrados {
  const EscalafonGrados._();

  /// Escalafón oficial de Taekwondo en México (Kup, 1er Poom <15 años y 1er Dan >=15 años).
  /// Las cintas avanzadas llevan una franja horizontal central del color de la siguiente cinta.
  static List<GradoCinta> taekwondoWtMexico() {
    return <GradoCinta>[
      GradoCinta(
        id: 'grado-10-kup',
        orden: 1,
        codigo: '10.º Kup',
        nombre: 'Cinta Blanca',
        colorBaseHex: '#F4F2ED',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 0,
        asistenciasMinimas: 0,
        costoExamenCentavos: 0,
      ),
      GradoCinta(
        id: 'grado-10-kup-av',
        orden: 2,
        codigo: '10.º Kup Av.',
        nombre: 'Cinta Blanca Avanzada',
        colorBaseHex: '#F4F2ED',
        colorPuntaHex: '#EA580C', // Siguiente: Naranja
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 20,
        costoExamenCentavos: 50000,
      ),
      GradoCinta(
        id: 'grado-9-kup',
        orden: 3,
        codigo: '9.º Kup',
        nombre: 'Cinta Naranja',
        colorBaseHex: '#EA580C',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 20,
        costoExamenCentavos: 50000,
      ),
      GradoCinta(
        id: 'grado-8-kup',
        orden: 4,
        codigo: '8.º Kup',
        nombre: 'Cinta Amarilla',
        colorBaseHex: '#EAB308',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 20,
        costoExamenCentavos: 55000,
      ),
      GradoCinta(
        id: 'grado-7-kup',
        orden: 5,
        codigo: '7.º Kup',
        nombre: 'Cinta Amarilla Avanzada',
        colorBaseHex: '#EAB308',
        colorPuntaHex: '#16803C', // Siguiente: Verde
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 22,
        costoExamenCentavos: 55000,
      ),
      GradoCinta(
        id: 'grado-6-kup',
        orden: 6,
        codigo: '6.º Kup',
        nombre: 'Cinta Verde',
        colorBaseHex: '#16803C',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 24,
        costoExamenCentavos: 60000,
      ),
      GradoCinta(
        id: 'grado-5-kup',
        orden: 7,
        codigo: '5.º Kup',
        nombre: 'Cinta Verde Avanzada',
        colorBaseHex: '#16803C',
        colorPuntaHex: '#1D4ED8', // Siguiente: Azul
        esPoom: false,
        mesesMinimos: 3,
        asistenciasMinimas: 24,
        costoExamenCentavos: 65000,
      ),
      GradoCinta(
        id: 'grado-4-kup',
        orden: 8,
        codigo: '4.º Kup',
        nombre: 'Cinta Azul',
        colorBaseHex: '#1D4ED8',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 4,
        asistenciasMinimas: 26,
        costoExamenCentavos: 70000,
      ),
      GradoCinta(
        id: 'grado-3-kup',
        orden: 9,
        codigo: '3.º Kup',
        nombre: 'Cinta Azul Avanzada',
        colorBaseHex: '#1D4ED8',
        colorPuntaHex: '#78350F', // Siguiente: Marrón
        esPoom: false,
        mesesMinimos: 4,
        asistenciasMinimas: 26,
        costoExamenCentavos: 70000,
      ),
      GradoCinta(
        id: 'grado-2-kup',
        orden: 10,
        codigo: '2.º Kup',
        nombre: 'Cinta Marrón',
        colorBaseHex: '#78350F',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 4,
        asistenciasMinimas: 28,
        costoExamenCentavos: 75000,
      ),
      GradoCinta(
        id: 'grado-2-kup-av',
        orden: 11,
        codigo: '2.º Kup Av.',
        nombre: 'Cinta Marrón Avanzada',
        colorBaseHex: '#78350F',
        colorPuntaHex: '#BC2220', // Siguiente: Roja
        esPoom: false,
        mesesMinimos: 4,
        asistenciasMinimas: 28,
        costoExamenCentavos: 80000,
      ),
      GradoCinta(
        id: 'grado-1-kup',
        orden: 12,
        codigo: '1.º Kup',
        nombre: 'Cinta Roja',
        colorBaseHex: '#BC2220',
        colorPuntaHex: null,
        esPoom: false,
        mesesMinimos: 6,
        asistenciasMinimas: 36,
        costoExamenCentavos: 90000,
      ),
      GradoCinta(
        id: 'grado-1-poom',
        orden: 13,
        codigo: '1.º Poom',
        nombre: 'Negra 1er Poom (Menores de 15 años)',
        colorBaseHex: '#BC2220',
        colorPuntaHex: '#14181F',
        esPoom: true,
        mesesMinimos: 6,
        asistenciasMinimas: 48,
        costoExamenCentavos: 250000,
      ),
      GradoCinta(
        id: 'grado-1-dan',
        orden: 14,
        codigo: '1.º Dan',
        nombre: 'Negra 1er Dan (Mayores de 15 años)',
        colorBaseHex: '#14181F',
        colorPuntaHex: '#D4AF37',
        esPoom: false,
        mesesMinimos: 6,
        asistenciasMinimas: 48,
        costoExamenCentavos: 250000,
      ),
    ];
  }
}
