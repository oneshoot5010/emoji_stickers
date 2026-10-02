import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/sticker.dart';
import '../services/favorites.dart';
import 'sticker_image.dart';

void showStickerSheet(BuildContext context, Sticker sticker) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => _StickerSheet(sticker: sticker),
  );
}

class _StickerSheet extends StatelessWidget {
  final Sticker sticker;
  const _StickerSheet({required this.sticker});

  Future<void> _share(BuildContext context) async {
    try {
      final data = await rootBundle.load(sticker.asset);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${sticker.id}.png');
      await file.writeAsBytes(data.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      // لسه مفيش صورة للستيكر، نشارك الإيموجي كنص
      await Share.share(sticker.emoji);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StickerImage(sticker: sticker, size: 160),
            const SizedBox(height: 8),
            Text(sticker.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _share(context),
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                  ),
                ),
                const SizedBox(width: 12),
                ListenableBuilder(
                  listenable: Favorites.instance,
                  builder: (_, __) {
                    final fav = Favorites.instance.has(sticker.id);
                    return IconButton.outlined(
                      onPressed: () => Favorites.instance.toggle(sticker.id),
                      tooltip: fav ? 'شيل من المفضلة' : 'ضيف للمفضلة',
                      icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
