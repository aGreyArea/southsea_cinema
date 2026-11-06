import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  testWidgets('Basic app loading test', (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    expect(find.text(appTitle), findsOneWidget);
  });

  group('App smoke tests', () {
    testWidgets('App displays HomeView as home', (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text(appTitle), findsOneWidget);
    });

    testWidgets('Displays movie cards with names, prices and ticket dropdowns',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('REPO MAN (15)'), findsOneWidget);
      expect(find.text('Tickets (£9.50 each)'), findsOneWidget);
      expect(find.text('PARANORMAL ACTIVITY (15)'), findsOneWidget);
      expect(find.text('Tickets (£7.00 each)'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2));
      expect(find.text('Add to order'), findsNWidgets(2));
    });
  });
}
