import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    switch (_prefs!.getString(_key)) {
      case 'dark':
        _mode = ThemeMode.dark;
      case 'light':
        _mode = ThemeMode.light;
      default:
        _mode = ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    await _prefs?.setString(_key, m.name);
  }
}
