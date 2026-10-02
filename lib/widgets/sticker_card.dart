import 'package:flutter/material.dart';
import '../models/sticker.dart';
import 'sticker_sheet.dart';

class StickerCard extends StatelessWidget {
  final Sticker sticker;
  final Color color;

  const StickerCard({super.key, required this.sticker, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showStickerSheet(context, sticker),
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
                  sticker.preview,
                  style: const TextStyle(fontSize: 22, height: 1.35),
                ),
              ),
            ),
            if (sticker.isAnimated)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('${sticker.frames.length} رسائل',
                      style: t.bodySmall),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            IconButton(
              tooltip: 'نسخ',
              icon: const Icon(Icons.copy),
              onPressed: () => copyFrame(context, sticker.preview),
            ),
          ],
        ),
      ),
    );
  }
}
