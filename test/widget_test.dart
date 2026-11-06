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

    testWidgets('Displays movie cards with names, prices and booking buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.byType(MovieCard), findsNWidgets(2));
      expect(find.text('Repo Man (15)'), findsOneWidget);
      expect(find.text('£9.50'), findsOneWidget);
      expect(find.text('Paranormal Activity (15)'), findsOneWidget);
      expect(find.text('£7.00'), findsOneWidget);
      expect(find.text('BOOK'), findsNWidgets(2));
    });
  });
}
