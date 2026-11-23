import 'dart:math' as math;

import 'academia.dart';
import 'familia_alumnos.dart';

/// M3 · Tipos de cargo posibles en el estado de cuenta familiar.
enum TipoCargo {
  mensualidad,
  inscripcion,
  examenGrado,
  equipo,
  torneo,
  otro,
}

/// M3 · Estado de liquidación de un cargo en cuenta.
enum EstadoCargo {
  pendiente,
  abonadoParcial,
  pagado,
  cancelado,
}

/// M3 · Métodos de pago admitidos en la caja del dojang.
enum MetodoPago {
  efectivo,
  transferencia,
  terminal,
}

/// M3 · Cargo individual o familiar dentro del estado de cuenta.
class CargoCuenta {
  final String id;
  final String academiaId;
  final String tutorId;
  final String? alumnoId;
  final TipoCargo tipo;
  final String concepto;
  final String? periodoOpcional;
  final int subtotalCentavos;
  final int descuentoCentavos;
  final int recargoCentavos;
  final int totalCentavos;
  final int pagadoCentavos;
  final int saldoCentavos;
  final String fechaVencimientoIso;
  final String? referenciaOrigenId;
  final EstadoCargo estado;

  CargoCuenta({
    required this.id,
    required this.academiaId,
    required this.tutorId,
    this.alumnoId,
    required this.tipo,
    required this.concepto,
    this.periodoOpcional,
    required this.subtotalCentavos,
    this.descuentoCentavos = 0,
    this.recargoCentavos = 0,
    required this.totalCentavos,
    this.pagadoCentavos = 0,
    required this.saldoCentavos,
    required this.fechaVencimientoIso,
    this.referenciaOrigenId,
    required this.estado,
  }) {
    if (subtotalCentavos < 0 ||
        descuentoCentavos < 0 ||
        recargoCentavos < 0 ||
        totalCentavos < 0 ||
        pagadoCentavos < 0 ||
        saldoCentavos < 0) {
      throw ArgumentError('Los montos de un cargo no pueden ser negativos.');
    }
  }

  bool get estaLiquidado => estado == EstadoCargo.pagado && saldoCentavos == 0;

  CargoCuenta copyWith({
    String? id,
    String? academiaId,
    String? tutorId,
    String? alumnoId,
    bool limpiarAlumnoId = false,
    TipoCargo? tipo,
    String? concepto,
    String? periodoOpcional,
    int? subtotalCentavos,
    int? descuentoCentavos,
    int? recargoCentavos,
    int? totalCentavos,
    int? pagadoCentavos,
    int? saldoCentavos,
    String? fechaVencimientoIso,
    String? referenciaOrigenId,
    EstadoCargo? estado,
  }) {
    return CargoCuenta(
      id: id ?? this.id,
      academiaId: academiaId ?? this.academiaId,
      tutorId: tutorId ?? this.tutorId,
      alumnoId: limpiarAlumnoId ? null : (alumnoId ?? this.alumnoId),
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
      periodoOpcional: periodoOpcional ?? this.periodoOpcional,
      subtotalCentavos: subtotalCentavos ?? this.subtotalCentavos,
      descuentoCentavos: descuentoCentavos ?? this.descuentoCentavos,
      recargoCentavos: recargoCentavos ?? this.recargoCentavos,
      totalCentavos: totalCentavos ?? this.totalCentavos,
      pagadoCentavos: pagadoCentavos ?? this.pagadoCentavos,
      saldoCentavos: saldoCentavos ?? this.saldoCentavos,
      fechaVencimientoIso: fechaVencimientoIso ?? this.fechaVencimientoIso,
      referenciaOrigenId: referenciaOrigenId ?? this.referenciaOrigenId,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'academiaId': academiaId,
        'tutorId': tutorId,
        'alumnoId': alumnoId,
        'tipo': tipo.name,
        'concepto': concepto,
        'periodoOpcional': periodoOpcional,
        'subtotalCentavos': subtotalCentavos,
        'descuentoCentavos': descuentoCentavos,
        'recargoCentavos': recargoCentavos,
        'totalCentavos': totalCentavos,
        'pagadoCentavos': pagadoCentavos,
        'saldoCentavos': saldoCentavos,
        'fechaVencimientoIso': fechaVencimientoIso,
        'referenciaOrigenId': referenciaOrigenId,
        'estado': estado.name,
      };

  factory CargoCuenta.fromJson(Map<String, dynamic> json) {
    return CargoCuenta(
      id: json['id'] as String,
      academiaId: json['academiaId'] as String,
      tutorId: json['tutorId'] as String,
      alumnoId: json['alumnoId'] as String?,
      tipo: TipoCargo.values.byName(json['tipo'] as String),
      concepto: json['concepto'] as String,
      periodoOpcional: json['periodoOpcional'] as String?,
      subtotalCentavos: json['subtotalCentavos'] as int,
      descuentoCentavos: (json['descuentoCentavos'] as int?) ?? 0,
      recargoCentavos: (json['recargoCentavos'] as int?) ?? 0,
      totalCentavos: json['totalCentavos'] as int,
      pagadoCentavos: (json['pagadoCentavos'] as int?) ?? 0,
      saldoCentavos: json['saldoCentavos'] as int,
      fechaVencimientoIso: json['fechaVencimientoIso'] as String,
      referenciaOrigenId: json['referenciaOrigenId'] as String?,
      estado: EstadoCargo.values.byName(json['estado'] as String),
    );
  }
}

/// M3 · Línea de desglose dentro de un [TicketPago].
class LineaTicket {
  final String cargoId;
  final String alumnoNombre;
  final String concepto;
  final int montoAbonadoCentavos;
  final int saldoRestanteCargoCentavos;

  LineaTicket({
    required this.cargoId,
    required this.alumnoNombre,
    required this.concepto,
    required this.montoAbonadoCentavos,
    required this.saldoRestanteCargoCentavos,
  }) {
    if (montoAbonadoCentavos <= 0) {
      throw ArgumentError.value(
        montoAbonadoCentavos,
        'montoAbonadoCentavos',
        'El monto abonado en una línea de ticket debe ser mayor a 0 centavos.',
      );
    }
    if (saldoRestanteCargoCentavos < 0) {
      throw ArgumentError.value(
        saldoRestanteCargoCentavos,
        'saldoRestanteCargoCentavos',
        'El saldo restante de un cargo no puede ser negativo.',
      );
    }
  }

  LineaTicket copyWith({
    String? cargoId,
    String? alumnoNombre,
    String? concepto,
    int? montoAbonadoCentavos,
    int? saldoRestanteCargoCentavos,
  }) {
    return LineaTicket(
      cargoId: cargoId ?? this.cargoId,
      alumnoNombre: alumnoNombre ?? this.alumnoNombre,
      concepto: concepto ?? this.concepto,
      montoAbonadoCentavos: montoAbonadoCentavos ?? this.montoAbonadoCentavos,
      saldoRestanteCargoCentavos:
          saldoRestanteCargoCentavos ?? this.saldoRestanteCargoCentavos,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cargoId': cargoId,
        'alumnoNombre': alumnoNombre,
        'concepto': concepto,
        'montoAbonadoCentavos': montoAbonadoCentavos,
        'saldoRestanteCargoCentavos': saldoRestanteCargoCentavos,
      };

  factory LineaTicket.fromJson(Map<String, dynamic> json) {
    return LineaTicket(
      cargoId: json['cargoId'] as String,
      alumnoNombre: json['alumnoNombre'] as String,
      concepto: json['concepto'] as String,
      montoAbonadoCentavos: json['montoAbonadoCentavos'] as int,
      saldoRestanteCargoCentavos: json['saldoRestanteCargoCentavos'] as int,
    );
  }
}

final RegExp _patronPanTarjeta = RegExp(
  r'(?<!\d)(?:\d[\s._/-]*){12,18}\d(?!\d)',
);
final RegExp _patronCvvExplicito = RegExp(
  r'\b(?:cvv2?|cvc2?|cid|c[oó]d(?:igo)?\.?\s*(?:de\s*)?seg(?:uridad)?)\b[\s.:#=()-]*\d{3,4}\b',
  caseSensitive: false,
);

/// Valida que [referenciaPagoOpcional] no contenga un número de tarjeta
/// bancaria (PAN de 13 a 19 dígitos) ni un código de seguridad CVV/CVC.
///
/// Lanza [ViolacionPrivacidadException] si detecta datos financieros prohibidos
/// conforme a `docs/privacidad.md`.
void validarReferenciaPagoSegura(String? referenciaPagoOpcional) {
  if (referenciaPagoOpcional == null || referenciaPagoOpcional.trim().isEmpty) {
    return;
  }
  final texto = referenciaPagoOpcional.trim();
  if (_patronCvvExplicito.hasMatch(texto)) {
    throw ViolacionPrivacidadException(
      'Prohibido almacenar códigos CVV/CVC en la referencia de pago.',
    );
  }
  for (final coincidencia in _patronPanTarjeta.allMatches(texto)) {
    final soloDigitos =
        coincidencia.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
    if (soloDigitos.length >= 13 && soloDigitos.length <= 19) {
      throw ViolacionPrivacidadException(
        'Prohibido almacenar números de tarjeta bancaria (PAN de 13 a 19 dígitos) en la referencia de pago. Registra únicamente los últimos 4 dígitos o el código de autorización.',
      );
    }
  }
}

/// M3 · Ticket de Comprobante de Pago inmutable (D-05, D-06).
///
/// Un ticket emitido nunca altera sus montos ni folios; en caso de error,
/// solo puede marcarse como cancelado con motivo obligatorio y folio de reverso,
/// o disociarse por solicitud de cancelación ARCO conservando su suma contable.
class TicketPago {
  final String id;
  final String folio;
  final String academiaId;
  final String tutorId;
  final String emitidoEnIso;
  final MetodoPago metodoPago;
  final String? referenciaPagoOpcional;
  final List<LineaTicket> lineas;
  final int totalPagadoCentavos;
  final String cajeroUsuarioId;
  final bool cancelado;
  final String? motivoCancelacionOpcional;
  final String? folioReversoOpcional;
  final bool sincronizadoNube;
  final String codigoVerificacionQr;

  TicketPago({
    required this.id,
    required this.folio,
    required this.academiaId,
    required this.tutorId,
    required this.emitidoEnIso,
    required this.metodoPago,
    this.referenciaPagoOpcional,
    required List<LineaTicket> lineas,
    required this.totalPagadoCentavos,
    required this.cajeroUsuarioId,
    this.cancelado = false,
    this.motivoCancelacionOpcional,
    this.folioReversoOpcional,
    this.sincronizadoNube = false,
    required this.codigoVerificacionQr,
  }) : lineas = List<LineaTicket>.unmodifiable(lineas) {
    validarReferenciaPagoSegura(referenciaPagoOpcional);
    if (totalPagadoCentavos <= 0) {
      throw ArgumentError.value(
        totalPagadoCentavos,
        'totalPagadoCentavos',
        'El total pagado del ticket debe ser mayor a cero.',
      );
    }
    if (this.lineas.isEmpty) {
      throw ArgumentError(
        'Un ticket de pago debe contener al menos una línea de concepto.',
      );
    }
    final sumaLineas = this.lineas.fold<int>(
      0,
      (suma, l) => suma + l.montoAbonadoCentavos,
    );
    if (sumaLineas != totalPagadoCentavos) {
      throw ArgumentError(
        'La suma de líneas ($sumaLineas) no coincide con totalPagadoCentavos ($totalPagadoCentavos).',
      );
    }
    if (cancelado &&
        (motivoCancelacionOpcional == null ||
            motivoCancelacionOpcional!.trim().isEmpty)) {
      throw ArgumentError(
        'Un ticket cancelado requiere motivoCancelacionOpcional obligatorio.',
      );
    }
  }

  /// Crea una copia controlada (para sincronización offline, cancelación con
  /// reverso o disociación contable ARCO) manteniendo inmutables los importes.
  TicketPago copyWith({
    String? tutorId,
    List<LineaTicket>? lineas,
    bool? cancelado,
    String? motivoCancelacionOpcional,
    String? folioReversoOpcional,
    bool? sincronizadoNube,
  }) {
    return TicketPago(
      id: id,
      folio: folio,
      academiaId: academiaId,
      tutorId: tutorId ?? this.tutorId,
      emitidoEnIso: emitidoEnIso,
      metodoPago: metodoPago,
      referenciaPagoOpcional: referenciaPagoOpcional,
      lineas: lineas ?? this.lineas,
      totalPagadoCentavos: totalPagadoCentavos,
      cajeroUsuarioId: cajeroUsuarioId,
      cancelado: cancelado ?? this.cancelado,
      motivoCancelacionOpcional:
          motivoCancelacionOpcional ?? this.motivoCancelacionOpcional,
      folioReversoOpcional: folioReversoOpcional ?? this.folioReversoOpcional,
      sincronizadoNube: sincronizadoNube ?? this.sincronizadoNube,
      codigoVerificacionQr: codigoVerificacionQr,
    );
  }

  /// Renderiza el ticket en texto monoespaciado tabular para impresoras
  /// térmicas de 58 mm (`anchoColumnas = 32`) u 80 mm (`anchoColumnas = 48`).
  String renderizarTicketTermico({
    int anchoColumnas = 48,
    String nombreAcademia = 'MI DOYANG BY CUPA',
    String? telefonoAcademia,
    String? direccionAcademia,
    String leyendaPie =
        'Comprobante interno de control escolar — Este documento no es un comprobante fiscal CFDI.',
  }) {
    if (anchoColumnas < 24) {
      throw ArgumentError.value(
        anchoColumnas,
        'anchoColumnas',
        'El ancho mínimo soportado es 24 columnas (32 para 58mm, 48 para 80mm).',
      );
    }

    final separador = '-' * anchoColumnas;
    final separadorDoble = '=' * anchoColumnas;
    final salida = <String>[];

    void agregarCentrado(String texto) {
      for (final linea in _envolverTexto(texto, anchoColumnas)) {
        final espaciosIzq = math.max(0, (anchoColumnas - linea.length) ~/ 2);
        salida.add('${' ' * espaciosIzq}$linea');
      }
    }

    void agregarEnvuelto(String texto) {
      salida.addAll(_envolverTexto(texto, anchoColumnas));
    }

    void agregarParAlineado(String izquierda, String derecha) {
      final espacioDisponibleIzq =
          math.max(8, anchoColumnas - derecha.length - 1);
      final partesIzq = _envolverTexto(izquierda, espacioDisponibleIzq);
      for (var i = 0; i < partesIzq.length; i++) {
        if (i < partesIzq.length - 1) {
          salida.add(partesIzq[i]);
        } else {
          final ultima = partesIzq[i];
          final relleno =
              math.max(1, anchoColumnas - ultima.length - derecha.length);
          salida.add('$ultima${' ' * relleno}$derecha');
        }
      }
    }

    final alumnosUnicos = lineas
        .map((l) => l.alumnoNombre.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .join(', ');

    salida.add(separadorDoble);
    agregarCentrado(nombreAcademia.toUpperCase());
    if (direccionAcademia != null && direccionAcademia.trim().isNotEmpty) {
      agregarCentrado(direccionAcademia.trim());
    }
    if (telefonoAcademia != null && telefonoAcademia.trim().isNotEmpty) {
      agregarCentrado('Tel: ${telefonoAcademia.trim()}');
    }
    salida.add(separador);
    agregarEnvuelto('Folio: $folio');
    agregarEnvuelto('Fecha: $emitidoEnIso');
    agregarEnvuelto(
      'Alumno(s): ${alumnosUnicos.isEmpty ? "General" : alumnosUnicos}',
    );
    agregarCentrado('(IMPORTES EN MXN)');
    salida.add(separador);

    for (final linea in lineas) {
      final montoTexto = formatearMxn(linea.montoAbonadoCentavos);
      agregarParAlineado(
        '${linea.concepto} (${linea.alumnoNombre})',
        montoTexto,
      );
      if (linea.saldoRestanteCargoCentavos > 0) {
        agregarParAlineado(
          '  Saldo pendiente:',
          formatearMxn(linea.saldoRestanteCargoCentavos),
        );
      }
    }

    salida.add(separador);
    agregarParAlineado(
      'TOTAL PAGADO',
      formatearMxn(totalPagadoCentavos),
    );
    agregarEnvuelto('Metodo: ${_etiquetaMetodoPago(metodoPago)}');
    if (referenciaPagoOpcional != null &&
        referenciaPagoOpcional!.trim().isNotEmpty) {
      agregarEnvuelto('Ref: ${referenciaPagoOpcional!.trim()}');
    }
    salida.add(separador);
    agregarCentrado(cancelado ? '[CANCELADO]' : '[PAGADO]');
    if (cancelado) {
      if (folioReversoOpcional != null) {
        agregarCentrado('Reverso: $folioReversoOpcional');
      }
      if (motivoCancelacionOpcional != null) {
        agregarEnvuelto('Motivo: $motivoCancelacionOpcional');
      }
    }
    agregarEnvuelto('QR: $codigoVerificacionQr');
    salida.add(separador);
    agregarCentrado(leyendaPie);
    salida.add(separadorDoble);

    return salida.join('\n');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'folio': folio,
        'academiaId': academiaId,
        'tutorId': tutorId,
        'emitidoEnIso': emitidoEnIso,
        'metodoPago': metodoPago.name,
        'referenciaPagoOpcional': referenciaPagoOpcional,
        'lineas': lineas.map((l) => l.toJson()).toList(),
        'totalPagadoCentavos': totalPagadoCentavos,
        'cajeroUsuarioId': cajeroUsuarioId,
        'cancelado': cancelado,
        'motivoCancelacionOpcional': motivoCancelacionOpcional,
        'folioReversoOpcional': folioReversoOpcional,
        'sincronizadoNube': sincronizadoNube,
        'codigoVerificacionQr': codigoVerificacionQr,
      };

  factory TicketPago.fromJson(Map<String, dynamic> json) {
    return TicketPago(
      id: json['id'] as String,
      folio: json['folio'] as String,
      academiaId: json['academiaId'] as String,
      tutorId: json['tutorId'] as String,
      emitidoEnIso: json['emitidoEnIso'] as String,
      metodoPago: MetodoPago.values.byName(json['metodoPago'] as String),
      referenciaPagoOpcional: json['referenciaPagoOpcional'] as String?,
      lineas: (json['lineas'] as List<dynamic>)
          .map(
            (item) =>
                LineaTicket.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      totalPagadoCentavos: json['totalPagadoCentavos'] as int,
      cajeroUsuarioId: json['cajeroUsuarioId'] as String,
      cancelado: (json['cancelado'] as bool?) ?? false,
      motivoCancelacionOpcional: json['motivoCancelacionOpcional'] as String?,
      folioReversoOpcional: json['folioReversoOpcional'] as String?,
      sincronizadoNube: (json['sincronizadoNube'] as bool?) ?? false,
      codigoVerificacionQr: json['codigoVerificacionQr'] as String,
    );
  }
}

String _etiquetaMetodoPago(MetodoPago metodo) {
  switch (metodo) {
    case MetodoPago.efectivo:
      return 'Efectivo';
    case MetodoPago.transferencia:
      return 'Transferencia SPEI';
    case MetodoPago.terminal:
      return 'Terminal Externa';
  }
}

List<String> _envolverTexto(String texto, int anchoMaximo) {
  final limpio = texto.trim();
  if (limpio.isEmpty) {
    return <String>[''];
  }
  if (limpio.length <= anchoMaximo) {
    return <String>[limpio];
  }
  final palabras = limpio.split(RegExp(r'\s+'));
  final lineas = <String>[];
  var actual = '';

  for (final palabra in palabras) {
    if (palabra.length > anchoMaximo) {
      if (actual.isNotEmpty) {
        lineas.add(actual);
        actual = '';
      }
      var inicio = 0;
      while (inicio < palabra.length) {
        final fin = math.min(inicio + anchoMaximo, palabra.length);
        lineas.add(palabra.substring(inicio, fin));
        inicio = fin;
      }
      continue;
    }

    if (actual.isEmpty) {
      actual = palabra;
    } else if (actual.length + 1 + palabra.length <= anchoMaximo) {
      actual = '$actual $palabra';
    } else {
      lineas.add(actual);
      actual = palabra;
    }
  }
  if (actual.isNotEmpty) {
    lineas.add(actual);
  }
  return lineas;
}
