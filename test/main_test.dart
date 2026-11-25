import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/theme_repository.dart';
import 'package:southsea_cinema/theme.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

import 'helpers/pump_with_films.dart';

void main() {
  final ThemeRepository themeRepository = ThemeRepository.instance;

  setUp(() {
    themeRepository.themeMode.value = ThemeMode.dark;
  });

  testWidgets('Basic app loading test', (WidgetTester tester) async {
    await pumpAndLoadFilms(tester, const SouthseaCinemaApp());
    expect(find.text(appTitle), findsOneWidget);
  });

  group('App smoke tests', () {
    testWidgets('App displays HomeView as home', (WidgetTester tester) async {
      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text(appTitle), findsOneWidget);
    });

    testWidgets('Displays movie cards with names, prices and ticket dropdowns',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());
      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('REPO MAN (15)'), findsOneWidget);
      expect(find.text('Tickets (£9.50 each)'), findsOneWidget);
      expect(find.text('PARANORMAL ACTIVITY (15)'), findsOneWidget);
      expect(find.text('Tickets (£7.00 each)'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2));
      expect(find.text('Add to order'), findsNWidgets(2));
      expect(find.text('Details'), findsNWidgets(2));
    });

    testWidgets('Details button opens only that movie',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());
      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();

      expect(find.byType(MovieListing), findsOneWidget);
      expect(find.byType(MovieCard), findsNothing);
      expect(find.text('REPO MAN (15)'), findsOneWidget);
      expect(find.text('PARANORMAL ACTIVITY (15)'), findsNothing);
    });
  });

  group('Light and dark mode', () {
    testWidgets('MaterialApp has both themes and uses the saved ThemeMode',
        (WidgetTester tester) async {
      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());

      final MaterialApp app =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, cinemaLightTheme);
      expect(app.darkTheme, cinemaDarkTheme);
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('the app is dark by default', (WidgetTester tester) async {
      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());

      final BuildContext context = tester.element(find.byType(HomeView));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(Theme.of(context).scaffoldBackgroundColor, cinemaBackground);
    });

    testWidgets('changing the setting re-themes the running app',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpAndLoadFilms(tester, const SouthseaCinemaApp());

      themeRepository.themeMode.value = ThemeMode.light;
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomeView));
      expect(Theme.of(context).brightness, Brightness.light);
      expect(Theme.of(context).scaffoldBackgroundColor, cinemaLightBackground);
      // film titles switch to dark text so they show on the white cards
      final Text title = tester.widget<Text>(find.text('REPO MAN (15)'));
      expect(title.style!.color, cinemaFontDark);
      final Card card = tester.widget<Card>(find.byType(Card).first);
      expect(card.color, cinemaLightSurface);
    });
  });
}
