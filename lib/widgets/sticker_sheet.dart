import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../services/favorites.dart';

Future<void> copyFrame(BuildContext context, String frame) async {
  await Clipboard.setData(ClipboardData(text: Catalog.forSend(frame)));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('اتنسخ. الصقه في أي محادثة'),
        duration: Duration(seconds: 1),
      ));
  }
}

void showStickerSheet(BuildContext context, Sticker sticker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StickerSheet(sticker: sticker),
  );
}

class _StickerSheet extends StatelessWidget {
  final Sticker sticker;
  const _StickerSheet({required this.sticker});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sticker.isAnimated
                          ? 'متحرك: ${sticker.frames.length} رسائل بالترتيب'
                          : 'ستيكر',
                      style: t.titleMedium,
                    ),
                  ),
                  ListenableBuilder(
                    listenable: Favorites.instance,
                    builder: (_, __) {
                      final fav = Favorites.instance.has(sticker.id);
                      return IconButton(
                        onPressed: () => Favorites.instance.toggle(sticker.id),
                        tooltip: fav ? 'شيل من المفضلة' : 'ضيف للمفضلة',
                        icon: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sticker.frames.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final frame = sticker.frames[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sticker.isAnimated)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('رسالة ${i + 1}', style: t.bodySmall),
                            ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                frame,
                                style: const TextStyle(fontSize: 24, height: 1.35),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () => copyFrame(context, frame),
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('نسخ'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    Share.share(Catalog.forSend(frame)),
                                icon: const Icon(Icons.share, size: 18),
                                label: const Text('مشاركة'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
