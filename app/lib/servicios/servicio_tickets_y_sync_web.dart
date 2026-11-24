import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'servicio_tickets_y_sync.dart';

Future<ResultadoSyncSupabase> sincronizarOutboxImpl(
  ConfigSupabase config,
  MotorDoyang motor,
) async {
  final pendientes = motor.colaOutbox.where((e) => !e.sincronizado).length;
  return ResultadoSyncSupabase(
    sincronizados: 0,
    pendientes: pendientes,
    mensaje: 'Vista previa en PC: $pendientes operación(es) en cola.',
  );
}

Future<String> guardarComprobanteHtmlImpl({
  required TicketPago ticket,
  required AcademiaConfig academia,
}) async {
  generarComprobanteHtmlImprimible(ticket: ticket, academia: academia);
  return '${ticket.folio}.html (generado en memoria)';
}

Future<String> guardarComprobanteEscPosImpl({
  required TicketPago ticket,
  required AcademiaConfig academia,
  int anchoColumnas = 48,
}) async {
  generarBytesEscPosTicket(
    ticket: ticket,
    academia: academia,
    anchoColumnas: anchoColumnas,
  );
  return '${ticket.folio}_${anchoColumnas}col.escpos.bin (generado en memoria)';
}
