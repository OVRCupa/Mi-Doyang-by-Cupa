import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

import 'tema_doyang.dart';

/// Faja horizontal oficial de cinta de Taekwondo (Kup, 1er Poom y Dan).
///
/// Reglas visuales:
/// - **Cintas avanzadas (`grado.esAvanzada`):** llevan una **franja horizontal
///   por la mitad a todo lo largo de la cinta** con el color de la siguiente cinta.
/// - **Negra 1er Poom (menores de 15 años):** mitad superior Roja y mitad inferior
///   Negra con distintivo dorado sobre la mitad negra.
/// - **Negra 1er Dan (mayores de 15 años):** base Negra con barra dorada.
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
    final colorSecundario = grado.tienePunta
        ? ColoresDoyang.desdeHex(grado.colorPuntaHex!)
        : null;
    final esAvanzada = grado.esAvanzada;
    final colorTexto = grado.esPoom
        ? ColoresDoyang.superficieTatami
        : (esAvanzada
            ? ColoresDoyang.tintaCinturonNegro
            : ColoresDoyang.textoSobreHex(grado.colorBaseHex));

    final alto = compacto ? 36.0 : 48.0;

    return Semantics(
      label: 'Grado ${grado.codigo}: ${grado.nombre}',
      child: Container(
        height: alto,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: ColoresDoyang.bordeCintaBlanca,
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          painter: _PintorFajaCinta(
            colorBase: colorBase,
            colorSecundario: colorSecundario,
            esAvanzada: esAvanzada,
            esPoom: grado.esPoom,
            esDan: grado.codigo.contains('Dan'),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: esAvanzada
                        // Pastilla de alto contraste para que el texto sobre la
                        // franja horizontal central siempre pase WCAG AA.
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColoresDoyang.superficieTatami
                                  .withValues(alpha: 0.92),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
                            ),
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
                          )
                        : Text(
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
  final Color? colorSecundario;
  final bool esAvanzada;
  final bool esPoom;
  final bool esDan;

  const _PintorFajaCinta({
    required this.colorBase,
    required this.colorSecundario,
    required this.esAvanzada,
    required this.esPoom,
    required this.esDan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rectCompleto = Offset.zero & size;

    if (esPoom) {
      // Cinta Negra 1er Poom (<15 años): mitad superior roja, mitad inferior negra.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height / 2),
        Paint()..color = ColoresDoyang.selloHong,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
        Paint()..color = ColoresDoyang.tintaCinturonNegro,
      );
    } else {
      canvas.drawRect(rectCompleto, Paint()..color = colorBase);
    }

    // Cinta avanzada: franja horizontal por la mitad a todo lo largo de la cinta
    // con el color de la siguiente cinta.
    if (esAvanzada && colorSecundario != null) {
      final altoFranja = size.height * 0.30;
      final topFranja = (size.height - altoFranja) / 2;
      canvas.drawRect(
        Rect.fromLTWH(0, topFranja, size.width, altoFranja),
        Paint()..color = colorSecundario!,
      );
    }

    // Cinta Negra Dan: barra vertical dorada en el extremo derecho.
    if (esDan && colorSecundario != null) {
      final anchoBarra = size.width * 0.05;
      final xBarra = size.width * 0.86;
      canvas.drawRect(
        Rect.fromLTWH(xBarra, 0, anchoBarra, size.height),
        Paint()..color = colorSecundario!,
      );
    }

    // Costuras longitudinales de tela de cinta de Taekwondo.
    final pinturaCostura = Paint()
      ..color = ColoresDoyang.tintaCinturonNegro.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;
    const margenCostura = 5.0;
    if (size.height > 16) {
      canvas.drawLine(
        Offset(0, margenCostura),
        Offset(size.width, margenCostura),
        pinturaCostura,
      );
      canvas.drawLine(
        Offset(0, size.height - margenCostura),
        Offset(size.width, size.height - margenCostura),
        pinturaCostura,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFajaCinta oldDelegate) =>
      oldDelegate.colorBase != colorBase ||
      oldDelegate.colorSecundario != colorSecundario ||
      oldDelegate.esAvanzada != esAvanzada ||
      oldDelegate.esPoom != esPoom ||
      oldDelegate.esDan != esDan;
}
