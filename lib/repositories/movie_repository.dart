import 'package:southsea_cinema/models/model.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return const [
      Movie(
        id: 'repo-man',
        name: 'Repo Man',
        synopsis:
            "A down and out young punk gets a job working with a seasoned repo man, but what awaits him in his new career is a series of outlandish adventures revolving around aliens, the CIA, and a most wanted '64 Chevy.",
        ageRating: '15',
        imagePath: 'assets/images/repo_man.png',
        screeningTime: '19:30',
        price: '9.50',
      ),
      Movie(
        id: 'paranormal-activity',
        name: 'Paranormal Activity',
        synopsis:
            'After a young, middle-class couple moves into what seems like a typical suburban house, they become increasingly disturbed by a presence that may or may not be demonic, but is certainly the most active in the middle of the night.',
        ageRating: '15',
        imagePath: 'assets/images/paranormal_activity.png',
        screeningTime: '21:45',
        price: '7.00',
      ),
    ];
  }

  Movie? getMovieById(String id) {
    for (final movie in getMovies()) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }
}
