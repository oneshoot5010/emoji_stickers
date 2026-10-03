import 'dart:math';
import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../services/actions.dart';
import '../services/favorites.dart';
import '../services/settings.dart';
import 'animated_text.dart';
import 'whatsapp_icon.dart';
import '../theme.dart';

void showStickerSheet(BuildContext context, Sticker sticker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _StickerSheet(sticker: sticker),
  );
}

/// زرار "فاجئني": ستيكر عشوائي، وزرار "واحد تاني"
void showSurprise(BuildContext context) {
  if (Catalog.all.isEmpty) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _SurpriseSheet(),
  );
}

class _SurpriseSheet extends StatefulWidget {
  const _SurpriseSheet();

  @override
  State<_SurpriseSheet> createState() => _SurpriseSheetState();
}

class _SurpriseSheetState extends State<_SurpriseSheet> {
  final Random _rnd = Random();
  late Sticker _s = _pick();

  Sticker _pick() => Catalog.all[_rnd.nextInt(Catalog.all.length)];

  @override
  Widget build(BuildContext context) {
    return _StickerSheet(
      key: ValueKey(_s.number),
      sticker: _s,
      onAnother: () => setState(() => _s = _pick()),
    );
  }
}

class _StickerSheet extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback? onAnother;
  const _StickerSheet({super.key, required this.sticker, this.onAnother});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scale = AppSettings.instance.fontScale;
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
                          ? 'متحرك: ${sticker.frames.length} إطارات'
                          : 'ستيكر',
                      style: t.titleMedium,
                    ),
                  ),
                  if (onAnother != null)
                    TextButton.icon(
                      onPressed: onAnother,
                      icon: const Icon(Icons.casino, size: 18),
                      label: const Text('واحد تاني'),
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
                          color: fav ? const Color(0xFFE53935) : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (sticker.isAnimated) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedStickerText(sticker: sticker, fontSize: 24),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            StickerActions.copyAll(context, sticker),
                        icon: const Icon(Icons.copy_all, size: 18),
                        label: const Text('نسخ الكل'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => StickerActions.whatsapp(sticker),
                        icon: const WhatsAppIcon(size: 20),
                        label: const Text('واتساب (الكل)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'الكل في رسالة واحدة بيظهر الإطارات تحت بعض. عشان يتحرك فعلًا: انسخ كل إطار لوحده وابعته ورا اللي قبله.',
                  style: t.bodySmall,
                ),
              ],
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
                              child: Text('إطار ${i + 1}', style: t.bodySmall),
                            ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  frame,
                                  style: stickerStyle(24 * scale),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () => StickerActions.copyFrame(
                                    context, sticker, frame),
                                icon: const Icon(Icons.copy, size: 18),
                                label: Text(
                                  sticker.isAnimated ? 'نسخ الإطار' : 'نسخ',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => StickerActions.share(sticker,
                                    frame: frame),
                                icon: const Icon(Icons.share, size: 18),
                                label: const Text('مشاركة'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => StickerActions.whatsapp(
                                    sticker,
                                    frame: frame),
                                icon: const WhatsAppIcon(size: 20),
                                label: const Text('واتساب'),
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
