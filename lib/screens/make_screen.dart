import 'package:flutter/material.dart';
import '../widgets/whatsapp_icon.dart';
import '../models/sticker.dart';
import '../services/actions.dart';
import '../theme.dart';

// إيموجي قديمة (٢٠١٩ وأقدم) عشان تظهر على كل الموبايلات
const _heads = <String>[
  '😀', '😄', '😁', '😂', '🤣', '😊', '😍', '🥰', '😘', '😎', '🤔', '😴',
  '😭', '😡', '😱', '😅', '😉', '🙄', '😏', '😌', '😋', '🤤', '😢', '🥺',
  '🤗', '🤩', '😇', '🙃', '😬', '😤', '🤯', '😳',
];

const _hands = <String>[
  '', '☕', '🍕', '🍔', '🍟', '🍪', '🍫', '🍦', '🍉', '🎂', '🎁', '💐',
  '🌹', '📱', '💻', '📖', '📝', '🎮', '⚽', '🏀', '🎧', '🎤', '📸', '🔥',
  '💦', '💨', '❤️', '💰', '🔑', '🛒', '🚗', '✈️', '🕌', '🌙', '⭐', '🎉',
  '🎈', '📞', '☂️', '⏰',
];

/// "اعمل ستيكرك": تختار الوش واللي في إيده وتكتب جملة
class MakeScreen extends StatefulWidget {
  const MakeScreen({super.key});

  @override
  State<MakeScreen> createState() => _MakeScreenState();
}

class _MakeScreenState extends State<MakeScreen> {
  String _head = '😎';
  String _hand = '☕';
  final TextEditingController _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  String get _text {
    final sb = StringBuffer();
    sb.writeln('    $_head');
    sb.writeln('    /[]\\$_hand');
    sb.write('     /\\');
    final c = _caption.text.trim();
    if (c.isNotEmpty) sb.write('\n$c');
    return sb.toString();
  }

  Sticker get _sticker => Sticker(number: 0, frames: [_text]);

  Widget _picker(List<String> items, String selected, void Function(String) onPick) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final e in items)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onPick(e),
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: e == selected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: e == selected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
              ),
              child: e.isEmpty
                  ? const Text('بدون', style: TextStyle(fontSize: 11))
                  : Text(e, style: const TextStyle(fontSize: 24)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = _sticker;
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعمل ستيكرك'),
        backgroundColor: const Color(0xFF81D4FA),
        foregroundColor: kInk,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(_text,
                    style: stickerStyle(30)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => StickerActions.copy(context, s),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('نسخ'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => StickerActions.share(s),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('مشاركة'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => StickerActions.whatsapp(s),
                  icon: const WhatsAppIcon(size: 20),
                  label: const Text('واتساب'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('جملة تحت الشخصية (اختياري)', style: t.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _caption,
            maxLength: 40,
            decoration: const InputDecoration(
              hintText: 'مثلاً: صباح الفل',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('الوش', style: t.titleSmall),
          const SizedBox(height: 8),
          _picker(_heads, _head, (e) => setState(() => _head = e)),
          const SizedBox(height: 20),
          Text('اللي في إيده', style: t.titleSmall),
          const SizedBox(height: 8),
          _picker(_hands, _hand, (e) => setState(() => _hand = e)),
        ],
      ),
    );
  }
}
