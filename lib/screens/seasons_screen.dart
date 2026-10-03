import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../services/seasons.dart';
import '../theme.dart';
import 'category_screen.dart';

/// كل المواسم والمناسبات. اللي وقتها دلوقتي بيطلع فوق.
class SeasonsScreen extends StatelessWidget {
  const SeasonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = Seasons.active(DateTime.now());
    final all = Catalog.seasonal;
    final cats = [
      for (final c in all)
        if (active.contains(c.season)) c,
      for (final c in all)
        if (!active.contains(c.season)) c,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواسم ومناسبات'),
        backgroundColor: const Color(0xFFCE93D8),
        foregroundColor: kInk,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final c = cats[i];
          final now = active.contains(c.season);
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: c.color.withValues(alpha: now ? 0.75 : 0.4),
            leading: Text(c.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(c.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: kInk)),
            subtitle: Text(
              now
                  ? 'وقتها دلوقتي • ${c.stickers.length} ستيكر'
                  : '${c.stickers.length} ستيكر',
              style: const TextStyle(color: kInk),
            ),
            trailing: const Icon(Icons.chevron_left, color: kInk),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategoryScreen(
                title: c.title,
                color: c.color,
                stickers: c.stickers,
              ),
            )),
          );
        },
      ),
    );
  }
}
