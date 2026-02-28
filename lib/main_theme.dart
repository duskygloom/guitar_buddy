import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTheme {
  static const primaryColor = Color(0xFFB3B7EE);
  static const secondaryColor = Color(0xFF9395D3);
  static const surfaceColor = Color(0xFF000807);
  static const tertiaryColor = Color(0xFFA2A3BB);
  static const onPrimaryColor = Color(0xFFFBF9FF);

  static ColorScheme _colorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColor,
    );
  }

  static ThemeData _themeData(ColorScheme colors) {
    final typography = Typography.material2021(colorScheme: colors);
    final textTheme = GoogleFonts.abelTextTheme(typography.white);
    return ThemeData.from(colorScheme: colors, textTheme: textTheme).copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainer.withAlpha(220),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: colors.primaryContainer),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: colors.primaryContainer),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: colors.errorContainer),
        ),
        fillColor: colors.surfaceBright.withAlpha(100),
        labelStyle: textTheme.labelSmall?.copyWith(color: colors.onSurface),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.onSurface),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        insetPadding: EdgeInsets.zero,
        backgroundColor: colors.surfaceContainer,
      ),
      popupMenuTheme: PopupMenuThemeData(
        menuPadding: EdgeInsets.zero,
        color: colors.surfaceContainer.withAlpha(245),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(colors.tertiary),
          foregroundColor: WidgetStatePropertyAll(colors.onTertiary),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        strokeCap: StrokeCap.round,
      ),
    );
  }

  static ThemeData get darkTheme => _themeData(_colorScheme(Brightness.dark));
  // static ThemeData get lightTheme => _themeData(_colorScheme(Brightness.light));
}
