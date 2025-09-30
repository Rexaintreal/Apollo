import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CatProvider extends ChangeNotifier {
  bool _isCatEnabled = true;
  bool _isMotionEnabled = true;
  String _selectedCat = "assets/cat.png";
  double _catSize = 100; // default size
  double _catOpacity = 1.0; // default fully visible

  bool get isCatEnabled => _isCatEnabled;
  bool get isMotionEnabled => _isMotionEnabled;
  String get selectedCat => _selectedCat;
  double get catSize => _catSize;
  double get catOpacity => _catOpacity; 

  // List of available cats
  static const List<String> availableCats = [
    "assets/cat.png",
    "assets/cat2.png",
    "assets/cat3.png",
    "assets/cat4.png",
    "assets/cat5.png",
    "assets/cat7.png",
    "assets/cat8.png",
    "assets/cat9.png",
    "assets/cat10.png",
  ];

  CatProvider() {
    _loadCatPref();
  }

  void toggleCat(bool value) {
    _isCatEnabled = value;
    _saveCatPref();
    notifyListeners();
  }

  void toggleMotion(bool value) {
    _isMotionEnabled = value;
    _saveCatPref();
    notifyListeners();
  }

  void selectCat(String catPath) {
    _selectedCat = catPath;
    _saveCatPref();
    notifyListeners();
  }

  void setCatSize(double size) {
    _catSize = size;
    _saveCatPref();
    notifyListeners();
  }

  void setCatOpacity(double opacity) {
    _catOpacity = opacity;
    _saveCatPref();
    notifyListeners();
  }

  Future<void> _loadCatPref() async {
    final prefs = await SharedPreferences.getInstance();
    _isCatEnabled = prefs.getBool("isCatEnabled") ?? true;
    _isMotionEnabled = prefs.getBool("isMotionEnabled") ?? true;
    _selectedCat = prefs.getString("selectedCat") ?? "assets/cat.png";
    _catSize = prefs.getDouble("catSize") ?? 100;
    _catOpacity = prefs.getDouble("catOpacity") ?? 1.0; 
    notifyListeners();
  }

  Future<void> _saveCatPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isCatEnabled", _isCatEnabled);
    prefs.setBool("isMotionEnabled", _isMotionEnabled);
    prefs.setString("selectedCat", _selectedCat);
    prefs.setDouble("catSize", _catSize);
    prefs.setDouble("catOpacity", _catOpacity); 
  }
}
