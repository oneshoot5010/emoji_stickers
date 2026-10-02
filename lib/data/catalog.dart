import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sticker.dart';

/// بيقرا ملف assets/stickers.txt بنفس الشكل اللي إنت كاتبه بيه:
///  - سطر عنوان = تصنيف جديد (أول كلمة فيه هي الإيموجي)
///  - "١) ..." بداية ستيكر، و"━━━" نهايته
///  - "---" جوه الستيكر = إطار جديد (رسالة جديدة)
class Catalog {
  Catalog._();

  static const _palette = <Color>[
    Color(0xFFFFE08A),
    Color(0xFFFFC2D6),
    Color(0xFFBFD8FF),
    Color(0xFFC6F0D4),
    Color(0xFFFFB8A8),
    Color(0xFFD9C8FF),
  ];

  static List<StickerCategory> categories = [];
  static List<Sticker> all = [];

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/stickers.txt');
    categories = parse(raw);
    all = [for (final c in categories) ...c.stickers];
  }

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  static int _toInt(String s) {
    var out = '';
    for (final ch in s.split('')) {
      final i = _arabicDigits.indexOf(ch);
      out += i >= 0 ? '$i' : ch;
    }
    return int.parse(out);
  }

  static List<StickerCategory> parse(String raw) {
    final entryStart = RegExp(r'^([٠-٩0-9]+)\) ?(.*)$');
    final result = <StickerCategory>[];

    String? title;
    String emoji = '✨';
    var stickers = <Sticker>[];

    void flush() {
      if (title != null && stickers.isNotEmpty) {
        result.add(StickerCategory(
          title: title!,
          emoji: emoji,
          color: _palette[result.length % _palette.length],
          stickers: stickers,
        ));
      }
      stickers = [];
    }

    int? number;
    var lines = <String>[];

    Sticker build() {
      final frames = <String>[];
      var cur = <String>[];
      for (final l in lines) {
        if (l.trim() == '---') {
          frames.add(cur.join('\n'));
          cur = [];
        } else {
          cur.add(l);
        }
      }
      frames.add(cur.join('\n'));
      return Sticker(
        number: number!,
        frames: [for (final f in frames) f.trimRight()],
      );
    }

    for (final original in raw.split('\n')) {
      // شيل علامات الاتجاه الخفية وأي \r، وسيب المسافات في أول السطر
      final line = original
          .replaceAll('\u200E', '')
          .replaceAll('\u200F', '')
          .replaceAll('\r', '')
          .trimRight();

      if (number != null) {
        // جوه ستيكر
        if (line.startsWith('━')) {
          stickers.add(build());
          number = null;
          lines = [];
        } else {
          lines.add(line);
        }
        continue;
      }

      // برة أي ستيكر
      if (line.trim().isEmpty || line.startsWith('━')) continue;
      final m = entryStart.firstMatch(line);
      if (m != null) {
        number = _toInt(m.group(1)!);
        lines = [m.group(2)!];
      } else {
        // عنوان تصنيف
        flush();
        final t = line.trim();
        final space = t.indexOf(' ');
        if (space > 0) {
          emoji = t.substring(0, space);
          title = t.substring(space + 1).trim();
        } else {
          emoji = '✨';
          title = t;
        }
      }
    }
    flush();
    return result;
  }

  /// النص اللي بيتنسخ/بيتبعت: علامة اتجاه في أول كل سطر عشان الشكل ميتبهدلش في واتساب
  static String forSend(String frame) =>
      frame.split('\n').map((l) => '\u200E$l').join('\n');
}
