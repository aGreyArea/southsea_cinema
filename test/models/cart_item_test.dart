import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/models/model.dart';

void main() {
  const Movie repoMan = Movie(
    id: 'repo-man',
    name: 'Repo Man',
    synopsis: 'A young punk gets a job working with a seasoned repo man.',
    ageRating: '15',
    imagePath: 'assets/images/repo_man.png',
    screeningDate: 'Friday 27 Nov 2026',
    screeningTime: '19:30',
    price: 9.50,
  );

  group('CartItem', () {
    test('constructor assigns movie and quantity', () {
      const CartItem item = CartItem(movie: repoMan, quantity: 2);

      expect(item.movie, repoMan);
      expect(item.quantity, 2);
    });

    test('lineTotal multiplies price by quantity', () {
      const CartItem item = CartItem(movie: repoMan, quantity: 3);

      expect(item.lineTotal, 28.50);
    });
  });
}
