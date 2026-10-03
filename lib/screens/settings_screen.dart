import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/catalog.dart';
import '../services/favorites.dart';
import '../services/recents.dart';
import '../services/settings.dart';

const _githubUrl = 'https://github.com/oneshoot5010';
const _whatsappUrl = 'https://wa.me/201044947639';
const _appVersion = '0.3.0';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name =
      TextEditingController(text: AppSettings.instance.name);
  bool _updating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _open(String url) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && mounted) _snack('مقدرتش أفتح الرابط');
  }

  Future<void> _suggestSticker() => _open(
        '$_whatsappUrl?text=${Uri.encodeComponent('اقتراح ستيكر لتطبيق ستيكرات إيموجي:\n')}',
      );

  Future<void> _update() async {
    setState(() => _updating = true);
    final r = await Catalog.refreshOnline();
    if (!mounted) return;
    setState(() => _updating = false);
    if (r == null) {
      _snack('مقدرتش أوصل للنت أو للملف');
    } else if (!r.changed) {
      _snack('عندك آخر نسخة من الستيكرات');
    } else if (r.delta > 0) {
      _snack('اتضاف ${r.delta} ستيكر جديد');
    } else {
      _snack('اتحدّثت الستيكرات');
    }
  }

  Future<void> _confirm(String title, String body, Future<void> Function() go,
      String done) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
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
      await go();
      if (mounted) _snack(done);
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
          const SizedBox(height: 20),
          Text('حجم الخط', style: t.titleMedium),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (_, __) => SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.85, label: Text('صغير')),
                ButtonSegment(value: 1.0, label: Text('وسط')),
                ButtonSegment(value: 1.2, label: Text('كبير')),
              ],
              selected: {AppSettings.instance.fontScale},
              onSelectionChanged: (s) =>
                  AppSettings.instance.setFontScale(s.first),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الستيكرات الطويلة بتصغّر لوحدها عشان تناسب الشاشة.',
            style: t.bodySmall,
          ),
          const SizedBox(height: 20),
          Text('ستيكرات باسمك', style: t.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: 'اكتب اسمك',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) async {
              await AppSettings.instance.setName(v);
              Catalog.rebuild();
            },
          ),
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (_, __) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('اهتزاز خفيف عند النسخ'),
              value: AppSettings.instance.haptics,
              onChanged: AppSettings.instance.setHaptics,
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: _updating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update),
            title: const Text('تحديث الستيكرات من النت'),
            subtitle: const Text('بيجيب أي ستيكرات جديدة من غير ما تنزل نسخة جديدة'),
            onTap: _updating ? null : _update,
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: const Text('اقترح ستيكر'),
            subtitle: const Text('بيفتح واتساب برسالة جاهزة للمطوّر'),
            onTap: _suggestSticker,
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('مشاركة التطبيق'),
            onTap: () => Share.share(
              'جرّب تطبيق "ستيكرات إيموجي": ${Catalog.all.length} ستيكر بالإيموجي تنسخها وتبعتها في أي محادثة 😂',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('مسح "آخر ما استخدمته"'),
            onTap: () => _confirm(
              'مسح آخر ما استخدمته؟',
              'القايمة هتتفضى.',
              Recents.instance.clear,
              'اتمسحت القايمة',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('مسح المفضلة'),
            onTap: () => _confirm(
              'مسح المفضلة؟',
              'كل الستيكرات المحفوظة هتتشال.',
              Favorites.instance.clear,
              'اتمسحت المفضلة',
            ),
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
                  onTap: () => _open(_githubUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('WhatsApp'),
                  subtitle: const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('+20 104 494 7639'),
                    ),
                  ),
                  onTap: () => _open(_whatsappUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(child: Text('الإصدار $_appVersion', style: t.bodySmall)),
        ],
      ),
    );
  }
}
