import 'package:flutter/material.dart';

/// iOS Dark Mode Theme
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF000000), // iOS systemBackground dark
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1C1C1E),      // iOS secondarySystemBackground dark
    primary: Color(0xFF1C1C1E),
    secondary: Color(0xFF2C2C2E),
    inversePrimary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF0A84FF),     // iOS systemBlue dark
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF000000),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
    titleTextStyle: TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0.5,
    ),
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
    bodyMedium: TextStyle(color: Color(0xFFEBEBF5)), // iOS secondaryLabel dark
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1C1C1E),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);