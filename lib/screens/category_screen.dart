import 'package:flutter/material.dart';
import '../models/sticker.dart';
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
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: color),
      body: stickers.isEmpty
          ? Center(child: Text(emptyText))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stickers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              s.preview,
                              style: const TextStyle(fontSize: 22, height: 1.35),
                            ),
                          ),
                        ),
                        if (s.isAnimated)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text('${s.frames.length} رسائل',
                                  style: t.bodySmall),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        IconButton(
                          tooltip: 'نسخ',
                          icon: const Icon(Icons.copy),
                          onPressed: () => copyFrame(context, s.preview),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
