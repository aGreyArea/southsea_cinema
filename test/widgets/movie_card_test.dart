import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

import '../helpers/pump_with_films.dart';

void main() {
  final BasketRepository basket = BasketRepository.instance;

  setUp(() {
    basket.clear(); // the basket is shared, so start every test empty
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
}
