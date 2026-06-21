import 'package:flutter/material.dart';

/// Design tokens shared in spirit with the web dashboard
/// (warm paper background, navy ink, marigold accent).
class GurukulColors {
  static const paper = Color(0xFFFAF8F3);
  static const ink = Color(0xFF1E2A4A);
  static const inkLight = Color(0xFF3D4A6B);
  static const marigold = Color(0xFFE08D3C);
  static const marigoldLight = Color(0xFFF2C078);
  static const sage = Color(0xFF3D7A5C);
  static const sageLight = Color(0xFFE4EFE8);
  static const brick = Color(0xFFB23A48);
  static const brickLight = Color(0xFFF5E3E5);
  static const sand = Color(0xFFDDD8CC);
}

ThemeData buildGurukulTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: GurukulColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: GurukulColors.ink,
      primary: GurukulColors.ink,
      secondary: GurukulColors.marigold,
      surface: Colors.white,
      background: GurukulColors.paper,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GurukulColors.paper,
      foregroundColor: GurukulColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: GurukulColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: GurukulColors.sand),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GurukulColors.ink,
        foregroundColor: GurukulColors.paper,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GurukulColors.sand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GurukulColors.sand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GurukulColors.marigold, width: 2),
      ),
    ),
    fontFamily: 'Roboto',
  );
}
