import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import 'recents.dart';
import 'settings.dart';

/// نسخ / مشاركة / واتساب. كلهم بيسجلوا الستيكر في "آخر ما استخدمته"
/// وبيهتزوا اهتزاز خفيف (لو مفعّل من الإعدادات).
class StickerActions {
  StickerActions._();

  /// كل إطارات الستيكر في رسالة واحدة (الإطارات بتظهر تحت بعض)
  static String allText(Sticker s) =>
      s.frames.map(Catalog.forSend).join('\n\n');

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
      ));
  }

  static void _tick(Sticker s) {
    if (AppSettings.instance.haptics) HapticFeedback.lightImpact();
    if (s.number > 0) Recents.instance.add(s.id);
  }

  static Future<void> copyFrame(
      BuildContext context, Sticker s, String frame) async {
    await Clipboard.setData(ClipboardData(text: Catalog.forSend(frame)));
    _tick(s);
    if (context.mounted) _toast(context, 'اتنسخ. الصقه في أي محادثة');
  }

  static Future<void> copyAll(BuildContext context, Sticker s) async {
    await Clipboard.setData(ClipboardData(text: allText(s)));
    _tick(s);
    if (context.mounted) _toast(context, 'اتنسخت كل الإطارات في رسالة واحدة');
  }

  /// نسخ الستيكر كله (إطار واحد أو كل الإطارات حسب نوعه)
  static Future<void> copy(BuildContext context, Sticker s) =>
      s.isAnimated ? copyAll(context, s) : copyFrame(context, s, s.preview);

  static Future<void> share(Sticker s, {String? frame}) async {
    _tick(s);
    await Share.share(frame != null ? Catalog.forSend(frame) : allText(s));
  }

  /// بيفتح واتساب والرسالة جاهزة، وإنت تختار الشخص
  static Future<void> whatsapp(Sticker s, {String? frame}) async {
    _tick(s);
    final text = frame != null ? Catalog.forSend(frame) : allText(s);
    var ok = false;
    try {
      ok = await launchUrl(
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ok) await Share.share(text);
  }
}
