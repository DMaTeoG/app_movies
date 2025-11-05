import 'dart:convert';

import 'package:app_movies/models/movie_summary.dart';

import 'person.dart';

class MovieDetail extends MovieSummary {
  MovieDetail({
    required super.id,
    required super.title,
    required super.overview,
    required super.posterPath,
    required super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required this.genres,
    required this.runtime,
    required this.tagline,
    required this.director,
    required this.cast,
  });

  final List<String> genres;
  final int? runtime;
  final String? tagline;
  final String? director;
  final List<PersonRole> cast;

  factory MovieDetail.fromMap(
    Map<String, dynamic> map, {
    required String? director,
    required List<PersonRole> cast,
  }) {
    return MovieDetail(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: MovieSummary.parseDate(map['release_date'] as String?),
      genres: (map['genres'] as List<dynamic>? ?? [])
          .map(
            (dynamic genre) =>
                (genre as Map<String, dynamic>)['name'] as String,
          )
          .toList(),
      runtime: map['runtime'] as int?,
      tagline: map['tagline'] as String?,
      director: director,
      cast: cast,
    );
  }

  factory MovieDetail.fromJson(
    String source, {
    required String? director,
    required List<PersonRole> cast,
  }) => MovieDetail.fromMap(
    json.decode(source) as Map<String, dynamic>,
    director: director,
    cast: cast,
  );

  String runtimeLabel() {
    if (runtime == null || runtime == 0) {
      return '--';
    }
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}
