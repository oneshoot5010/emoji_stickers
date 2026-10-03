import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../services/favorites.dart';
import '../services/recents.dart';
import '../services/seasons.dart';
import '../services/settings.dart';
import '../theme.dart';
import '../widgets/sticker_sheet.dart';
import 'category_screen.dart';
import 'make_screen.dart';
import 'search_screen.dart';
import 'seasons_screen.dart';
import 'settings_screen.dart';
import 'stories_screen.dart';

class _Tile {
  final String title;
  final String emoji;
  final Color color;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile({
    required this.title,
    required this.emoji,
    required this.color,
    required this.subtitle,
    required this.onTap,
  });
}

class _Suggest {
  final StickerCategory category;
  final String label;
  const _Suggest(this.category, this.label);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  /// اقتراحات حسب اليوم والوقت والمواسم
  List<_Suggest> _suggestions() {
    final now = DateTime.now();
    final out = <_Suggest>[];
    if (Seasons.isFriday(now)) {
      final c = Catalog.bySlot('friday');
      if (c != null) out.add(_Suggest(c, 'النهاردة جمعة'));
    }
    final slot = Catalog.bySlot(Seasons.slot(now));
    if (slot != null) out.add(_Suggest(slot, 'مناسب للوقت ده'));
    final active = Seasons.active(now);
    for (final c in Catalog.seasonal) {
      if (active.contains(c.season)) out.add(_Suggest(c, 'مناسبة الأيام دي'));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Catalog.changed,
      builder: (context, _, __) => _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final tiles = <_Tile>[];

    for (final c in Catalog.regular) {
      tiles.add(_Tile(
        title: c.title,
        emoji: c.emoji,
        color: c.color,
        subtitle: '${c.stickers.length} ستيكر',
        onTap: () => _push(
          context,
          CategoryScreen(title: c.title, color: c.color, stickers: c.stickers),
        ),
      ));
    }

    final storyCount = [
      for (final c in Catalog.stories) ...c.stickers,
    ].length;
    tiles.add(_Tile(
      title: 'قصص',
      emoji: '📖',
      color: const Color(0xFFFFE082),
      subtitle: '$storyCount ستيكر',
      onTap: () => _push(context, const StoriesScreen()),
    ));

    final seasonal = Catalog.seasonal;
    if (seasonal.isNotEmpty) {
      final n = [for (final c in seasonal) ...c.stickers].length;
      tiles.add(_Tile(
        title: 'مواسم ومناسبات',
        emoji: '📅',
        color: const Color(0xFFCE93D8),
        subtitle: '$n ستيكر',
        onTap: () => _push(context, const SeasonsScreen()),
      ));
    }

    final nameCat = Catalog.nameCategory;
    final noName = AppSettings.instance.name.trim().isEmpty;
    if (nameCat != null) {
      tiles.add(_Tile(
        title: 'ستيكرات باسمك',
        emoji: '🏷️',
        color: const Color(0xFFA5D6A7),
        subtitle: noName
            ? 'اكتب اسمك الأول'
            : '${nameCat.stickers.length} ستيكر',
        onTap: () {
          if (noName) {
            _push(context, const SettingsScreen());
          } else {
            _push(
              context,
              CategoryScreen(
                title: 'ستيكرات باسمك',
                color: const Color(0xFFA5D6A7),
                stickers: nameCat.stickers,
              ),
            );
          }
        },
      ));
    }

    final suggestions = _suggestions();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSurprise(context),
        icon: const Icon(Icons.casino),
        label: const Text('فاجئني'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              onSearch: () => _push(context, const SearchScreen()),
              onSettings: () => _push(context, const SettingsScreen()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final s in suggestions) ...[
                    _SuggestTile(
                      suggest: s,
                      onTap: () => _push(
                        context,
                        CategoryScreen(
                          title: s.category.title,
                          color: s.category.color,
                          stickers: s.category.stickers,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _SimpleTile(
                    icon: Icons.brush,
                    iconColor: kBlueBottom,
                    title: 'اعمل ستيكرك',
                    subtitle: 'اختار الوش واللي في إيده واكتب جملة',
                    onTap: () => _push(context, const MakeScreen()),
                  ),
                  const SizedBox(height: 8),
                  const _FavoritesTile(),
                  const _RecentsTile(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: tiles.length,
              itemBuilder: (_, i) => _CategoryCard(tile: tiles[i]),
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
  final _Tile tile;
  const _CategoryCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: tile.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tile.color,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tile.emoji, style: const TextStyle(fontSize: 34)),
            const Spacer(),
            Text(
              tile.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tile.subtitle,
              style: t.bodySmall?.copyWith(color: kInk),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SimpleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}

class _SuggestTile extends StatelessWidget {
  final _Suggest suggest;
  final VoidCallback onTap;
  const _SuggestTile({required this.suggest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = suggest.category;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: c.color.withValues(alpha: 0.6),
      leading: Text(c.emoji, style: const TextStyle(fontSize: 28)),
      title: Text(
        c.title,
        style: const TextStyle(fontWeight: FontWeight.w700, color: kInk),
      ),
      subtitle: Text(
        '${suggest.label} • ${c.stickers.length} ستيكر',
        style: const TextStyle(color: kInk),
      ),
      trailing: const Icon(Icons.chevron_left, color: kInk),
      onTap: onTap,
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
        return ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        );
      },
    );
  }
}

class _RecentsTile extends StatelessWidget {
  const _RecentsTile();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Recents.instance,
      builder: (context, _) {
        final byId = {for (final s in Catalog.all) s.id: s};
        final recent = <Sticker>[
          for (final id in Recents.instance.ids)
            if (byId[id] != null) byId[id]!,
        ];
        if (recent.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            leading: const Icon(Icons.history, color: kBlueBottom),
            title: const Text('آخر ما استخدمته'),
            subtitle: Text('${recent.length} ستيكر'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CategoryScreen(
                title: 'آخر ما استخدمته',
                color: const Color(0xFF81D4FA),
                stickers: recent,
              ),
            )),
          ),
        );
      },
    );
  }
}
