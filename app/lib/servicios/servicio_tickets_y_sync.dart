import 'dart:convert';
import 'dart:io';

import 'package:mi_doyang_core/mi_doyang_core.dart';

/// Configuración de conexión opcional a Supabase (inyectable vía `--dart-define`
/// sin guardar secretos en el código fuente).
class ConfigSupabase {
  final String url;
  final String anonKey;
  final String? accessToken;

  const ConfigSupabase({
    required this.url,
    required this.anonKey,
    this.accessToken,
  });

  factory ConfigSupabase.desdeEntorno() => const ConfigSupabase(
        url: String.fromEnvironment('SUPABASE_URL'),
        anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  bool get estaConfigurado => url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
}

class ResultadoSyncSupabase {
  final int sincronizados;
  final int pendientes;
  final String mensaje;

  const ResultadoSyncSupabase({
    required this.sincronizados,
    required this.pendientes,
    required this.mensaje,
  });
}

/// Servicio de sincronización idempotente de `colaOutbox` contra Supabase REST/RPC
/// (`supabase/migrations/0001_esquema_inicial.sql`), con degradación segura
/// offline-first cuando no hay red o credenciales configuradas.
class SincronizadorSupabase {
  final ConfigSupabase config;

  const SincronizadorSupabase({required this.config});

  Future<ResultadoSyncSupabase> sincronizarOutbox(MotorDoyang motor) async {
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
            'Modo local offline: ${pendientes.length} operación(es) guardadas en disco. '
            'Configura SUPABASE_URL y SUPABASE_ANON_KEY para sincronizar a la nube.',
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
            'Sincronización con Supabase: $ok enviadas, ${pendientes.length - ok} pendientes.',
      );
    } on Object {
      return ResultadoSyncSupabase(
        sincronizados: ok,
        pendientes: pendientes.length - ok,
        mensaje:
            'Sin conexión con Supabase. Los ${pendientes.length - ok} eventos '
            'siguen seguros en la cola offline local.',
      );
    } finally {
      cliente.close();
    }
  }
}

/// Exporta un ticket a archivo local imprimible (`.html` para PDF/WhatsApp o
/// `.escpos.bin` para impresora térmica de 58/80 mm).
class ExportadorComprobantesLocal {
  static Directory _carpetaTickets() {
    final base = Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Directory.systemTemp.path;
    return Directory('$base${Platform.pathSeparator}MiDoyangByCupa${Platform.pathSeparator}tickets');
  }

  static Future<File> guardarComprobanteHtml({
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
    return archivo;
  }

  static Future<File> guardarComprobanteEscPos({
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
    return archivo;
  }
}
