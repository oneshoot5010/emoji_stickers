import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/favorites.dart';
import '../services/settings.dart';

const _githubUrl = 'https://github.com/oneshoot5010';
const _whatsappUrl = 'https://wa.me/201044947639';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مقدرتش أفتح الرابط')),
      );
    }
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('مسح المفضلة؟'),
        content: const Text('كل الستيكرات المحفوظة هتتشال.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('امسح'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Favorites.instance.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اتمسحت المفضلة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('المظهر', style: t.titleMedium),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (_, __) => SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('تلقائي')),
                ButtonSegment(value: ThemeMode.light, label: Text('فاتح')),
                ButtonSegment(value: ThemeMode.dark, label: Text('داكن')),
              ],
              selected: {AppSettings.instance.mode},
              onSelectionChanged: (s) => AppSettings.instance.setMode(s.first),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('مشاركة التطبيق'),
            onTap: () => Share.share(
              'جرّب تطبيق "ستيكرات إيموجي": 300 ستيكر بالإيموجي تنسخها وتبعتها في أي محادثة 😂',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('مسح المفضلة'),
            onTap: () => _clearFavorites(context),
          ),
          const Divider(height: 32),
          Text('عن المطور', style: t.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Mohamed Hassan'),
                  subtitle: Text('مطوّر التطبيق'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('oneshoot5010'),
                  onTap: () => _open(context, _githubUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('WhatsApp'),
                  subtitle: Directionality(
                    textDirection: TextDirection.ltr,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Text('+20 104 494 7639'),
                    ),
                  ),
                  onTap: () => _open(context, _whatsappUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('الإصدار 0.2.0', style: t.bodySmall)),
        ],
      ),
    );
  }
}
