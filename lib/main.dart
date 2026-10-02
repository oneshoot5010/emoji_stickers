import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/catalog.dart';
import 'screens/home_screen.dart';
import 'services/favorites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Catalog.load();
  await Favorites.instance.load();
  runApp(const EmojiApp());
}

class EmojiApp extends StatelessWidget {
  const EmojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFC93C),
      surface: const Color(0xFFF7F5FF),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ستيكرات إيموجي',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
