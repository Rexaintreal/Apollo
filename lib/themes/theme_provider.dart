import 'package:flutter/material.dart';
import 'package:apollo/themes/dark_mode.dart';
import 'package:apollo/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially light mode

  ThemeData _themeData = lightMode;

  // get theme
  ThemeData get themeData => _themeData;

  // is dark mode 
  bool get isDarkMode => _themeData == darkMode;

  // set theme 
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // update ui
    notifyListeners();
  }

  // toggle theme
  void toggleTheme(bool value) {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }

}