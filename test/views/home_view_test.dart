import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

import '../helpers/pump_with_films.dart';

// A repository whose asset load always fails, for the error-message test.
class FailingMovieRepository extends MovieRepository {
  @override
  Future<List<Movie>> loadMoviesFromAsset() async {
    throw Exception('asset missing');
  }
}

void main() {
  testWidgets('HomeView shows a spinner, then cards loaded from the asset',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpAndLoadFilms(
      tester,
      const MaterialApp(home: HomeView()),
      whileLoading: () {
        // First frame: the asset is still being read.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(MovieCard), findsNothing);
      },
    );

    final List<Movie>? fromAsset =
        await tester.runAsync(() => MovieRepository().loadMoviesFromAsset());
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(MovieCard), findsNWidgets(fromAsset!.length));
    for (final Movie movie in fromAsset) {
      expect(find.text('${movie.name.toUpperCase()} (${movie.ageRating})'),
          findsOneWidget);
    }
  });

  testWidgets('HomeView shows an error message if the films fail to load',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeView(movieRepository: FailingMovieRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(MovieCard), findsNothing);
    expect(
      find.text("Sorry, we couldn't load the films. Please try again later."),
      findsOneWidget,
    );
  });
}
