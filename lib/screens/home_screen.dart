import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../services/favorites.dart';
import '../theme.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final regular = Catalog.regular;
    final storyStickers = <Sticker>[
      for (final c in Catalog.stories) ...c.stickers,
    ];
    final storiesCard = StickerCategory(
      title: 'قصص',
      emoji: '📖',
      color: const Color(0xFFFFE082),
      stickers: storyStickers,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(
            onSearch: () => _push(context, const SearchScreen()),
            onSettings: () => _push(context, const SettingsScreen()),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: _FavoritesTile()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: regular.length + 1,
              itemBuilder: (_, i) {
                if (i < regular.length) {
                  final c = regular[i];
                  return _CategoryCard(
                    category: c,
                    onTap: () => _push(
                      context,
                      CategoryScreen(
                        title: c.title,
                        color: c.color,
                        stickers: c.stickers,
                      ),
                    ),
                  );
                }
                return _CategoryCard(
                  category: storiesCard,
                  onTap: () => _push(context, const StoriesScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onSettings;
  const _Header({required this.onSearch, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBlueTop, kBlueBottom],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ستيكرات إيموجي',
                    style: t.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'بحث',
                  onPressed: onSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'الإعدادات',
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${Catalog.all.length} ستيكر. انسخ وابعت في أي محادثة',
                    style: t.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ),
                const Text('😂😍', style: TextStyle(fontSize: 34)),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final StickerCategory category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 34)),
            const Spacer(),
            Text(
              category.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${category.stickers.length} ستيكر',
              style: t.bodySmall?.copyWith(color: kInk),
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
        final favs =
            Catalog.all.where((s) => Favorites.instance.has(s.id)).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            leading: const Icon(Icons.favorite, color: Color(0xFFE53935)),
            title: const Text('المفضلة'),
            subtitle: Text('${favs.length} ستيكر'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategoryScreen(
                title: 'المفضلة',
                color: const Color(0xFFFFAB91),
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
