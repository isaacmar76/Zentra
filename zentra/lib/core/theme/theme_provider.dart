import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Provider reactivo para gestionar la selección y persistencia de temas visuales en Zentra.
class ThemeProvider with ChangeNotifier {
  static const String _prefKey = 'zentra_active_theme';
  String _currentThemeId = 'tm_disenos';

  String get currentThemeId => _currentThemeId;

  ZentraThemePalette get currentPalette => AppTheme.getThemeById(_currentThemeId);

  ThemeData get currentThemeData => currentPalette.toThemeData();

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_prefKey);
      if (savedId != null && AppTheme.allThemes.any((t) => t.id == savedId)) {
        _currentThemeId = savedId;
        notifyListeners();
      }
    } catch (_) {
      // Si SharedPreferences no está disponible en la plataforma, mantiene el tema por defecto
    }
  }

  Future<void> setTheme(String themeId) async {
    if (_currentThemeId == themeId) return;

    _currentThemeId = themeId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, themeId);
    } catch (_) {}
  }
}
