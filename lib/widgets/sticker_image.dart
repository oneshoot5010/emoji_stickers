import 'package:flutter/material.dart';
import '../models/sticker.dart';

class StickerImage extends StatelessWidget {
  final Sticker sticker;
  final double size;

  const StickerImage({super.key, required this.sticker, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      sticker.asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          child: Text(sticker.emoji, style: TextStyle(fontSize: size)),
        ),
      ),
    );
  }
}
