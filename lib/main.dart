import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/catalog.dart';
import 'screens/home_screen.dart';
import 'services/favorites.dart';
import 'services/settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Catalog.load();
  await Favorites.instance.load();
  await AppSettings.instance.load();
  runApp(const EmojiApp());
}

class EmojiApp extends StatelessWidget {
  const EmojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
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
