import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTheme {
  static const primaryColor = Color(0xFF902923);
  static const secondaryColor = Color(0xFFA22C29);
  static const surfaceColor = Color(0xFF0A100D);
  static const tertiaryColor = Color(0xFFB9BAA3);
  static const onPrimaryColor = Color(0xFFD6D5C9);

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
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorTextStyle: GoogleFonts.abel(
          color: colors.onPrimaryContainer,
        ),
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
    );
  }

  static ThemeData get darkTheme => _themeData(_colorScheme(Brightness.dark));
  // static ThemeData get lightTheme => _themeData(_colorScheme(Brightness.light));
}
