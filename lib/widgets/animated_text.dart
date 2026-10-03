import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sticker.dart';
import '../services/settings.dart';

/// بيعرض الستيكر. لو متحرك، الإطارات بتتبدّل لوحدها كل ٠٫٦ ثانية.
class AnimatedStickerText extends StatefulWidget {
  final Sticker sticker;
  final double fontSize;

  const AnimatedStickerText({
    super.key,
    required this.sticker,
    this.fontSize = 22,
  });

  @override
  State<AnimatedStickerText> createState() => _AnimatedStickerTextState();
}

class _AnimatedStickerTextState extends State<AnimatedStickerText> {
  Timer? _timer;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    if (!widget.sticker.isAnimated) return;
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted) return;
      setState(() {
        _i = (_i + 1) % widget.sticker.frames.length;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedStickerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sticker.number != widget.sticker.number) {
      _timer?.cancel();
      _timer = null;
      _i = 0;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sticker;
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final size = widget.fontSize * AppSettings.instance.fontScale;
        final frame = s.frames[_i % s.frames.length];
        final text = Directionality(
          textDirection: TextDirection.ltr,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(frame, style: TextStyle(fontSize: size, height: 1.35)),
          ),
        );
        if (!s.isAnimated) return text;
        // نثبّت الارتفاع على أطول إطار عشان الكارت ميتنططش
        var lines = 1;
        for (final f in s.frames) {
          final n = '\n'.allMatches(f).length + 1;
          if (n > lines) lines = n;
        }
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: lines * size * 1.35),
          child: Align(alignment: Alignment.centerLeft, child: text),
        );
      },
    );
  }
}
