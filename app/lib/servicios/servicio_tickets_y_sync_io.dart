import 'dart:convert';
import 'dart:io';

import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'servicio_tickets_y_sync.dart';

Future<ResultadoSyncSupabase> sincronizarOutboxImpl(
  ConfigSupabase config,
  MotorDoyang motor,
) async {
  final pendientes = motor.colaOutbox.where((e) => !e.sincronizado).toList();
  if (pendientes.isEmpty) {
    return const ResultadoSyncSupabase(
      sincronizados: 0,
      pendientes: 0,
      mensaje: 'Todo está al día: no hay operaciones pendientes en la cola.',
    );
  }
  if (!config.estaConfigurado) {
    return ResultadoSyncSupabase(
      sincronizados: 0,
      pendientes: pendientes.length,
      mensaje:
          'Modo local offline: ${pendientes.length} operación(es) guardadas en disco.',
    );
  }

  final cliente = HttpClient()..connectionTimeout = const Duration(seconds: 6);
  var ok = 0;
  try {
    for (final evento in pendientes) {
      if (evento.tipoOperacion == 'EMITIR_TICKET_PAGO') {
        final uri = Uri.parse(
          '${config.url.replaceAll(RegExp(r'/+$'), '')}/rest/v1/rpc/procesar_pago_offline',
        );
        final req = await cliente.postUrl(uri);
        req.headers.set('apikey', config.anonKey);
        req.headers.set(
          'Authorization',
          'Bearer ${config.accessToken ?? config.anonKey}',
        );
        req.headers.set('Content-Type', 'application/json; charset=utf-8');
        req.add(
          utf8.encode(
            jsonEncode(<String, dynamic>{
              'p_client_mutation_id': evento.id,
              'p_folio': evento.payload['folio'],
              'p_tutor_id': evento.payload['tutorId'],
              'p_metodo_pago': evento.payload['metodoPago'],
              'p_referencia_pago': evento.payload['referenciaPagoOpcional'],
              'p_total_pagado_centavos': evento.payload['totalPagadoCentavos'],
              'p_codigo_qr': evento.payload['codigoVerificacionQr'],
            }),
          ),
        );
        final res = await req.close();
        await res.drain<void>();
        if (res.statusCode >= 200 && res.statusCode < 300) {
          ok++;
        }
      }
    }
    return ResultadoSyncSupabase(
      sincronizados: ok,
      pendientes: pendientes.length - ok,
      mensaje:
          'Sincronización completada: $ok enviadas, ${pendientes.length - ok} pendientes.',
    );
  } on Object {
    return ResultadoSyncSupabase(
      sincronizados: ok,
      pendientes: pendientes.length - ok,
      mensaje:
          'Sin conexión al servidor. Los ${pendientes.length - ok} eventos siguen seguros en la cola offline.',
    );
  } finally {
    cliente.close();
  }
}

Directory _carpetaTickets() {
  final base = Platform.environment['LOCALAPPDATA'] ??
      Platform.environment['APPDATA'] ??
      Directory.systemTemp.path;
  return Directory(
    '$base${Platform.pathSeparator}MiDoyangByCupa${Platform.pathSeparator}tickets',
  );
}

Future<String> guardarComprobanteHtmlImpl({
  required TicketPago ticket,
  required AcademiaConfig academia,
}) async {
  final dir = _carpetaTickets();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final nombreSeguro = ticket.folio.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  final archivo = File('${dir.path}${Platform.pathSeparator}$nombreSeguro.html');
  final html = generarComprobanteHtmlImprimible(
    ticket: ticket,
    academia: academia,
  );
  await archivo.writeAsString(html, flush: true);
  return archivo.path;
}

Future<String> guardarComprobanteEscPosImpl({
  required TicketPago ticket,
  required AcademiaConfig academia,
  int anchoColumnas = 48,
}) async {
  final dir = _carpetaTickets();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final nombreSeguro = ticket.folio.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  final archivo = File(
    '${dir.path}${Platform.pathSeparator}${nombreSeguro}_${anchoColumnas}col.escpos.bin',
  );
  final bytes = generarBytesEscPosTicket(
    ticket: ticket,
    academia: academia,
    anchoColumnas: anchoColumnas,
  );
  await archivo.writeAsBytes(bytes, flush: true);
  return archivo.path;
}
