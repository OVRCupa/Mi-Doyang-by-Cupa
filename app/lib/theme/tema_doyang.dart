import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

/// Tokens oficiales de color de **Mi Doyang by Cupa** (`docs/diseno.md` §4.1).
///
/// Regla de arquitectura: ningún archivo fuera de `lib/theme/` puede usar
/// constructores crudos de color ni paletas por defecto de Flutter.
abstract final class ColoresDoyang {
  static const papelDobok = Color(0xFFF7F5F0);
  static const superficieTatami = Color(0xFFFFFFFF);
  static const esqueletoCarga = Color(0xFFEAE6DD);
  static const bordePiedra = Color(0xFFD6D1C7);
  static const bordeActivo = Color(0xFF5A6270);
  static const tintaCinturonNegro = Color(0xFF14181F);
  static const tintaGrafito = Color(0xFF4A5260);
  static const azulChung = Color(0xFF1644AD);
  static const fondoAzulSuave = Color(0xFFE8EEF9);
  static const selloHong = Color(0xFFB82924);
  static const fondoHongSuave = Color(0xFFFDECEA);
  static const jadeAprobado = Color(0xFF146C43);
  static const fondoJadeSuave = Color(0xFFE7F4EE);
  static const ambarTatami = Color(0xFF8A5300);
  static const fondoAmbarSuave = Color(0xFFFFF4DB);
  static const doradoDan = Color(0xFFE0A800);
  static const bordeCintaBlanca = Color(0xFF7A766E);
  static const sombraSuave = Color(0x1414181F);
  static const transparente = Color(0x00000000);

  /// Convierte una cadena hexadecimal `#RRGGBB` en [Color].
  static Color desdeHex(String hex) => Color(hexAArgb(hex));

  /// Devuelve el color primario de la academia garantizando contraste
  /// WCAG 2.1 AA (>= 4.5:1) sobre texto claro `#F7F5F0`.
  static Color primarioAcademiaAccesible(String colorPrimarioHex) {
    final argbAjustado = asegurarContrasteWcagAA(
      hexAArgb(colorPrimarioHex),
      fondoArgb: 0xFFF7F5F0,
      minimo: 4.5,
    );
    return Color(argbAjustado);
  }

  /// Devuelve el color de texto (`#14181F` o `#F7F5F0`) con mayor contraste
  /// WCAG sobre el fondo indicado en hexadecimal.
  static Color textoSobreHex(String fondoHex) {
    final argbFondo = hexAArgb(fondoHex);
    final contrasteNegro = calcularRazonContraste(0xFF14181F, argbFondo);
    final contrasteBlanco = calcularRazonContraste(0xFFF7F5F0, argbFondo);
    return contrasteNegro >= contrasteBlanco ? tintaCinturonNegro : papelDobok;
  }
}

/// Escala tipográfica oficial en `dp` (`docs/diseno.md` §5).
abstract final class EscalaTipograficaDoyang {
  static const metadato = 12.0;
  static const celda = 14.0;
  static const cuerpo = 16.0;
  static const seccion = 20.0;
  static const encabezado = 24.0;
  static const granTotal = 32.0;
  static const marcadorPrincipal = 44.0;
}

/// Dimensiones, radios y objetivos táctiles del sistema (`docs/diseno.md`).
abstract final class DimensionesDoyang {
  static const objetivoTactilMinimo = 48.0;
  static const altoFilaTactil = 56.0;
  static const puntoQuiebreEscritorioCompacto = 1100.0;
  static const anchoRailCompacto = 76.0;
  static const anchoSidebarExpandido = 224.0;
  static const radioContenedor = 6.0;
  static const radioBoton = 6.0;
}

const _familiaOswald = 'Oswald';
const _variacionOswaldSemiBold = <FontVariation>[FontVariation('wght', 600)];
const _cifrasTabulares = <FontFeature>[FontFeature.tabularFigures()];

/// Constructores de estilos tipográficos con cifras tabulares obligatorias
/// para montos, folios, asistencias, pesos y fechas (`docs/diseno.md` §5).
abstract final class TipografiaDoyang {
  static TextStyle metadato({
    Color color = ColoresDoyang.tintaGrafito,
    FontWeight peso = FontWeight.w500,
  }) =>
      TextStyle(
        fontSize: EscalaTipograficaDoyang.metadato,
        fontWeight: peso,
        color: color,
        height: 1.25,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle celda({
    Color color = ColoresDoyang.tintaCinturonNegro,
    FontWeight peso = FontWeight.w400,
  }) =>
      TextStyle(
        fontSize: EscalaTipograficaDoyang.celda,
        fontWeight: peso,
        color: color,
        height: 1.3,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle etiqueta({
    Color color = ColoresDoyang.tintaGrafito,
  }) =>
      TextStyle(
        fontSize: EscalaTipograficaDoyang.celda,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle cuerpo({
    Color color = ColoresDoyang.tintaCinturonNegro,
    FontWeight peso = FontWeight.w400,
  }) =>
      TextStyle(
        fontSize: EscalaTipograficaDoyang.cuerpo,
        fontWeight: peso,
        color: color,
        height: 1.35,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle boton({
    Color color = ColoresDoyang.papelDobok,
  }) =>
      TextStyle(
        fontSize: EscalaTipograficaDoyang.cuerpo,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle tituloSeccion({
    Color color = ColoresDoyang.tintaCinturonNegro,
  }) =>
      TextStyle(
        fontFamily: _familiaOswald,
        fontVariations: _variacionOswaldSemiBold,
        fontSize: EscalaTipograficaDoyang.seccion,
        color: color,
        height: 1.2,
        letterSpacing: 0.3,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle encabezadoPantalla({
    Color color = ColoresDoyang.tintaCinturonNegro,
  }) =>
      TextStyle(
        fontFamily: _familiaOswald,
        fontVariations: _variacionOswaldSemiBold,
        fontSize: EscalaTipograficaDoyang.encabezado,
        color: color,
        height: 1.15,
        letterSpacing: 0.3,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle granTotal({
    Color color = ColoresDoyang.tintaCinturonNegro,
  }) =>
      TextStyle(
        fontFamily: _familiaOswald,
        fontVariations: _variacionOswaldSemiBold,
        fontSize: EscalaTipograficaDoyang.granTotal,
        color: color,
        height: 1.1,
        letterSpacing: 0.2,
        fontFeatures: _cifrasTabulares,
      );

  static TextStyle marcadorPrincipal({
    Color color = ColoresDoyang.tintaCinturonNegro,
  }) =>
      TextStyle(
        fontFamily: _familiaOswald,
        fontVariations: _variacionOswaldSemiBold,
        fontSize: EscalaTipograficaDoyang.marcadorPrincipal,
        color: color,
        height: 1.05,
        letterSpacing: 0.2,
        fontFeatures: _cifrasTabulares,
      );

  /// Estilo monoespaciado tabular exclusivo para el widget de ticket térmico
  /// y folios de caja (`docs/diseno.md` §5.3).
  static TextStyle ticketMonoespaciado({
    Color color = ColoresDoyang.tintaCinturonNegro,
    FontWeight peso = FontWeight.w500,
    bool compacto = false,
  }) =>
      TextStyle(
        fontFamily: 'Consolas',
        fontFamilyFallback: const <String>['JetBrains Mono', 'monospace'],
        fontSize: compacto
            ? EscalaTipograficaDoyang.metadato
            : EscalaTipograficaDoyang.celda,
        fontWeight: peso,
        color: color,
        height: 1.25,
        fontFeatures: _cifrasTabulares,
      );
}

/// Construye el [ThemeData] de **Mi Doyang by Cupa** aplicando el color
/// primario personalizado de la academia con verificación de contraste WCAG AA.
ThemeData construirTemaDoyang({String colorPrimarioHex = '#1644AD'}) {
  final primario = ColoresDoyang.primarioAcademiaAccesible(colorPrimarioHex);

  final esquema = ColorScheme(
    brightness: Brightness.light,
    primary: primario,
    onPrimary: ColoresDoyang.papelDobok,
    secondary: ColoresDoyang.selloHong,
    onSecondary: ColoresDoyang.papelDobok,
    error: ColoresDoyang.selloHong,
    onError: ColoresDoyang.papelDobok,
    surface: ColoresDoyang.superficieTatami,
    onSurface: ColoresDoyang.tintaCinturonNegro,
    surfaceContainer: ColoresDoyang.papelDobok,
    surfaceContainerHigh: ColoresDoyang.esqueletoCarga,
    onSurfaceVariant: ColoresDoyang.tintaGrafito,
    outline: ColoresDoyang.bordePiedra,
  );

  return ThemeData(
    colorScheme: esquema,
    scaffoldBackgroundColor: ColoresDoyang.papelDobok,
    dividerColor: ColoresDoyang.bordePiedra,
    textTheme: TextTheme(
      displaySmall: TipografiaDoyang.marcadorPrincipal(),
      headlineLarge: TipografiaDoyang.granTotal(),
      headlineMedium: TipografiaDoyang.encabezadoPantalla(),
      titleLarge: TipografiaDoyang.tituloSeccion(),
      titleMedium: TipografiaDoyang.cuerpo(peso: FontWeight.w600),
      bodyLarge: TipografiaDoyang.cuerpo(),
      bodyMedium: TipografiaDoyang.celda(),
      labelLarge: TipografiaDoyang.boton(
        color: ColoresDoyang.tintaCinturonNegro,
      ),
      labelMedium: TipografiaDoyang.etiqueta(),
      labelSmall: TipografiaDoyang.metadato(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(
          DimensionesDoyang.objetivoTactilMinimo,
          DimensionesDoyang.objetivoTactilMinimo,
        ),
        backgroundColor: primario,
        foregroundColor: ColoresDoyang.papelDobok,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DimensionesDoyang.radioBoton),
          ),
        ),
        textStyle: TipografiaDoyang.boton(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          DimensionesDoyang.objetivoTactilMinimo,
          DimensionesDoyang.objetivoTactilMinimo,
        ),
        foregroundColor: ColoresDoyang.tintaCinturonNegro,
        side: const BorderSide(color: ColoresDoyang.bordeActivo),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DimensionesDoyang.radioBoton),
          ),
        ),
        textStyle: TipografiaDoyang.cuerpo(peso: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColoresDoyang.superficieTatami,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: TipografiaDoyang.etiqueta(),
      hintStyle: TipografiaDoyang.celda(color: ColoresDoyang.tintaGrafito),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        borderSide: BorderSide(color: ColoresDoyang.bordePiedra),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        borderSide: BorderSide(color: primario, width: 1.5),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        borderSide: BorderSide(color: ColoresDoyang.bordePiedra),
      ),
    ),
    cardTheme: const CardThemeData(
      color: ColoresDoyang.superficieTatami,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(DimensionesDoyang.radioContenedor),
        ),
        side: BorderSide(color: ColoresDoyang.bordePiedra),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: ColoresDoyang.superficieTatami,
    ),
  );
}
