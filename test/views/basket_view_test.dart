import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

import '../helpers/pump_with_films.dart';

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

    await pumpAndLoadFilms(tester, const SouthseaCinemaApp());

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

  testWidgets(
      'booking flow: add JSON films, remove one, checkout clears the basket',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The cards come from assets/data/movies.json, not the hard-coded list.
    await pumpAndLoadFilms(tester, const SouthseaCinemaApp());
    final List<Movie>? films =
        await tester.runAsync(() => MovieRepository().loadMoviesFromAsset());
    expect(find.byType(MovieCard), findsNWidgets(films!.length));
    final Movie firstFilm = films[0]; // Repo Man, £9.50
    final Movie secondFilm = films[1]; // Paranormal Activity, £7.00

    Future<void> addTickets(int cardIndex, int quantity) async {
      final Finder card = find.byType(MovieCard).at(cardIndex);
      await tester.tap(find.descendant(
        of: card,
        matching: find.byType(DropdownButtonFormField<int>),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$quantity').last);
      await tester.pumpAndSettle();
      await tester
          .tap(find.descendant(of: card, matching: find.text('Add to order')));
      await tester.pump();
    }

    // 1. Add tickets for both films loaded from the asset.
    await addTickets(0, 2);
    await addTickets(1, 3);
    expect(basket.getItems().map((item) => item.movie.id),
        [firstFilm.id, secondFilm.id]);
    expect(basket.totalQuantity, 5);

    // 2. Open the basket from the drawer.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Basket'));
    await tester.pumpAndSettle();
    expect(find.byType(BasketView), findsOneWidget);
    expect(find.text('2 Tickets'), findsOneWidget);
    expect(find.text('3 Tickets'), findsOneWidget);
    expect(find.text('£44.00'), findsOneWidget); // £19 + £21 + £4 service

    // 3. Remove the first film.
    await tester.tap(find.byKey(Key('delete-${firstFilm.id}')));
    await tester.pump();
    expect(basket.getItems().length, 1);
    expect(basket.getItems()[0].movie.id, secondFilm.id);
    expect(find.text('£23.40'), findsOneWidget); // £21 + 3 x £0.80

    // 4. Temporary checkout: clears the in-memory basket only.
    await tester.tap(find.text('BUY TICKETS'));
    await tester.pump();
    expect(basket.isEmpty, isTrue);
    expect(basket.totalDue, 0);
    expect(find.text('Your basket is empty.'), findsOneWidget);
    expect(
      find.text(
          'Thank you! Your order for 3 tickets (£23.40) has been placed.'),
      findsOneWidget,
    );

    // Nothing is kept after checkout (saved bookings arrive in Worksheet 7):
    // the next order starts from an empty basket.
    basket.addTickets(firstFilm, 1);
    expect(basket.totalQuantity, 1);
    expect(basket.getItems().length, 1);
  });
}
