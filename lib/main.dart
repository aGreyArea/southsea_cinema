import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/repositories/theme_repository.dart';
import 'package:southsea_cinema/theme.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

Future<void> main() async {
  // needed before using plugins such as shared_preferences in main
  WidgetsFlutterBinding.ensureInitialized();
  // load the saved light/dark choice before the first frame
  await ThemeRepository.instance.load();
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatelessWidget {
  const SouthseaCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // rebuilds MaterialApp whenever the theme setting changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeRepository.instance.themeMode,
      builder: (BuildContext context, ThemeMode themeMode, Widget? child) {
        return MaterialApp(
          title: appTitle,
          debugShowCheckedModeBanner: false,
          theme: cinemaLightTheme,
          darkTheme: cinemaDarkTheme,
          themeMode: themeMode,
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) {
              return const HomeView();
            },
            '/basket': (BuildContext context) {
              return const BasketView();
            },
            '/settings': (BuildContext context) {
              return const SettingsView();
            },
          },
        );
      },
    );
  }
}
