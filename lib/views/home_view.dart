import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/model.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class HomeView extends StatefulWidget {
  // Optional so tests can pass in a repository that fails to load.
  // The app itself uses const HomeView() and gets the real repository.
  final MovieRepository? movieRepository;

  const HomeView({super.key, this.movieRepository});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final MovieRepository _movieRepository =
      widget.movieRepository ?? MovieRepository();

  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // initState cannot be async, so start the load here and let it
    // call setState when the films arrive.
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final List<Movie> movies = await _movieRepository.loadMoviesFromAsset();
      if (!mounted) return; // the screen may have closed while loading
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Sorry, we couldn\'t load the films. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: cinemaBrand),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: cinemaFontWhite, fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: _movies[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: _buildBody(),
    );
  }
}
