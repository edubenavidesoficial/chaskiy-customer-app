import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //
  ThemeData lightTheme() {
    final colorScheme = _lightColorScheme();

    return ThemeData(
      // fontFamily: GoogleFonts.ibmPlexSerif().fontFamily,
      // fontFamily: GoogleFonts.krub().fontFamily,
      // fontFamily: GoogleFonts.montserrat().fontFamily,
      // fontFamily: GoogleFonts.poppins().fontFamily,
      fontFamily: GoogleFonts.roboto().fontFamily,
      // fontFamily: GoogleFonts.nunito().fontFamily,
      // fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      // backgroundColor: Colors.white,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.grey,
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: Colors.grey[50],
      textTheme: blackTextTheme,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // brightness: Brightness.light,
      // CUSTOMIZE showDatePicker Colors
      dialogBackgroundColor: Colors.white,
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: Colors.grey[400],
      colorScheme: colorScheme,
      extensions: const [AppSemanticColors.light],
      //
      tabBarTheme: tabBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(Colors.white),
      cardTheme: _cardTheme,
      chipTheme: _chipTheme(Brightness.light),
      useMaterial3: true,
    );
  }

  //
  ThemeData darkTheme() {
    const background = Color(0xFF07111F);
    const surface = Color(0xFF111D2E);
    const surfaceHigh = Color(0xFF18273B);
    const outline = Color(0xFF52627A);
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF5BA2FF),
      onPrimary: Color(0xFF001B3F),
      primaryContainer: Color(0xFF153E70),
      onPrimaryContainer: Color(0xFFD7E8FF),
      secondary: Color(0xFFFFA143),
      onSecondary: Color(0xFF321300),
      secondaryContainer: Color(0xFF5B2D00),
      onSecondaryContainer: Color(0xFFFFDCC2),
      surface: surface,
      onSurface: Color(0xFFF4F7FC),
      surfaceContainerLowest: background,
      surfaceContainerLow: Color(0xFF0C1727),
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: Color(0xFF22334A),
      onSurfaceVariant: Color(0xFFB8C4D5),
      outline: outline,
      outlineVariant: Color(0xFF2B3B51),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF4A2027),
      onErrorContainer: Color(0xFFFFDAD6),
    );

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.roboto().fontFamily,
      primaryColor: AppColor.primaryColor,
      primaryColorDark: AppColor.primaryColorDark,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.primary.withValues(alpha: .35),
        cursorColor: AppColor.cursorColor,
      ),
      cardColor: surface,
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFDCE6F5)),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2B3B51),
        thickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Color(0xFFF4F7FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        dragHandleColor: outline,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogBackgroundColor: surfaceHigh,
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      highlightColor: colorScheme.primary.withValues(alpha: .12),
      splashColor: colorScheme.primary.withValues(alpha: .10),
      colorScheme: colorScheme,
      extensions: const [AppSemanticColors.dark],
      //
      tabBarTheme: tabBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme(surfaceHigh),
      cardTheme: _cardTheme,
      chipTheme: _chipTheme(Brightness.dark),
      useMaterial3: true,
    );
  }

  /// Paleta clara completa.
  ///
  /// Antes se construía con `ColorScheme.light()` sin definir los tonos
  /// contenedores, y Flutter los resuelve con respaldos que aquí hacían daño:
  /// `primaryContainer` caía en `primary` (azul sobre azul, texto invisible),
  /// todos los `surfaceContainer*` caían en blanco (sin jerarquía entre fondo
  /// y tarjeta) y `outlineVariant` caía en negro. El tema oscuro sí estaba
  /// definido, por eso solo se veía mal en claro.
  ///
  /// Los tonos de marca se derivan del color que llega del panel, así que si
  /// se cambia allá, la paleta entera lo sigue.
  ColorScheme _lightColorScheme() {
    const surface = Color(0xFFFFFFFF);
    final primary = AppColor.primaryColor;
    final secondary = AppColor.accentColor;

    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: _readableOn(primary),
      primaryContainer: _softTint(primary, surface, .13),
      onPrimaryContainer: _deepen(primary, .18),
      secondary: secondary,
      onSecondary: _readableOn(secondary),
      secondaryContainer: _softTint(secondary, surface, .15),
      onSecondaryContainer: _deepen(secondary, .22),
      surface: surface,
      onSurface: const Color(0xFF101828),
      surfaceContainerLowest: surface,
      surfaceContainerLow: const Color(0xFFF6F8FB),
      surfaceContainer: const Color(0xFFF1F4F9),
      surfaceContainerHigh: const Color(0xFFEAEFF6),
      surfaceContainerHighest: const Color(0xFFE2E8F1),
      onSurfaceVariant: const Color(0xFF5B6B82),
      outline: const Color(0xFFA6B2C3),
      outlineVariant: const Color(0xFFDFE5EE),
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF8C1D18),
    );
  }

  /// Tono suave del color de marca sobre un fondo, sin quemar un hexadecimal.
  static Color _softTint(Color color, Color background, double alpha) =>
      Color.alphaBlend(color.withValues(alpha: alpha), background);

  /// Versión más oscura, para el texto que va sobre el tono suave.
  static Color _deepen(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Blanco o negro según lo que contraste con el color recibido: el panel
  /// puede configurar un color de marca claro y el texto encima debe leerse.
  static Color _readableOn(Color color) =>
      color.computeLuminance() > .55 ? const Color(0xFF101828) : Colors.white;

  ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(0, 52),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  );

  FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  );

  OutlinedButtonThemeData get _outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  );

  TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );

  InputDecorationTheme _inputDecorationTheme(Color fillColor) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.withValues(alpha: .25)),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: AppColor.primaryColor, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  CardThemeData get _cardTheme => const CardThemeData(
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  );

  ChipThemeData _chipTheme(Brightness brightness) => ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    side: BorderSide(color: Colors.grey.withValues(alpha: .24)),
    labelStyle: TextStyle(
      color: brightness == Brightness.light ? Colors.black87 : Colors.white,
      fontWeight: FontWeight.w600,
    ),
  );

  //MISC
  final TextTheme blackTextTheme = TextTheme(
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineLarge: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.black),
    labelMedium: TextStyle(color: Colors.black),
    labelSmall: TextStyle(color: Colors.black),
  );

  final TextTheme whiteTextTheme = TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
  );

  //
  TabBarThemeData get tabBarTheme {
    return TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Utils.textColorByTheme(),
      unselectedLabelColor: Utils.textColorByTheme(),
      // labelColor: Utils.textColorByTheme(),
      indicator: BoxDecoration(
        // color: AppColor.primaryColor,
        border: Border(
          bottom: BorderSide(color: Utils.textColorByTheme(), width: 3),
        ),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      tabAlignment: TabAlignment.start,
    );
  }
}
