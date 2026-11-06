import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/model.dart';

void main() {
  group('Movie', () {
    test('constructor assigns all properties', () {
      const Movie movie = Movie(
        id: 'repo-man',
        name: 'Repo Man',
        synopsis: 'A young punk gets a job working with a seasoned repo man.',
        ageRating: '15',
        imagePath: 'assets/images/repo_man.png',
        screeningTime: '19:30',
        price: '9.50',
      );

      expect(movie.id, 'repo-man');
      expect(movie.name, 'Repo Man');
      expect(movie.synopsis,
          'A young punk gets a job working with a seasoned repo man.');
      expect(movie.ageRating, '15');
      expect(movie.imagePath, 'assets/images/repo_man.png');
      expect(movie.screeningTime, '19:30');
      expect(movie.price, '9.50');
    });

    test('formattedPrice shows a whole-pound price with two decimal places',
        () {
      const Movie movie = Movie(
        id: 'paranormal-activity',
        name: 'Paranormal Activity',
        synopsis: 'A couple are disturbed by a presence in their house.',
        ageRating: '15',
        imagePath: 'assets/images/paranormal_activity.png',
        screeningTime: '21:45',
        price: '7.00',
      );

      expect(movie.formattedPrice, '£7.00');
    });

    test('formattedPrice shows a price with pence with two decimal places', () {
      const Movie movie = Movie(
        id: 'repo-man',
        name: 'Repo Man',
        synopsis: 'A young punk gets a job working with a seasoned repo man.',
        ageRating: '15',
        imagePath: 'assets/images/repo_man.png',
        screeningTime: '19:30',
        price: '9.50',
      );

      expect(movie.formattedPrice, '£9.50');
    });
  });
}
