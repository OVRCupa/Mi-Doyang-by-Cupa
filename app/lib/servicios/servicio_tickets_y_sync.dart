import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'servicio_tickets_y_sync_web.dart'
    if (dart.library.io) 'servicio_tickets_y_sync_io.dart' as impl;

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

  bool get estaConfigurado =>
      url.trim().isNotEmpty && anonKey.trim().isNotEmpty;
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

class SincronizadorSupabase {
  final ConfigSupabase config;

  const SincronizadorSupabase({required this.config});

  Future<ResultadoSyncSupabase> sincronizarOutbox(MotorDoyang motor) =>
      impl.sincronizarOutboxImpl(config, motor);
}

class ExportadorComprobantesLocal {
  static Future<String> guardarComprobanteHtml({
    required TicketPago ticket,
    required AcademiaConfig academia,
  }) =>
      impl.guardarComprobanteHtmlImpl(ticket: ticket, academia: academia);

  static Future<String> guardarComprobanteEscPos({
    required TicketPago ticket,
    required AcademiaConfig academia,
    int anchoColumnas = 48,
  }) =>
      impl.guardarComprobanteEscPosImpl(
        ticket: ticket,
        academia: academia,
        anchoColumnas: anchoColumnas,
      );
}
