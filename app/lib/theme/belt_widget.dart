import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'tema_doyang.dart';

/// Faja visual de cinta de Taekwondo (`docs/diseno.md` §3 y §4.2).
///
/// Reglas geométricas obligatorias:
/// - Bloque horizontal con textura de costura longitudinal.
/// - El `20%` derecho se reserva exclusivamente para la franja vertical de la
///   **punta** (cuando aplica); el texto del grado se alinea en el `80%`
///   izquierdo y nunca invade la punta.
/// - En la cinta **Poom** (dividida horizontalmente en rojo `#B82924` arriba y
///   negro `#14181F` abajo), cualquier etiqueta en dorado (`#E0A800`) se dibuja
///   únicamente sobre la mitad negra (`#14181F`, contraste `8.3:1`).
class BeltWidget extends StatelessWidget {
  final GradoCinta grado;
  final bool compacto;

  const BeltWidget({
    super.key,
    required this.grado,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = ColoresDoyang.desdeHex(grado.colorBaseHex);
    final colorPunta =
        grado.tienePunta ? ColoresDoyang.desdeHex(grado.colorPuntaHex!) : null;
    final colorTexto = grado.esPoom
        ? ColoresDoyang.papelDobok
        : ColoresDoyang.textoSobreHex(grado.colorBaseHex);
    final alto = compacto ? 32.0 : 42.0;

    return Semantics(
      label: 'Cinta actual: ${grado.codigo}, ${grado.nombre}',
      child: Container(
        height: alto,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(DimensionesDoyang.radioContenedor),
          ),
          border: Border.all(
            color: ColoresDoyang.bordeCintaBlanca,
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _PintorFajaCinta(
            colorBase: colorBase,
            colorPunta: colorPunta,
            esPoom: grado.esPoom,
          ),
          child: Row(
            children: <Widget>[
              // 80% izquierdo para el texto del grado (nunca invade la punta)
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      compacto
                          ? '${grado.codigo} · ${grado.nombre}'
                          : '${grado.codigo.toUpperCase()} · ${grado.nombre.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: compacto
                          ? TipografiaDoyang.metadato(
                              color: colorTexto,
                              peso: FontWeight.w700,
                            )
                          : TipografiaDoyang.celda(
                              color: colorTexto,
                              peso: FontWeight.w700,
                            ),
                    ),
                  ),
                ),
              ),
              // 20% derecho reservado para la punta o distintivo Poom/Dan
              Expanded(
                flex: 2,
                child: grado.esPoom
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'POOM',
                            style: TipografiaDoyang.metadato(
                              color: ColoresDoyang.doradoDan,
                              peso: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.expand(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PintorFajaCinta extends CustomPainter {
  final Color colorBase;
  final Color? colorPunta;
  final bool esPoom;

  const _PintorFajaCinta({
    required this.colorBase,
    required this.colorPunta,
    required this.esPoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pincelBase = Paint()..style = PaintingStyle.fill;

    if (esPoom) {
      // Mitad superior roja Hong (#B82924), mitad inferior negra (#14181F)
      pincelBase.color = ColoresDoyang.selloHong;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height / 2),
        pincelBase,
      );
      pincelBase.color = ColoresDoyang.tintaCinturonNegro;
      canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
        pincelBase,
      );
    } else {
      pincelBase.color = colorBase;
      canvas.drawRect(Offset.zero & size, pincelBase);

      // Franja vertical de la punta en el 20% derecho
      if (colorPunta != null) {
        final inicioZonaPunta = size.width * 0.80;
        final anchoFranja = size.width * 0.11;
        final xFranja = inicioZonaPunta + (size.width * 0.045);
        final pincelPunta = Paint()
          ..style = PaintingStyle.fill
          ..color = colorPunta!;
        canvas.drawRect(
          Rect.fromLTWH(xFranja, 0, anchoFranja, size.height),
          pincelPunta,
        );
      }
    }

    // Líneas de costura longitudinales tradicionales del cinturón
    final pincelCostura = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = ColoresDoyang.bordeCintaBlanca.withAlpha(90);

    final ySuperior = size.height * 0.18;
    final yInferior = size.height * 0.82;
    canvas.drawLine(
      Offset(0, ySuperior),
      Offset(size.width, ySuperior),
      pincelCostura,
    );
    canvas.drawLine(
      Offset(0, yInferior),
      Offset(size.width, yInferior),
      pincelCostura,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorFajaCinta oldDelegate) {
    return oldDelegate.colorBase != colorBase ||
        oldDelegate.colorPunta != colorPunta ||
        oldDelegate.esPoom != esPoom;
  }
}
