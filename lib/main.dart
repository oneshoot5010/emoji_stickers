import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/catalog.dart';
import 'screens/home_screen.dart';
import 'services/favorites.dart';
import 'services/recents.dart';
import 'services/settings.dart';
import 'services/updater.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // الإعدادات الأول، عشان اسمك يتحط في الستيكرات وقت التحميل
  await AppSettings.instance.load();
  await Catalog.load();
  await Favorites.instance.load();
  await Recents.instance.load();
  runApp(const EmojiApp());
  _checkForNewStickers();
}

/// تحديث الستيكرات من النت في الخلفية. لو مفيش نت، مفيش حاجة بتحصل.
Future<void> _checkForNewStickers() async {
  final r = await Catalog.refreshOnline();
  if (r == null || !r.changed) return;
  appMessenger.currentState?.showSnackBar(SnackBar(
    content: Text(
      r.delta > 0 ? 'اتضاف ${r.delta} ستيكر جديد' : 'اتحدّثت الستيكرات',
    ),
  ));
}

class EmojiApp extends StatelessWidget {
  const EmojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: appMessenger,
        title: 'ستيكرات إيموجي',
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: AppSettings.instance.mode,
        home: const HomeScreen(),
      ),
    );
  }
}
