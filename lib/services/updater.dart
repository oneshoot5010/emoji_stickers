import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بيستخدمه main.dart عشان يظهر رسالة "اتحدثت الستيكرات"
final GlobalKey<ScaffoldMessengerState> appMessenger =
    GlobalKey<ScaffoldMessengerState>();

/// بيجيب ملف الستيكرات من GitHub، ولو مفيش نت التطبيق بيكمل بالملف اللي جواه.
/// (المستودع لازم يكون Public عشان التحديث الأونلاين يشتغل.)
class StickerUpdater {
  StickerUpdater._();

  static const url =
      'https://raw.githubusercontent.com/oneshoot5010/emoji_stickers/main/assets/stickers.txt';

  static const _kCache = 'stickers_cache';
  static const _kSig = 'stickers_cache_sig';

  /// النسخة المحفوظة، بس لو كانت متحفظة مع نفس نسخة التطبيق.
  /// لو نزلت APK جديد فيه ستيكرات تانية، الكاش القديم بيتتجاهل.
  static Future<String?> cachedFor(String bundled) async {
    try {
      final p = await SharedPreferences.getInstance();
      final text = p.getString(_kCache);
      final sig = p.getInt(_kSig);
      if (text == null || sig != bundled.length) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String text, String bundled) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kCache, text);
      await p.setInt(_kSig, bundled.length);
    } catch (_) {}
  }

  static Future<String?> fetch() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return await res
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }
}
