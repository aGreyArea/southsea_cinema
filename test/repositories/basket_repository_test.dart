import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  final MovieRepository movieRepository = MovieRepository();
  final Movie repoMan = movieRepository.getMovieById('repo-man')!; // £9.50
  final Movie paranormalActivity =
      movieRepository.getMovieById('paranormal-activity')!; // £7.00

  group('BasketRepository unit tests', () {
    test('basket starts empty', () {
      final BasketRepository basket = BasketRepository();
      expect(basket.getItems(), isEmpty);
      expect(basket.isEmpty, isTrue);
      expect(basket.total, 0);
      expect(basket.totalQuantity, 0);
      expect(basket.serviceCharge, 0);
      expect(basket.totalDue, 0);
    });

    test('addTickets adds a movie to the basket', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 2);

      expect(basket.getItems().length, 1);
      expect(basket.getItems()[0].movie.id, 'repo-man');
      expect(basket.getItems()[0].quantity, 2);
    });

    test('addTickets for the same movie increases its quantity', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 2);
      basket.addTickets(repoMan, 1);

      expect(basket.getItems().length, 1);
      expect(basket.getItems()[0].quantity, 3);
    });

    test('addTickets ignores zero or negative quantities', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 0);
      basket.addTickets(repoMan, -1);

      expect(basket.getItems(), isEmpty);
    });

    test('total and totalQuantity cover every movie in the basket', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 2); // 19.00
      basket.addTickets(paranormalActivity, 3); // 21.00

      expect(basket.getItems().length, 2);
      expect(basket.totalQuantity, 5);
      expect(basket.total, 40.00);
      expect(basket.serviceCharge, closeTo(4.00, 0.001)); // 5 x £0.80
      expect(basket.totalDue, closeTo(44.00, 0.001));
    });

    test('removeTickets removes only that movie', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 2);
      basket.addTickets(paranormalActivity, 1);
      basket.removeTickets(repoMan);

      expect(basket.getItems().length, 1);
      expect(basket.getItems()[0].movie.id, 'paranormal-activity');
      expect(basket.total, 7.00);
    });

    test('clear empties the basket', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 2);
      basket.addTickets(paranormalActivity, 1);
      basket.clear();

      expect(basket.getItems(), isEmpty);
      expect(basket.total, 0);
    });

    test('items cannot be changed from outside the repository', () {
      final BasketRepository basket = BasketRepository();
      basket.addTickets(repoMan, 1);

      expect(() => basket.getItems().clear(), throwsUnsupportedError);
    });
  });
}
