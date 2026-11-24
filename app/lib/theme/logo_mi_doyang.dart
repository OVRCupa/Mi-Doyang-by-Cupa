import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'tema_doyang.dart';

/// Logo oficial vectorial de **Mi Doyang by Cupa**.
///
/// La letra **"O"** replica el círculo dividido de **OVR CUPA**:
/// mitad izquierda azul (Chung) y mitad derecha roja (Hong), rodeado por un
/// anillo blanco con divisor vertical central. Debajo del nombre principal
/// aparece el subtítulo **"By Cupa"**.
class LogoMiDoyang extends StatelessWidget {
  final bool compacto;
  final bool sobreOscuro;

  const LogoMiDoyang({
    super.key,
    this.compacto = false,
    this.sobreOscuro = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorTexto = sobreOscuro
        ? ColoresDoyang.superficieTatami
        : ColoresDoyang.tintaCinturonNegro;
    final colorSubtitulo = sobreOscuro
        ? ColoresDoyang.papelDobok
        : ColoresDoyang.tintaGrafito;
    final tamanoCirculo = compacto ? 20.0 : 40.0;
    final estiloNombre = compacto
        ? TipografiaDoyang.tituloSeccion(color: colorTexto)
        : TipografiaDoyang.marcadorPrincipal(color: colorTexto);

    return Semantics(
      label: 'Mi Doyang By Cupa',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            compacto ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('MI D', style: estiloNombre),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: compacto ? 2 : 4),
                  child: SizedBox(
                    width: tamanoCirculo,
                    height: tamanoCirculo,
                    child: CustomPaint(
                      painter: _PintorOCupa(
                        colorAnillo: sobreOscuro
                            ? ColoresDoyang.superficieTatami
                            : ColoresDoyang.tintaCinturonNegro,
                      ),
                    ),
                  ),
                ),
                Text('YANG', style: estiloNombre),
              ],
            ),
          ),
          SizedBox(height: compacto ? 1 : 4),
          Text(
            'By Cupa',
            style: compacto
                ? TipografiaDoyang.metadato(
                    color: colorSubtitulo,
                    peso: FontWeight.w700,
                  )
                : TipografiaDoyang.cuerpo(
                    color: colorSubtitulo,
                    peso: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PintorOCupa extends CustomPainter {
  final Color colorAnillo;

  const _PintorOCupa({required this.colorAnillo});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final radioExterior = math.min(size.width, size.height) / 2;
    final grosorAnillo = radioExterior * 0.16;
    final radioInterior = radioExterior - grosorAnillo;

    // Anillo exterior blanco (como en OVR CUPA)
    canvas.drawCircle(
      centro,
      radioExterior,
      Paint()..color = colorAnillo,
    );

    final rectInterior = Rect.fromCircle(
      center: centro,
      radius: radioInterior,
    );

    // Mitad izquierda: Azul Chung
    canvas.drawArc(
      rectInterior,
      math.pi / 2,
      math.pi,
      true,
      Paint()..color = ColoresDoyang.azulChung,
    );

    // Mitad derecha: Rojo Hong
    canvas.drawArc(
      rectInterior,
      -math.pi / 2,
      math.pi,
      true,
      Paint()..color = ColoresDoyang.selloHong,
    );

    // Divisor vertical blanco central
    canvas.drawLine(
      Offset(centro.dx, centro.dy - radioInterior),
      Offset(centro.dx, centro.dy + radioInterior),
      Paint()
        ..color = colorAnillo
        ..strokeWidth = grosorAnillo * 0.72,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorOCupa oldDelegate) =>
      oldDelegate.colorAnillo != colorAnillo;
}
