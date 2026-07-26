import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTheme {
  static const color1 = Color(0xFF040F0F);
  static const color2 = Color(0xFFC9FBFF);
  static const color3 = Color(0xFF85BDBF);
  static const color4 = Color(0xFFC2FCF7);
  static const color5 = Color(0xFF57737A);

  static ColorScheme _colorScheme(Brightness brightness) {
    final Color primaryColor;
    if (brightness == Brightness.dark) {
      primaryColor = color3;
    } else {
      primaryColor = color5;
    }
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );
  }

  static ThemeData _themeData(ColorScheme colors) {
    final typography = Typography.material2021(colorScheme: colors);
    final TextTheme textTheme;
    final Color inputFill;
    if (colors.brightness == Brightness.dark) {
      textTheme = GoogleFonts.abelTextTheme(typography.white);
      inputFill = colors.surfaceBright;
    } else {
      textTheme = GoogleFonts.abelTextTheme(typography.black);
      inputFill = colors.surfaceDim;
    }

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
          borderSide: BorderSide(width: 2, color: colors.primary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 2, color: colors.errorContainer),
        ),
        fillColor: inputFill.withAlpha(100),
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
  static ThemeData get lightTheme => _themeData(_colorScheme(Brightness.light));

  static Duration get clickDelay => Duration(milliseconds: 150);
}
