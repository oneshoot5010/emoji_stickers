import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/sticker.dart';
import '../widgets/sticker_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final List<Sticker> results = _q.isEmpty
        ? <Sticker>[]
        : Catalog.all
            .where((s) => s.frames.any((f) => f.contains(_q)))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث بكلمة، مثلاً: قهوة أو نوم',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _q = v.trim()),
        ),
      ),
      body: _q.isEmpty
          ? const Center(child: Text('اكتب كلمة تدور بيها'))
          : results.isEmpty
              ? const Center(child: Text('مفيش نتيجة'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      StickerCard(sticker: results[i], color: color),
                ),
    );
  }
}
