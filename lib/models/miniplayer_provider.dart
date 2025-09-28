import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniPlayerProvider extends ChangeNotifier {
  bool _isMiniPlayerEnabled = true;

  MiniPlayerProvider() {
    _loadMiniPlayerPreference();
  }

  bool get isMiniPlayerEnabled => _isMiniPlayerEnabled;

  void toggleMiniPlayer(bool value) {
    _isMiniPlayerEnabled = value;
    _saveMiniPlayerPreference();
    notifyListeners();
  }

  Future<void> _loadMiniPlayerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isMiniPlayerEnabled = prefs.getBool('miniPlayerEnabled') ?? true;
    notifyListeners();
  }

  Future<void> _saveMiniPlayerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('miniPlayerEnabled', _isMiniPlayerEnabled);
  }
}