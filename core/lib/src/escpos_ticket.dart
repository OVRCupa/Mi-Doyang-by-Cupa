import 'dart:typed_data';

import 'academia.dart';
import 'caja_tickets.dart';

/// Generador de comandos binarios **ESC/POS** para impresoras térmicas de
/// 58 mm (32 columnas) y 80 mm (48 columnas), en Dart puro sin dependencias
/// nativas externas (D-06, D-09).
Uint8List generarBytesEscPosTicket({
  required TicketPago ticket,
  required AcademiaConfig academia,
  int anchoColumnas = 48,
  bool cortarPapel = true,
}) {
  final cols = anchoColumnas <= 32 ? 32 : 48;
  final bytes = <int>[];

  // ESC @ — Inicializar impresora térmica
  bytes.addAll(const <int>[0x1B, 0x40]);
  // ESC t 2 — Tabla de caracteres PC850 / Latin-1 básica
  bytes.addAll(const <int>[0x1B, 0x74, 0x02]);

  // Centrar encabezado en negrita y doble altura
  bytes.addAll(const <int>[0x1B, 0x61, 0x01]); // Centrado
  bytes.addAll(const <int>[0x1B, 0x45, 0x01]); // Negrita ON
  bytes.addAll(const <int>[0x1D, 0x21, 0x01]); // Doble altura
  bytes.addAll(_codificarAsciiSeguro(academia.nombre.toUpperCase()));
  bytes.add(0x0A);
  bytes.addAll(const <int>[0x1D, 0x21, 0x00]); // Tamaño normal
  bytes.addAll(const <int>[0x1B, 0x45, 0x00]); // Negrita OFF

  // Cuerpo del ticket alineado a la izquierda
  bytes.addAll(const <int>[0x1B, 0x61, 0x00]); // Izquierda
  final texto = ticket.renderizarTicketTermico(
    anchoColumnas: cols,
    nombreAcademia: academia.nombre,
  );
  for (final linea in texto.split('\n')) {
    bytes.addAll(_codificarAsciiSeguro(linea));
    bytes.add(0x0A);
  }

  // Código QR nativo ESC/POS (GS ( k) centrado
  bytes.addAll(const <int>[0x1B, 0x61, 0x01]); // Centrado
  bytes.addAll(_comandoQrEscPos(ticket.codigoVerificacionQr));
  bytes.addAll(const <int>[0x0A, 0x0A, 0x0A]);

  // Corte parcial de papel (GS V 66 0)
  if (cortarPapel) {
    bytes.addAll(const <int>[0x1D, 0x56, 0x42, 0x00]);
  }

  return Uint8List.fromList(bytes);
}

/// Genera un comprobante digital en HTML autocontenido (sin recursos externos),
/// listo para imprimir a PDF en Windows/Android o compartir por WhatsApp.
String generarComprobanteHtmlImprimible({
  required TicketPago ticket,
  required AcademiaConfig academia,
}) {
  final sello = ticket.cancelado ? 'CANCELADO' : 'PAGADO';
  final colorSello = ticket.cancelado ? '#B82924' : '#146C43';
  final textoTermico = _escaparHtml(
    ticket.renderizarTicketTermico(
      anchoColumnas: 48,
      nombreAcademia: academia.nombre,
    ),
  );

  return '''<!DOCTYPE html>
<html lang="es-MX">
<head>
<meta charset="utf-8">
<title>Comprobante ${_escaparHtml(ticket.folio)} · ${_escaparHtml(academia.nombre)}</title>
<style>
  body { font-family: "Courier New", Courier, monospace; background: #F7F5F0; color: #14181F; padding: 24px; }
  .ticket { max-width: 420px; margin: 0 auto; background: #FFFFFF; border: 1px solid #D6D1C7; padding: 20px; }
  .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px dashed #4A5260; padding-bottom: 8px; margin-bottom: 12px; }
  .sello { border: 2px solid $colorSello; color: $colorSello; font-weight: bold; padding: 2px 8px; font-size: 13px; }
  pre { margin: 0; font-size: 13px; line-height: 1.4; white-space: pre-wrap; }
  .qr { margin-top: 14px; padding-top: 10px; border-top: 1px dashed #4A5260; font-size: 11px; color: #4A5260; word-break: break-all; }
  @media print { body { background: #FFFFFF; padding: 0; } .ticket { border: none; } }
</style>
</head>
<body>
  <div class="ticket">
    <div class="header">
      <strong>FOLIO ${_escaparHtml(ticket.folio)}</strong>
      <span class="sello">$sello</span>
    </div>
    <pre>$textoTermico</pre>
    <div class="qr">
      <strong>Verificación QR:</strong> ${_escaparHtml(ticket.codigoVerificacionQr)}<br>
      Emitido con Mi Doyang by Cupa · Comprobante interno (no fiscal CFDI).
    </div>
  </div>
</body>
</html>
''';
}

List<int> _comandoQrEscPos(String contenido) {
  final data = _codificarAsciiSeguro(contenido);
  final storeLen = data.length + 3;
  final pL = storeLen & 0xFF;
  final pH = (storeLen >> 8) & 0xFF;

  return <int>[
    // Modelo QR 2
    0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00,
    // Tamaño de módulo = 5
    0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x05,
    // Corrección de error M (49)
    0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x31,
    // Almacenar datos en buffer QR
    0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30,
    ...data,
    // Imprimir símbolo QR
    0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30,
  ];
}

List<int> _codificarAsciiSeguro(String texto) {
  const reemplazos = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'ñ': 'n',
    'Ñ': 'N',
    'ü': 'u',
    'Ü': 'U',
    '·': '-',
    '°': 'o',
    'º': 'o',
  };
  final out = <int>[];
  for (final rune in texto.runes) {
    final ch = String.fromCharCode(rune);
    final mapeado = reemplazos[ch] ?? ch;
    for (final unit in mapeado.codeUnits) {
      out.add((unit >= 0x20 && unit <= 0x7E) ? unit : 0x3F);
    }
  }
  return out;
}

String _escaparHtml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
