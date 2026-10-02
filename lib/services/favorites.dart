import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favorites extends ChangeNotifier {
  Favorites._();
  static final Favorites instance = Favorites._();

  static const _key = 'favorite_stickers';
  final Set<String> _ids = {};
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _ids.addAll(_prefs!.getStringList(_key) ?? const []);
  }

  bool has(String id) => _ids.contains(id);
  List<String> get ids => _ids.toList();

  Future<void> toggle(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    await _prefs?.setStringList(_key, _ids.toList());
  }

  Future<void> clear() async {
    _ids.clear();
    notifyListeners();
    await _prefs?.remove(_key);
  }
}
