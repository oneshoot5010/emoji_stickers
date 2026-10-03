import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sticker.dart';
import '../services/settings.dart';
import '../services/updater.dart';

/// بيقرا ملف assets/stickers.txt بنفس الشكل اللي إنت كاتبه بيه:
///  - سطر عنوان = تصنيف جديد (أول كلمة فيه هي الإيموجي)
///  - "١) ..." بداية ستيكر، و"━━━" نهايته
///  - "---" جوه الستيكر = إطار جديد (رسالة جديدة)
class Catalog {
  Catalog._();

  static const _palette = <Color>[
    Color(0xFFFFE082),
    Color(0xFF81D4FA),
    Color(0xFFFFAB91),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFFFFCC80),
  ];

  static List<StickerCategory> categories = [];
  static List<Sticker> all = [];

  /// بيزيد كل ما الستيكرات تتغير (تحديث من النت أو تغيير الاسم)
  static final ValueNotifier<int> changed = ValueNotifier<int>(0);

  static String _bundledRaw = '';
  static String _raw = '';

  static Future<void> load() async {
    _bundledRaw = await rootBundle.loadString('assets/stickers.txt');
    final cached = await StickerUpdater.cachedFor(_bundledRaw);
    _raw = cached ?? _bundledRaw;
    rebuild(notify: false);
  }

  /// {الاسم} بيتبدّل بالاسم، و{مذكر|مؤنث} بيتختار حسب نوع الاسم
  static final _genderForm = RegExp(r'\{([^{}|]+)\|([^{}|]+)\}');

  static String _applyName(String raw, String name) {
    final female = AppSettings.instance.isFemale;
    return raw
        .replaceAll('{الاسم}', name.isEmpty ? 'صاحبي' : name)
        .replaceAllMapped(
          _genderForm,
          (m) => female ? m.group(2)! : m.group(1)!,
        );
  }

  /// بيعيد قراءة الستيكرات (بعد تغيير الاسم مثلًا)
  static void rebuild({bool notify = true}) {
    final name = AppSettings.instance.name.trim();
    var parsed = <StickerCategory>[];
    try {
      parsed = parse(_applyName(_raw, name));
    } catch (_) {}
    if (parsed.isEmpty) {
      parsed = parse(_applyName(_bundledRaw, name));
    }
    categories = parsed;
    all = [for (final c in categories) ...c.stickers];
    if (notify) changed.value++;
  }

  /// بيجيب أحدث ملف ستيكرات من GitHub. null = فشل (مفيش نت أو الملف مش متاح)
  static Future<UpdateResult?> refreshOnline() async {
    final text = await StickerUpdater.fetch();
    if (text == null) return null;
    if (text == _raw) return const UpdateResult(changed: false, delta: 0);
    var count = 0;
    try {
      final test = parse(_applyName(text, 'x'));
      count = [for (final c in test) ...c.stickers].length;
    } catch (_) {
      return null;
    }
    // حماية: ملف ناقص أو بايظ ما يبدّلش اللي عندنا
    if (count < 100) return null;
    final before = all.length;
    _raw = text;
    await StickerUpdater.save(text, _bundledRaw);
    rebuild();
    return UpdateResult(changed: true, delta: all.length - before);
  }

  /// التصنيف "قصص" = كل ستيكراته نص عادي (مش شخصية /[]\ ومش متحرك)
  static bool isStories(StickerCategory c) => c.stickers.every(
        (s) => !s.isAnimated && !s.preview.contains('/[]'),
      );

  static List<StickerCategory> get regular =>
      categories.where((c) => !c.special && !isStories(c)).toList();

  static List<StickerCategory> get stories =>
      categories.where((c) => !c.special && isStories(c)).toList();

  static List<StickerCategory> get seasonal =>
      categories.where((c) => c.season != null).toList();

  static StickerCategory? get nameCategory {
    for (final c in categories) {
      if (c.isName) return c;
    }
    return null;
  }

  static StickerCategory? bySlot(String slot) {
    for (final c in categories) {
      if (c.slot == slot) return c;
    }
    return null;
  }

  static String shortTitle(StickerCategory c) =>
      c.title.replaceFirst(RegExp(r'^قصص:\s*'), '');

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
    String? season;
    String? slot;
    var isName = false;
    var stickers = <Sticker>[];

    void flush() {
      if (title != null && stickers.isNotEmpty) {
        result.add(StickerCategory(
          title: title!,
          emoji: emoji,
          color: _palette[result.length % _palette.length],
          stickers: stickers,
          season: season,
          slot: slot,
          isName: isName,
        ));
      }
      stickers = [];
    }

    int? number;
    var lines = <String>[];

    Sticker build() {
      final frames = <List<String>>[];
      var cur = <String>[];
      for (final l in lines) {
        if (l.trim() == '---') {
          frames.add(cur);
          cur = [];
        } else {
          cur.add(l);
        }
      }
      frames.add(cur);

      // رقم الستيكر ("١٩) ") كان واخد مكان في أول سطر، وإحنا شيلناه.
      // لازم نرجّع نفس المسافة عشان الراس تفضل فوق الجسم.
      int indentOf(String x) => x.length - x.trimLeft().length;
      var pad = 0;
      final first = frames.first;
      final body = first.indexWhere((l) => l.contains('/['));
      if (body > 0) {
        // الشخصية: المسافات قبل الراس مكتوبة في الملف نفسه (متحسبة بالمقاس)
        pad = 0;
      } else if (frames.length > 1 && frames[1].isNotEmpty) {
        pad = indentOf(frames[1].first);
      }
      first[0] = ' ' * pad + first[0];

      return Sticker(
        number: number!,
        frames: [for (final f in frames) f.join('\n').trimRight()],
      );
    }

    for (final original in raw.split('\n')) {
      // شيل علامات الاتجاه الخفية وأي \r، وسيب المسافات في أول السطر
      final line = original
          .replaceAll('\u200E', '')
          .replaceAll('\u200F', '')
          .replaceAll('\uFEFF', '')
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
        // عنوان تصنيف (ممكن يكون في آخره علامات زي |s=ramadan أو |t=morning أو |name)
        flush();
        final parts = line.trim().split('|');
        final main = parts.first.trim();
        season = null;
        slot = null;
        isName = false;
        for (final p in parts.skip(1)) {
          final tag = p.trim();
          if (tag.startsWith('s=')) {
            season = tag.substring(2);
          } else if (tag.startsWith('t=')) {
            slot = tag.substring(2);
          } else if (tag == 'name') {
            isName = true;
          }
        }
        final space = main.indexOf(' ');
        if (space > 0) {
          emoji = main.substring(0, space);
          if (emoji == '🆕') emoji = '✨';
          title = main.substring(space + 1).trim();
        } else {
          emoji = '✨';
          title = main;
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

class UpdateResult {
  final bool changed;
  final int delta;
  const UpdateResult({required this.changed, required this.delta});
}
