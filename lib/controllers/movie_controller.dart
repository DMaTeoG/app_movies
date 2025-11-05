import 'package:flutter/material.dart';

import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../services/movie_service.dart';

class MovieController extends ChangeNotifier {
  MovieController({this.service, String? initialError})
    : errorMessage = initialError;

  final MovieService? service;

  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;

  List<MovieSummary> nowPlaying = <MovieSummary>[];
  List<MovieSummary> trending = <MovieSummary>[];
  List<MovieSummary> searchResults = <MovieSummary>[];

  DateTime selectedDate = DateTime.now();
  MovieDetail? selectedDetail;

  List<DateTime> get calendarDays => List<DateTime>.generate(
    7,
    (int index) => DateTime.now().add(Duration(days: index)),
  );

  List<MovieSummary> get moviesForSelectedDate {
    final filtered = nowPlaying
        .where(
          (MovieSummary movie) =>
              movie.releaseDate != null &&
              _isSameDay(movie.releaseDate!, selectedDate),
        )
        .toList();
    return filtered.isEmpty ? nowPlaying : filtered;
  }

  Future<void> bootstrap() async {
    if (service == null) {
      return;
    }
    try {
      _setLoading(true);
      final results = await Future.wait<List<MovieSummary>>(
        <Future<List<MovieSummary>>>[
          service!.fetchNowPlaying(),
          service!.fetchTrending(),
        ],
      );
      nowPlaying = results[0];
      trending = results[1];
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await bootstrap();
    notifyListeners();
  }

  Future<void> search(String query) async {
    isSearching = query.trim().isNotEmpty;
    if (!isSearching) {
      searchResults = <MovieSummary>[];
      notifyListeners();
      return;
    }
    if (service == null) {
      return;
    }
    try {
      _setLoading(true);
      searchResults = await service!.searchMovies(query);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Future<void> selectMovie(int movieId) async {
    if (service == null) {
      return;
    }
    try {
      _setLoading(true);
      selectedDetail = await service!.fetchMovieDetail(movieId);
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
    notifyListeners();
  }

  void resetDetail() {
    selectedDetail = null;
  }

  @override
  void dispose() {
    service?.client.close();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
