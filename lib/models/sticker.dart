import 'package:flutter/material.dart';

class Sticker {
  final int number;
  final List<String> frames; // إطار واحد = رسالة واحدة

  const Sticker({required this.number, required this.frames});

  String get id => 's$number';
  bool get isAnimated => frames.length > 1;
  String get preview => frames.first;
}

class StickerCategory {
  final String title;
  final String emoji;
  final Color color;
  final List<Sticker> stickers;

  /// مناسبة (ramadan, eid_fitr, ...) لو التصنيف موسمي
  final String? season;

  /// وقت (morning, evening, night, friday) لو التصنيف بيتقترح حسب الوقت
  final String? slot;

  /// تصنيف الستيكرات اللي فيها {الاسم}
  final bool isName;

  const StickerCategory({
    required this.title,
    required this.emoji,
    required this.color,
    required this.stickers,
    this.season,
    this.slot,
    this.isName = false,
  });

  bool get special => season != null || slot != null || isName;
}
