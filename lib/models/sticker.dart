import 'package:flutter/material.dart';

class Sticker {
  final String id;
  final String emoji; // بديل مؤقت لحد ما صورة الستيكر تتضاف
  final String label;

  const Sticker({required this.id, required this.emoji, required this.label});

  String get asset => 'assets/stickers/$id.png';
}

class StickerCategory {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final List<Sticker> stickers;

  const StickerCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.stickers,
  });
}
