import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovieRepository unit tests', () {
    test('getMovies returns two movies', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      expect(movies.length, 2);
    });

    test('getMovies contains valid Repo Man and Paranormal Activity', () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      final Movie repoMan = movies[0];
      expect(repoMan.id, 'repo-man');
      expect(repoMan.name, 'Repo Man');
      expect(repoMan.price, 9.50);
      expect(repoMan.imagePath, isNotEmpty);

      final Movie paranormalActivity = movies[1];
      expect(paranormalActivity.id, 'paranormal-activity');
      expect(paranormalActivity.name, 'Paranormal Activity');
      expect(paranormalActivity.price, 7.00);
      expect(paranormalActivity.imagePath, isNotEmpty);
    });

    test('getMovieById returns matching movie when id exists', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('repo-man');

      expect(movie, isNotNull);
      expect(movie?.name, 'Repo Man');
      expect(movie?.price, 9.50);
    });

    test('getMovieById returns null when id does not exist', () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById('non-existent');

      expect(movie, isNull);
    });

    test('loadMoviesFromAsset reads every film from movies.json', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = await repository.loadMoviesFromAsset();

      expect(movies.length, 2);

      final Movie repoMan = movies[0];
      expect(repoMan.id, 'repo-man');
      expect(repoMan.name, 'Repo Man');
      expect(repoMan.synopsis, startsWith('A down and out young punk'));
      expect(repoMan.ageRating, '15');
      expect(repoMan.imagePath, 'assets/images/repo_man.png');
      expect(repoMan.screeningDate, 'Friday 27 Nov 2026');
      expect(repoMan.screeningTime, '19:30');
      expect(repoMan.price, 9.50);

      final Movie paranormalActivity = movies[1];
      expect(paranormalActivity.id, 'paranormal-activity');
      expect(paranormalActivity.name, 'Paranormal Activity');
      expect(paranormalActivity.synopsis,
          startsWith('After a young, middle-class couple'));
      expect(paranormalActivity.ageRating, '15');
      expect(paranormalActivity.imagePath,
          'assets/images/paranormal_activity.png');
      expect(paranormalActivity.screeningDate, 'Saturday 28 Nov 2026');
      expect(paranormalActivity.screeningTime, '21:45');
      expect(paranormalActivity.price, 7.00);
    });

    test('loadMoviesFromAsset matches the in-code getMovies list', () async {
      final MovieRepository repository = MovieRepository();
      final List<Movie> fromAsset = await repository.loadMoviesFromAsset();
      final List<Movie> fromCode = repository.getMovies();

      expect(fromAsset.map((m) => m.toJson()).toList(),
          fromCode.map((m) => m.toJson()).toList());
    });
  });
}
