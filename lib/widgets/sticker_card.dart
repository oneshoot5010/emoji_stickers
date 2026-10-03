import 'package:flutter/material.dart';
import '../models/sticker.dart';
import '../services/actions.dart';
import '../services/favorites.dart';
import 'animated_text.dart';
import 'sticker_sheet.dart';

class StickerCard extends StatelessWidget {
  final Sticker sticker;
  final Color color;

  const StickerCard({super.key, required this.sticker, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const compact = VisualDensity.compact;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showStickerSheet(context, sticker),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(6, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sticker.isAnimated)
              Padding(
                padding: const EdgeInsets.only(bottom: 6, right: 8),
                child: Chip(
                  label: Text('${sticker.frames.length} إطارات متحركة',
                      style: t.bodySmall),
                  visualDensity: compact,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedStickerText(sticker: sticker),
                  ),
                ),
                SizedBox(
                  width: 84,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: compact,
                        iconSize: 20,
                        tooltip: sticker.isAnimated
                            ? 'نسخ الكل في رسالة واحدة'
                            : 'نسخ',
                        icon: Icon(
                          sticker.isAnimated ? Icons.copy_all : Icons.copy,
                        ),
                        onPressed: () => StickerActions.copy(context, sticker),
                      ),
                      IconButton(
                        visualDensity: compact,
                        iconSize: 20,
                        tooltip: 'مشاركة',
                        icon: const Icon(Icons.share),
                        onPressed: () => StickerActions.share(sticker),
                      ),
                      IconButton(
                        visualDensity: compact,
                        iconSize: 20,
                        tooltip: 'ابعت على واتساب',
                        icon: const Icon(Icons.send),
                        onPressed: () => StickerActions.whatsapp(sticker),
                      ),
                      ListenableBuilder(
                        listenable: Favorites.instance,
                        builder: (_, __) {
                          final fav = Favorites.instance.has(sticker.id);
                          return IconButton(
                            visualDensity: compact,
                            iconSize: 20,
                            tooltip: fav ? 'شيل من المفضلة' : 'ضيف للمفضلة',
                            icon: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              color: fav ? const Color(0xFFE53935) : null,
                            ),
                            onPressed: () =>
                                Favorites.instance.toggle(sticker.id),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
