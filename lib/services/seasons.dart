/// المواسم (بالتاريخ الهجري) والوقت واليوم.
/// التاريخ الهجري هنا حسابي، فممكن يفرق يوم أو اتنين عن الرؤية الفعلية،
/// عشان كده الفترات واسعة شوية.
class HijriDate {
  final int year;
  final int month;
  final int day;
  const HijriDate(this.year, this.month, this.day);
}

class Seasons {
  Seasons._();

  static HijriDate hijri(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final yy = date.year + 4800 - a;
    final mm = date.month + 12 * a - 3;
    final jd = date.day +
        ((153 * mm + 2) ~/ 5) +
        365 * yy +
        (yy ~/ 4) -
        (yy ~/ 100) +
        (yy ~/ 400) -
        32045;

    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }

  /// المواسم النشطة دلوقتي (ممكن أكتر من واحد)
  static Set<String> active(DateTime now) {
    final h = hijri(now);
    final m = h.month;
    final d = h.day;
    final s = <String>{};
    if (m == 9 || (m == 8 && d >= 26)) s.add('ramadan');
    if ((m == 9 && d >= 27) || (m == 10 && d <= 4)) s.add('eid_fitr');
    if (m == 12 && d >= 6 && d <= 14) s.add('eid_adha');
    if (m == 3 && d >= 6 && d <= 14) s.add('mawlid');
    if ((m == 12 && d >= 28) || (m == 1 && d <= 4)) s.add('hijri_new_year');
    if (now.month == 10 && now.day <= 8) s.add('october');
    if ((now.month == 12 && now.day >= 25) ||
        (now.month == 1 && now.day <= 3)) {
      s.add('new_year');
    }
    return s;
  }

  /// morning (٥ص-١٢ظ)، evening (١٢ظ-٩م)، night (٩م-٥ص)
  static String slot(DateTime now) {
    final h = now.hour;
    if (h >= 5 && h < 12) return 'morning';
    if (h >= 12 && h < 21) return 'evening';
    return 'night';
  }

  static bool isFriday(DateTime now) => now.weekday == DateTime.friday;
}
