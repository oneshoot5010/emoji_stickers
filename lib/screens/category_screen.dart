import 'package:flutter/material.dart';
import '../models/sticker.dart';
import '../theme.dart';
import '../widgets/sticker_card.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final Color color;
  final List<Sticker> stickers;
  final String emptyText;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.color,
    required this.stickers,
    this.emptyText = 'مفيش ستيكرات هنا لسه',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: kInk,
      ),
      body: stickers.isEmpty
          ? Center(child: Text(emptyText))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stickers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  StickerCard(sticker: stickers[i], color: color),
            ),
    );
  }
}
