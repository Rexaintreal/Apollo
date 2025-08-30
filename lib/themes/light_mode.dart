import 'package:flutter/material.dart';

/// iOS Light Mode Theme
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF2F2F7), 
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFFFFFFF),     
    primary: Color(0xFFFFFFFF),
    secondary: Color(0xFFF2F2F7),  
    inversePrimary: Color(0xFF000000),
    tertiary: Color(0xFF007AFF),    
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF000000)),
    titleTextStyle: TextStyle(
      color: Color(0xFF000000),
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: 0.5,
    ),
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF000000)),
    bodyMedium: TextStyle(color: Color(0xFF3C3C43)),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFFFFFFFF),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);

