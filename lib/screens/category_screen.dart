import 'package:flutter/material.dart';
import '../models/sticker.dart';
import '../widgets/sticker_image.dart';
import '../widgets/sticker_sheet.dart';

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
      appBar: AppBar(title: Text(title), backgroundColor: color),
      body: stickers.isEmpty
          ? Center(child: Text(emptyText))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: stickers.length,
              itemBuilder: (_, i) {
                final s = stickers[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => showStickerSheet(context, s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: StickerImage(sticker: s, size: 80),
                  ),
                );
              },
            ),
    );
  }
}
