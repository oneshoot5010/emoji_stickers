import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../services/favorites.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ستيكرات إيموجي', style: t.headlineMedium),
                    const SizedBox(height: 4),
                    Text('اختار مزاجك وابعتهولهم', style: t.bodyLarge),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _FavoritesTile()),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: categories.length,
                itemBuilder: (_, i) => _CategoryCard(category: categories[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final StickerCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CategoryScreen(
          title: category.title,
          color: category.color,
          stickers: category.stickers,
        ),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 44)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.title, style: t.titleLarge),
                Text('${category.stickers.length} ستيكر', style: t.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTile extends StatelessWidget {
  const _FavoritesTile();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Favorites.instance,
      builder: (context, _) {
        final favs = allStickers
            .where((s) => Favorites.instance.has(s.id))
            .toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            leading: const Icon(Icons.favorite),
            title: const Text('المفضلة'),
            subtitle: Text('${favs.length} ستيكر'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategoryScreen(
                title: 'المفضلة',
                color: const Color(0xFFFFC2D6),
                stickers: favs,
                emptyText: 'دوس على القلب جوه أي ستيكر عشان يتضاف هنا',
              ),
            )),
          ),
        );
      },
    );
  }
}
