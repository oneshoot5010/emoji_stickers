import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _kMode = 'theme_mode';
  static const _kScale = 'font_scale';
  static const _kHaptics = 'haptics';
  static const _kName = 'user_name';

  ThemeMode _mode = ThemeMode.system;
  double _scale = 1.0;
  bool _haptics = true;
  String _name = '';
  SharedPreferences? _prefs;

  ThemeMode get mode => _mode;
  double get fontScale => _scale;
  bool get haptics => _haptics;
  String get name => _name;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    switch (_prefs!.getString(_kMode)) {
      case 'dark':
        _mode = ThemeMode.dark;
      case 'light':
        _mode = ThemeMode.light;
      default:
        _mode = ThemeMode.system;
    }
    _scale = _prefs!.getDouble(_kScale) ?? 1.0;
    _haptics = _prefs!.getBool(_kHaptics) ?? true;
    _name = _prefs!.getString(_kName) ?? '';
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    await _prefs?.setString(_kMode, m.name);
  }

  Future<void> setFontScale(double v) async {
    _scale = v;
    notifyListeners();
    await _prefs?.setDouble(_kScale, v);
  }

  Future<void> setHaptics(bool v) async {
    _haptics = v;
    notifyListeners();
    await _prefs?.setBool(_kHaptics, v);
  }

  /// بعد ما تنادي الدالة دي، نادي Catalog.rebuild() عشان الاسم يتحط في الستيكرات
  Future<void> setName(String v) async {
    _name = v.trim();
    await _prefs?.setString(_kName, _name);
  }
}
