import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/pump_with_films.dart';

void main() {
  final MovieRepository movieRepository = MovieRepository();
  final Movie repoMan = movieRepository.getMovieById('repo-man')!; // £9.50
  final Movie paranormalActivity =
      movieRepository.getMovieById('paranormal-activity')!; // £7.00
  final BasketRepository basket = BasketRepository.instance;

  // sqflite_common_ffi runs SQLite on this computer instead of Android.
  sqfliteFfiInit();

  // Database work happens in real time, but widget tests run on a fake clock,
  // so let it finish inside runAsync and then rebuild the page.
  Future<void> waitForDatabase(WidgetTester tester) async {
    for (int i = 0; i < 5; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
  }

  Booking buildBooking(int bookingNumber, String summary, double total) {
    return Booking(
      bookingNumber: bookingNumber,
      summary: summary,
      total: total,
      date: '01/01/2026 10:00',
    );
  }

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
    await waitForDatabase(tester); // past bookings load in initState
  }

  setUp(() async {
    basket.clear(); // the basket is shared, so start every test empty

    // A fresh in-memory database with an empty bookings table for each test.
    final Database db =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await CinemaDatabase.instance.createTables(db, 1);
    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
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

    testWidgets('BUY TICKETS saves a numbered booking, then empties the basket',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      basket.addTickets(paranormalActivity, 1);
      await pumpBasket(tester);

      await tester.tap(find.text('BUY TICKETS'));
      await waitForDatabase(tester);

      expect(basket.isEmpty, isTrue);
      expect(find.text('Your basket is empty.'), findsOneWidget);
      expect(find.text('Booking 1001 saved'), findsOneWidget);

      final List<Booking>? saved =
          await tester.runAsync(() => CinemaDatabase.instance.getAllBookings());
      expect(saved!.length, 1);
      expect(saved[0].id, greaterThan(0));
      expect(saved[0].bookingNumber, 1001);
      expect(saved[0].summary, '2 x Repo Man, 1 x Paranormal Activity');
      expect(saved[0].total, closeTo(28.40, 0.001)); // £26 + 3 x £0.80
      expect(saved[0].date, matches(r'^\d{2}/\d{2}/\d{4} \d{2}:\d{2}$'));
    });

    testWidgets('booking numbers continue from the highest saved booking',
        (WidgetTester tester) async {
      await tester.runAsync(() => CinemaDatabase.instance
          .insertBooking(buildBooking(1005, '1 x Repo Man', 10.30)));
      basket.addTickets(repoMan, 1);
      await pumpBasket(tester);

      await tester.tap(find.text('BUY TICKETS'));
      await waitForDatabase(tester);

      expect(find.text('Booking 1006 saved'), findsOneWidget);
    });

    testWidgets('keeps the basket and shows an error if saving fails',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      await pumpBasket(tester);

      // a closed connection makes the database calls throw
      await tester.runAsync(() async {
        final Database db = await CinemaDatabase.instance.database;
        await db.close();
      });
      await tester.tap(find.text('BUY TICKETS'));
      await waitForDatabase(tester);

      expect(basket.totalQuantity, 2);
      expect(find.text('2 Tickets'), findsOneWidget);
      expect(
          find.textContaining('Could not save your booking'), findsOneWidget);
      CinemaDatabase.instance.setDatabase(null); // already closed
    });

    testWidgets('shows a message when there are no past bookings',
        (WidgetTester tester) async {
      await pumpBasket(tester);

      expect(find.text('PAST BOOKINGS'), findsOneWidget);
      expect(find.text('You have no past bookings.'), findsOneWidget);
    });

    testWidgets('lists past bookings below the basket, highest number first',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await CinemaDatabase.instance
            .insertBooking(buildBooking(1001, '1 x Repo Man', 10.30));
        await CinemaDatabase.instance.insertBooking(
            buildBooking(1002, '2 x Paranormal Activity', 15.60));
      });
      basket.addTickets(repoMan, 1);
      await pumpBasket(tester);

      expect(find.text('You have no past bookings.'), findsNothing);
      expect(find.text('Booking 1001'), findsOneWidget);
      expect(find.text('Booking 1002'), findsOneWidget);
      expect(find.text('2 x Paranormal Activity'), findsOneWidget);
      expect(find.text('£15.60'), findsOneWidget);
      expect(find.text('01/01/2026 10:00'), findsNWidgets(2));

      // highest booking number appears higher up the page
      expect(tester.getTopLeft(find.text('Booking 1002')).dy,
          lessThan(tester.getTopLeft(find.text('Booking 1001')).dy));
      // and the list sits below the basket's buttons
      expect(tester.getTopLeft(find.text('PAST BOOKINGS')).dy,
          greaterThan(tester.getTopLeft(find.text('BUY TICKETS')).dy));
    });

    testWidgets('a new booking appears in the past bookings list',
        (WidgetTester tester) async {
      basket.addTickets(repoMan, 2);
      await pumpBasket(tester);
      expect(find.text('You have no past bookings.'), findsOneWidget);

      await tester.tap(find.text('BUY TICKETS'));
      await waitForDatabase(tester);

      expect(find.text('You have no past bookings.'), findsNothing);
      expect(find.text('Booking 1001'), findsOneWidget);
      expect(find.text('2 x Repo Man'), findsOneWidget);
      expect(find.text('£20.60'), findsOneWidget);
    });
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
    await tester.pump();
    await waitForDatabase(tester); // past bookings load in initState
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

    // 4. Checkout saves a numbered booking, then clears the basket.
    await tester.tap(find.text('BUY TICKETS'));
    await waitForDatabase(tester);
    expect(basket.isEmpty, isTrue);
    expect(basket.totalDue, 0);
    expect(find.text('Your basket is empty.'), findsOneWidget);
    expect(find.text('Booking 1001 saved'), findsOneWidget);
    expect(find.text('Booking 1001'), findsOneWidget);
    expect(find.text('3 x ${secondFilm.name}'), findsOneWidget);

    // The next order starts from an empty basket.
    basket.addTickets(firstFilm, 1);
    expect(basket.totalQuantity, 1);
    expect(basket.getItems().length, 1);
  });
}
