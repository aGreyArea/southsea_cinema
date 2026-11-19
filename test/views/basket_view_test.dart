import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  final MovieRepository movieRepository = MovieRepository();
  final Movie repoMan = movieRepository.getMovieById('repo-man')!; // £9.50
  final Movie paranormalActivity =
      movieRepository.getMovieById('paranormal-activity')!; // £7.00
  final BasketRepository basket = BasketRepository.instance;

  Future<void> pumpBasket(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (context) => const BasketView(),
          '/home': (context) => const HomeView(),
        },
      ),
    );
  }

  setUp(() {
    basket.clear(); // the basket is shared, so start every test empty
  });

  group('BasketView', () {
    testWidgets('shows an empty message when the basket is empty',
        (WidgetTester tester) async {
      await pumpBasket(tester);

      expect(find.text('MY ORDER'), findsOneWidget);
      expect(find.text('Your basket is empty.'), findsOneWidget);
      expect(find.text('BUY TICKETS'), findsNothing);
    });

    testWidgets('lists each movie with its tickets, price and total',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      basket.addTickets(paranormalActivity, 3);
      await pumpBasket(tester);

      expect(find.text('Item'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('2 Tickets'), findsOneWidget);
      expect(find.text('3 Tickets'), findsOneWidget);
      expect(find.textContaining('REPO MAN'), findsOneWidget);
      expect(find.textContaining('PARANORMAL ACTIVITY'), findsOneWidget);
      expect(find.text('£19.00'), findsOneWidget);
      expect(find.text('£21.00'), findsOneWidget);
      expect(find.textContaining('Friday 27 Nov 2026  19:30'), findsOneWidget);
      expect(find.text('Service Charge'), findsOneWidget);
      expect(find.text('£4.00'), findsOneWidget); // 5 tickets x £0.80
      expect(find.text('Total Due'), findsOneWidget);
      expect(find.text('£44.00'), findsOneWidget);
      expect(find.text('UPDATE ORDER'), findsOneWidget);
      expect(find.text('BUY TICKETS'), findsOneWidget);
    });

    testWidgets('delete button removes that movie and updates the total',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      basket.addTickets(paranormalActivity, 3);
      await pumpBasket(tester);

      await tester.tap(find.byKey(const Key('delete-repo-man')));
      await tester.pump();

      expect(find.textContaining('REPO MAN'), findsNothing);
      expect(find.text('3 Tickets'), findsOneWidget);
      expect(find.text('£21.00'), findsOneWidget);
      expect(find.text('£2.40'), findsOneWidget); // 3 x £0.80
      expect(find.text('£23.40'), findsOneWidget);
      expect(basket.getItems().length, 1);
    });

    testWidgets('deleting the last movie shows the empty message',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 1);
      await pumpBasket(tester);

      await tester.tap(find.byKey(const Key('delete-repo-man')));
      await tester.pump();

      expect(find.text('Your basket is empty.'), findsOneWidget);
    });

    testWidgets('BUY TICKETS empties the basket and shows a confirmation',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      await pumpBasket(tester);

      await tester.tap(find.text('BUY TICKETS'));
      await tester.pump();

      expect(basket.isEmpty, isTrue);
      expect(find.text('Your basket is empty.'), findsOneWidget);
      expect(
        find.text(
            'Thank you! Your order for 2 tickets (£20.60) has been placed.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Add to order on a movie card puts tickets in the basket',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SouthseaCinemaApp());

    final Finder firstCard = find.byType(MovieCard).first;
    await tester.tap(find.descendant(
      of: firstCard,
      matching: find.byType(DropdownButtonFormField<int>),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: firstCard, matching: find.text('Add to order')));
    await tester.pump();

    expect(basket.getItems().length, 1);
    expect(basket.getItems()[0].movie.id, 'repo-man');
    expect(basket.getItems()[0].quantity, 2);
    expect(find.text('Added 2 tickets for Repo Man to your basket'),
        findsOneWidget);
  });
}
