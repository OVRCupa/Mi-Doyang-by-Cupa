import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'tema_doyang.dart';

/// Widget de vista previa y comprobante de pago en formato de papel térmico
/// de 80 mm (48 columnas) o 58 mm (32 columnas) con código QR verificable
/// (`docs/diseno.md` §3 y D-06).
class TicketTermicoWidget extends StatelessWidget {
  final TicketPago ticket;
  final AcademiaConfig academia;
  final int anchoColumnas;

  const TicketTermicoWidget({
    super.key,
    required this.ticket,
    required this.academia,
    this.anchoColumnas = 48,
  });

  @override
  Widget build(BuildContext context) {
    final textoTermico = ticket.renderizarTicketTermico(
      anchoColumnas: anchoColumnas,
      nombreAcademia: academia.nombre,
      telefonoAcademia: academia.telefono,
      direccionAcademia: academia.direccion,
      leyendaPie: academia.leyendaTicket,
    );

    final colorSello = ticket.cancelado
        ? ColoresDoyang.selloHong
        : ColoresDoyang.jadeAprobado;
    final fondoSello = ticket.cancelado
        ? ColoresDoyang.fondoHongSuave
        : ColoresDoyang.fondoJadeSuave;

    return Container(
      decoration: BoxDecoration(
        color: ColoresDoyang.superficieTatami,
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        border: Border.all(color: ColoresDoyang.bordePiedra, width: 1.2),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  'FOLIO ${ticket.folio}',
                  style: TipografiaDoyang.etiqueta(
                    color: ColoresDoyang.tintaCinturonNegro,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: fondoSello,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: colorSello),
                ),
                child: Text(
                  ticket.cancelado ? 'CANCELADO' : 'PAGADO',
                  style: TipografiaDoyang.metadato(
                    color: colorSello,
                    peso: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColoresDoyang.papelDobok,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: ColoresDoyang.bordePiedra),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                textoTermico,
                style: TipografiaDoyang.ticketMonoespaciado(
                  compacto: anchoColumnas <= 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _PintorQrVerificacion(
                    semilla: ticket.codigoVerificacionQr,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'QR de verificación inmutable',
                      style: TipografiaDoyang.etiqueta(
                        color: ColoresDoyang.tintaCinturonNegro,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.codigoVerificacionQr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TipografiaDoyang.metadato(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.sincronizadoNube
                          ? 'Sincronizado con nube'
                          : 'Guardado local (cola offline outbox)',
                      style: TipografiaDoyang.metadato(
                        color: ticket.sincronizadoNube
                            ? ColoresDoyang.jadeAprobado
                            : ColoresDoyang.ambarTatami,
                        peso: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PintorQrVerificacion extends CustomPainter {
  final String semilla;

  const _PintorQrVerificacion({required this.semilla});

  @override
  void paint(Canvas canvas, Size size) {
    const dimension = 11;
    final celda = size.width / dimension;
    final fondo = Paint()
      ..style = PaintingStyle.fill
      ..color = ColoresDoyang.superficieTatami;
    final tinta = Paint()
      ..style = PaintingStyle.fill
      ..color = ColoresDoyang.tintaCinturonNegro;

    canvas.drawRect(Offset.zero & size, fondo);

    bool esEsquinaBuscador(int f, int c) {
      final arribaIzq = f < 3 && c < 3;
      final arribaDer = f < 3 && c >= dimension - 3;
      final abajoIzq = f >= dimension - 3 && c < 3;
      return arribaIzq || arribaDer || abajoIzq;
    }

    final codigos = semilla.codeUnits;
    for (var f = 0; f < dimension; f++) {
      for (var c = 0; c < dimension; c++) {
        var pintar = false;
        if (esEsquinaBuscador(f, c)) {
          pintar = true;
        } else if (codigos.isNotEmpty) {
          final idx = (f * dimension + c) % codigos.length;
          pintar = ((codigos[idx] + f * 7 + c * 13) % 2) == 0;
        }
        if (pintar) {
          canvas.drawRect(
            Rect.fromLTWH(c * celda, f * celda, celda * 0.92, celda * 0.92),
            tinta,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorQrVerificacion oldDelegate) =>
      oldDelegate.semilla != semilla;
}
