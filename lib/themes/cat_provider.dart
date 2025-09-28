import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatProvider extends ChangeNotifier {
  bool _isCatEnabled = true;

  bool get isCatEnabled => _isCatEnabled;

  CatProvider() {
    _loadCatPref();
  }

  void toggleCat(bool value) {
    _isCatEnabled = value;
    _saveCatPref();
    notifyListeners();
  }

  Future<void> _loadCatPref() async {
    final prefs = await SharedPreferences.getInstance();
    _isCatEnabled = prefs.getBool("isCatEnabled") ?? true;
    notifyListeners();
  }

  Future<void> _saveCatPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isCatEnabled", _isCatEnabled);
  }
}
