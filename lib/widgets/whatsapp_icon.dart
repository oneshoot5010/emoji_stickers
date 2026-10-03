import 'package:flutter/material.dart';

/// أيقونة واتساب (الفقاعة الخضرا مع السماعة)
class WhatsAppIcon extends StatelessWidget {
  final double size;
  const WhatsAppIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/icon/whatsapp.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      );
}
