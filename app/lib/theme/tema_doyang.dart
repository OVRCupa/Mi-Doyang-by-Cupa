import 'package:material_ui/material_ui.dart';
import 'package:mi_doyang_core/mi_doyang_core.dart';

/// Tokens oficiales de color de **Mi Doyang by Cupa**, alineados al estilo
/// amigable de **CUPA Scanner** y **CUPA Taekwondo** (azul marino + azul
/// brillante + rojo marca + colores editables por academia).
///
/// Regla de arquitectura: ningún archivo fuera de `lib/theme/` puede usar
/// constructores crudos de color ni paletas por defecto de Flutter.
abstract final class ColoresDoyang {
  // Paleta base amigable estilo CUPA Taekwondo / CUPA Scanner (Light)
  static const papelDobok = Color(0xFFF1F5FB); // Cupa.Surface
  static const superficieTatami = Color(0xFFFFFFFF); // Cupa.Card
  static const superficieAlterna = Color(0xFFEEF2F8); // Cupa.SurfaceAlt
  static const esqueletoCarga = Color(0xFFE3EAF5);
  static const bordePiedra = Color(0xFFDCE4F0); // Cupa.Border
  static const bordeActivo = Color(0xFF2563EB); // Cupa.Blue
  static const tintaCinturonNegro = Color(0xFF0B1B33); // Cupa.NavyDeep
  static const azulMarinoMedio = Color(0xFF12305E); // Cupa.NavyMid
  static const tintaPrincipal = Color(0xFF16202B); // Cupa.Ink
  static const tintaGrafito = Color(0xFF5B6672); // Cupa.InkMuted
  static const azulChung = Color(0xFF2563EB); // Cupa.Blue
  static const azulBrillante = Color(0xFF3B82F6); // Cupa.BlueLight
  static const fondoAzulSuave = Color(0xFFE6EEF8); // Cupa.BlueBg
  static const selloHong = Color(0xFFBC2220); // Cupa.Red
  static const fondoHongSuave = Color(0xFFFBEAE9); // Cupa.DangerBg
  static const jadeAprobado = Color(0xFF177A43); // Cupa.Success
  static const fondoJadeSuave = Color(0xFFE7F5EC); // Cupa.SuccessBg
  static const ambarTatami = Color(0xFF8A520B); // Cupa.Warning
  static const fondoAmbarSuave = Color(0xFFFBF0DE); // Cupa.WarningBg
  static const doradoDan = Color(0xFFD4AF37); // Cupa.Gold
  static const bordeCintaBlanca = Color(0xFF8C97A8);
  static const sombraSuave = Color(0x140B1B33);
  static const transparente = Color(0x00000000);

  // Tokens oficiales exactos de la suite OVR CUPA (#031D38, #B20602, #111111, #F2F2F2)
  static const logoTextoClaro = Color(0xFFF2F2F2);
  static const logoTextoOscuro = Color(0xFF111111);
  static const logoAzulSobreClaro = Color(0xFF031D38);
  static const logoYangSobreClaro = Color(0xFF031D38);
  static const logoRojoSobreClaro = Color(0xFFB20602);
  static const logoAzulSobreOscuro = Color(0xFF031D38);
  static const logoRojoSobreOscuro = Color(0xFFB20602);

  /// Presets de colores amigables que cada academia puede elegir con 1 toque.
  static const presetsColorAcademia = <(String, String)>[
    ('CUPA Azul', '#2563EB'),
    ('Marino Dojang', '#0F2A55'),
    ('Rojo Hong', '#BC2220'),
    ('Verde Tatami', '#177A43'),
    ('Naranja Tigre', '#C2410C'),
    ('Grafito Negro', '#1E293B'),
  ];

  /// Degradado de encabezado estilo `Cupa.HeaderBrush`, adaptable al color
  /// editable de cada academia manteniendo contraste alto con texto blanco.
  static LinearGradient gradienteEncabezado(String colorPrimarioHex) {
    final primario = primarioAcademiaAccesible(colorPrimarioHex);
    final oscuro = Color.lerp(tintaCinturonNegro, primario, 0.28) ??
        tintaCinturonNegro;
    final medio =
        Color.lerp(azulMarinoMedio, primario, 0.45) ?? azulMarinoMedio;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[oscuro, medio],
    );
  }

  /// Convierte una cadena hexadecimal `#RRGGBB` en [Color].
  static Color desdeHex(String hex) => Color(hexAArgb(hex));

  /// Devuelve el color primario de la academia garantizando contraste
  /// WCAG 2.1 AA (>= 4.5:1) sobre texto claro `#F1F5FB`.
  static Color primarioAcademiaAccesible(String colorPrimarioHex) {
    final argbAjustado = asegurarContrasteWcagAA(
      hexAArgb(colorPrimarioHex),
      fondoArgb: 0xFFF1F5FB,
      minimo: 4.5,
    );
    return Color(argbAjustado);
  }

  /// Devuelve el color de texto (`#0B1B33` o `#FFFFFF`) con mayor contraste
  /// WCAG sobre el fondo indicado en hexadecimal.
  static Color textoSobreHex(String fondoHex) {
    final argbFondo = hexAArgb(fondoHex);
    final contrasteNegro = calcularRazonContraste(0xFF0B1B33, argbFondo);
    final contrasteBlanco = calcularRazonContraste(0xFFFFFFFF, argbFondo);
    return contrasteNegro >= contrasteBlanco
        ? tintaCinturonNegro
        : superficieTatami;
  }
}

/// Escala tipográfica oficial en `dp`.
abstract final class EscalaTipograficaDoyang {
  static const metadato = 12.0;
  static const celda = 14.0;
  static const cuerpo = 16.0;
  static const seccion = 20.0;
  static const encabezado = 24.0;
  static const granTotal = 32.0;
  static const marcadorPrincipal = 44.0;
}

/// Dimensiones, radios amigables y objetivos táctiles del sistema.
abstract final class DimensionesDoyang {
  static const objetivoTactilMinimo = 48.0;
  static const altoFilaTactil = 56.0;
  static const puntoQuiebreEscritorioCompacto = 1100.0;
  static const anchoRailCompacto = 76.0;
  static const anchoSidebarExpandido = 228.0;
  static const radioContenedor = 14.0;
  static const radioBoton = 12.0;
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
