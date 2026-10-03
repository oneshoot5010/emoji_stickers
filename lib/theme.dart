import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kInk = Color(0xFF1B2A41);
const kBlueTop = Color(0xFF4FC3F7);
const kBlueBottom = Color(0xFF1565C0);
const kYellow = Color(0xFFFFD54F);

ThemeData buildTheme(Brightness b) {
  final light = b == Brightness.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1E88E5),
    brightness: b,
    surface: light ? const Color(0xFFF2F8FF) : const Color(0xFF0E1726),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
  );
}

/// خط الستيكرات: نفس خط واتساب على أندرويد (Roboto)، عشان الشكل في التطبيق
/// يطلع زي الشكل بعد ما تبعته (الراس فوق الجسم بالظبط).
TextStyle stickerStyle(double size) => TextStyle(
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Noto Color Emoji', 'Noto Sans Arabic'],
      fontSize: size,
      height: 1.35,
    );
