import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

// HomeView reads its films from assets/data/movies.json in initState.
// Widget tests run on a fake clock, where real file reads never finish,
// so pump inside runAsync (real time), give the read a moment to complete,
// then pumpAndSettle so HomeView rebuilds with the loaded films.
//
// rootBundle caches each asset read. If an earlier test started a read on
// the fake clock, that read never finishes and stays cached, so evict it
// first to make this test start a fresh one.
Future<void> pumpAndLoadFilms(WidgetTester tester, Widget widget,
    {void Function()? whileLoading}) async {
  rootBundle.evict(MovieRepository.moviesAssetPath);
  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
    whileLoading?.call(); // lets a test check the loading spinner
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pumpAndSettle();
}
