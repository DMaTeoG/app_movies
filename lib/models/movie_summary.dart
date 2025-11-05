import 'dart:convert';

class MovieSummary {
  MovieSummary({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final DateTime? releaseDate;

  factory MovieSummary.fromMap(Map<String, dynamic> map) {
    return MovieSummary(
      id: map['id'] as int,
      title: map['title'] as String? ?? map['name'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      posterPath: map['poster_path'] as String?,
      backdropPath: map['backdrop_path'] as String?,
      voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: parseDate(
        map['release_date'] as String? ?? map['first_air_date'] as String?,
      ),
    );
  }

  factory MovieSummary.fromJson(String source) =>
      MovieSummary.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  String? releaseYearLabel() => releaseDate?.year.toString();
}
