import 'package:flutter/material.dart';
import '../models/sticker.dart';

// بيانات تجريبية. استبدلها بالـ150+ ستيكر بتوعك.
const categories = <StickerCategory>[
  StickerCategory(
    id: 'happy',
    title: 'فرحان',
    emoji: '😄',
    color: Color(0xFFFFE08A),
    stickers: [
      Sticker(id: 'happy_1', emoji: '😄', label: 'ضحكة'),
      Sticker(id: 'happy_2', emoji: '🥳', label: 'احتفال'),
      Sticker(id: 'happy_3', emoji: '😍', label: 'عاشق'),
      Sticker(id: 'happy_4', emoji: '🤩', label: 'مبهور'),
    ],
  ),
  StickerCategory(
    id: 'sad',
    title: 'زعلان',
    emoji: '😢',
    color: Color(0xFFBFD8FF),
    stickers: [
      Sticker(id: 'sad_1', emoji: '😢', label: 'عياط'),
      Sticker(id: 'sad_2', emoji: '😔', label: 'حزين'),
      Sticker(id: 'sad_3', emoji: '🥺', label: 'محتاج حضن'),
    ],
  ),
  StickerCategory(
    id: 'angry',
    title: 'متضايق',
    emoji: '😡',
    color: Color(0xFFFFB8A8),
    stickers: [
      Sticker(id: 'angry_1', emoji: '😡', label: 'غضبان'),
      Sticker(id: 'angry_2', emoji: '🙄', label: 'زهقان'),
      Sticker(id: 'angry_3', emoji: '😤', label: 'نرفزة'),
    ],
  ),
  StickerCategory(
    id: 'rush',
    title: 'مستعجل',
    emoji: '🏃',
    color: Color(0xFFC6F0D4),
    stickers: [
      Sticker(id: 'rush_1', emoji: '🏃', label: 'جاي بسرعة'),
      Sticker(id: 'rush_2', emoji: '⏰', label: 'اتأخرت'),
      Sticker(id: 'rush_3', emoji: '🔥', label: 'حالًا'),
    ],
  ),
];

final allStickers = <Sticker>[for (final c in categories) ...c.stickers];
