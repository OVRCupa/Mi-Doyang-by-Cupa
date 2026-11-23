import 'dart:math' as math;

/// Calcula la luminancia relativa de un valor ARGB según el estándar WCAG 2.1.
///
/// Devuelve un valor entre `0.0` (negro puro) y `1.0` (blanco puro).
double calcularLuminanciaRelativa(int colorArgb) {
  final r = ((colorArgb >> 16) & 0xFF) / 255.0;
  final g = ((colorArgb >> 8) & 0xFF) / 255.0;
  final b = (colorArgb & 0xFF) / 255.0;

  double linealizar(double canal) {
    if (canal <= 0.04045) {
      return canal / 12.92;
    }
    return math.pow((canal + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linealizar(r) +
      0.7152 * linealizar(g) +
      0.0722 * linealizar(b);
}

/// Calcula la razón de contraste WCAG 2.1 entre dos valores ARGB (`1.0` a `21.0`).
double calcularRazonContraste(int colorA, int colorB) {
  final lumA = calcularLuminanciaRelativa(colorA);
  final lumB = calcularLuminanciaRelativa(colorB);
  final masClaro = math.max(lumA, lumB);
  final masOscuro = math.min(lumA, lumB);
  return (masClaro + 0.05) / (masOscuro + 0.05);
}

/// Ajusta automáticamente la luminosidad de [colorArgb] en espacio HSL para
/// garantizar que alcance al menos la razón de contraste [minimo] (por defecto
/// `4.5:1` para WCAG 2.1 AA) frente a [fondoArgb], conservando su matiz y
/// saturación originales.
int asegurarContrasteWcagAA(
  int colorArgb, {
  required int fondoArgb,
  double minimo = 4.5,
}) {
  final alpha = (colorArgb & 0xFF000000) == 0
      ? 0xFF000000
      : (colorArgb & 0xFF000000);
  final normalizado = alpha | (colorArgb & 0x00FFFFFF);

  if (calcularRazonContraste(normalizado, fondoArgb) >= minimo) {
    return normalizado;
  }

  final hsl = _argbAHsl(normalizado);
  final h = hsl[0];
  final s = hsl[1];
  final lOriginal = hsl[2];

  final contrasteNegro = calcularRazonContraste(0xFF000000, fondoArgb);
  final contrasteBlanco = calcularRazonContraste(0xFFFFFFFF, fondoArgb);
  final oscurecer = contrasteNegro >= contrasteBlanco;

  if (oscurecer) {
    if (contrasteNegro <= minimo) {
      return alpha | 0x000000;
    }
    var bajo = 0.0;
    var alto = lOriginal;
    for (var i = 0; i < 28; i++) {
      final medio = (bajo + alto) / 2.0;
      final candidato = _hslAArgb(h, s, medio, alpha: alpha);
      if (calcularRazonContraste(candidato, fondoArgb) >= minimo) {
        bajo = medio;
      } else {
        alto = medio;
      }
    }
    var lAjustada = bajo;
    var resultado = _hslAArgb(h, s, lAjustada, alpha: alpha);
    while (calcularRazonContraste(resultado, fondoArgb) < minimo &&
        lAjustada > 0.0) {
      lAjustada = math.max(0.0, lAjustada - 0.004);
      resultado = _hslAArgb(h, s, lAjustada, alpha: alpha);
      if (lAjustada == 0.0) break;
    }
    return calcularRazonContraste(resultado, fondoArgb) >= minimo
        ? resultado
        : (alpha | 0x000000);
  } else {
    if (contrasteBlanco <= minimo) {
      return alpha | 0xFFFFFF;
    }
    var bajo = lOriginal;
    var alto = 1.0;
    for (var i = 0; i < 28; i++) {
      final medio = (bajo + alto) / 2.0;
      final candidato = _hslAArgb(h, s, medio, alpha: alpha);
      if (calcularRazonContraste(candidato, fondoArgb) >= minimo) {
        alto = medio;
      } else {
        bajo = medio;
      }
    }
    var lAjustada = alto;
    var resultado = _hslAArgb(h, s, lAjustada, alpha: alpha);
    while (calcularRazonContraste(resultado, fondoArgb) < minimo &&
        lAjustada < 1.0) {
      lAjustada = math.min(1.0, lAjustada + 0.004);
      resultado = _hslAArgb(h, s, lAjustada, alpha: alpha);
      if (lAjustada == 1.0) break;
    }
    return calcularRazonContraste(resultado, fondoArgb) >= minimo
        ? resultado
        : (alpha | 0xFFFFFF);
  }
}

/// Convierte una cadena hexadecimal (`#RRGGBB` o `#AARRGGBB`) a entero ARGB.
int hexAArgb(String hex) {
  final limpio = hex.trim().replaceFirst('#', '').toUpperCase();
  if (limpio.length == 6) {
    return int.parse('FF$limpio', radix: 16);
  }
  if (limpio.length == 8) {
    return int.parse(limpio, radix: 16);
  }
  throw FormatException('Formato hexadecimal de color inválido: $hex');
}

/// Convierte un entero ARGB a cadena hexadecimal `#RRGGBB`.
String argbAHex(int colorArgb) {
  final rgb = colorArgb & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Ajusta una cadena hexadecimal (`#RRGGBB`) para cumplir contraste WCAG AA
/// contra [fondoHex].
String asegurarContrasteHexWcagAA(
  String colorHex, {
  required String fondoHex,
  double minimo = 4.5,
}) {
  final ajustado = asegurarContrasteWcagAA(
    hexAArgb(colorHex),
    fondoArgb: hexAArgb(fondoHex),
    minimo: minimo,
  );
  return argbAHex(ajustado);
}

List<double> _argbAHsl(int argb) {
  final r = ((argb >> 16) & 0xFF) / 255.0;
  final g = ((argb >> 8) & 0xFF) / 255.0;
  final b = (argb & 0xFF) / 255.0;

  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final delta = maxC - minC;

  var h = 0.0;
  var s = 0.0;
  final l = (maxC + minC) / 2.0;

  if (delta != 0.0) {
    s = l > 0.5 ? delta / (2.0 - maxC - minC) : delta / (maxC + minC);
    if (maxC == r) {
      h = ((g - b) / delta) + (g < b ? 6.0 : 0.0);
    } else if (maxC == g) {
      h = ((b - r) / delta) + 2.0;
    } else {
      h = ((r - g) / delta) + 4.0;
    }
    h /= 6.0;
  }

  return <double>[h, s, l];
}

int _hslAArgb(double h, double s, double l, {int alpha = 0xFF000000}) {
  double r;
  double g;
  double b;

  if (s == 0.0) {
    r = l;
    g = l;
    b = l;
  } else {
    double hue2rgb(double p, double q, double t) {
      var tt = t;
      if (tt < 0.0) tt += 1.0;
      if (tt > 1.0) tt -= 1.0;
      if (tt < 1.0 / 6.0) return p + (q - p) * 6.0 * tt;
      if (tt < 1.0 / 2.0) return q;
      if (tt < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - tt) * 6.0;
      return p;
    }

    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2.0 * l - q;
    r = hue2rgb(p, q, h + 1.0 / 3.0);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1.0 / 3.0);
  }

  final ri = (r * 255.0).round().clamp(0, 255);
  final gi = (g * 255.0).round().clamp(0, 255);
  final bi = (b * 255.0).round().clamp(0, 255);

  return alpha | (ri << 16) | (gi << 8) | bi;
}
