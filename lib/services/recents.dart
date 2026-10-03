import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// آخر 20 ستيكر اتنسخوا أو اتبعتوا
class Recents extends ChangeNotifier {
  Recents._();
  static final Recents instance = Recents._();

  static const _key = 'recent_stickers';
  static const _max = 20;
  final List<String> _ids = [];
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(_prefs!.getStringList(_key) ?? const <String>[]);
  }

  List<String> get ids => List<String>.unmodifiable(_ids);

  Future<void> add(String id) async {
    _ids.remove(id);
    _ids.insert(0, id);
    if (_ids.length > _max) _ids.removeRange(_max, _ids.length);
    notifyListeners();
    await _prefs?.setStringList(_key, List<String>.from(_ids));
  }

  Future<void> clear() async {
    _ids.clear();
    notifyListeners();
    await _prefs?.remove(_key);
  }
}
