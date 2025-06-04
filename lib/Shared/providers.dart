// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _mainColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get mainColor => _mainColor;

  ThemeProvider() {
    _loadPreferences();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  void setMainColor(Color color) async {
    _mainColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mainColor', color.value);
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == prefs.getString('themeMode'),
      orElse: () => ThemeMode.system,
    );
    _mainColor = Color(prefs.getInt('mainColor') ?? Colors.blue.value);
    notifyListeners();
  }
}
