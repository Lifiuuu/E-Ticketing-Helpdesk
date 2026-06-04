import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(): super(ThemeMode.system) {
    _load();
  }

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
  void toggle() => state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  static const _prefKey = 'app_theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(_prefKey);
      if (v == 'light') {
        state = ThemeMode.light;
      } else if (v == 'dark') state = ThemeMode.dark;
      else if (v == 'system') state = ThemeMode.system;
    } catch (_) {}
  }

  Future<void> _save(String v) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, v);
    } catch (_) {}
  }

  @override
  set state(ThemeMode value) {
    super.state = value;
    // persist
    if (value == ThemeMode.light) {
      _save('light');
    } else if (value == ThemeMode.dark) _save('dark');
    else _save('system');
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
