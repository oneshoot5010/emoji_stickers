import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../theme.dart';
import 'category_screen.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = Catalog.stories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('قصص'),
        backgroundColor: const Color(0xFFFFE082),
        foregroundColor: kInk,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final c = cats[i];
          final title = Catalog.shortTitle(c);
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: c.color.withValues(alpha: 0.45),
            leading: Text(c.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: kInk)),
            subtitle: Text('${c.stickers.length} ستيكر',
                style: const TextStyle(color: kInk)),
            trailing: const Icon(Icons.chevron_left, color: kInk),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategoryScreen(
                title: title,
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
