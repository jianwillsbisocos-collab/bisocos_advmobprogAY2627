import 'package:flutter/material.dart';

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); }
}
