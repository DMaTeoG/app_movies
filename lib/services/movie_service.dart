import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../core/exceptions.dart';
import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../models/person.dart';

class MovieService {
  MovieService({http.Client? client, String? accessToken})
    : client = client ?? http.Client(),
      accessToken = accessToken ?? tmdbReadAccessToken {
    if (this.accessToken.isEmpty) {
      throw MovieApiKeyMissingException();
    }
  }

  final http.Client client;
  final String accessToken;

  Map<String, String> get _headers => <String, String>{
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, String>? query]) => Uri.https(
    'api.themoviedb.org',
    '/3/$path',
    <String, String>{'language': tmdbLanguage, if (query != null) ...query},
  );

  Future<List<MovieSummary>> fetchNowPlaying({int page = 1}) async =>
      _fetchSummaryList(
        'movie/now_playing',
        query: <String, String>{'page': '$page'},
      );

  Future<List<MovieSummary>> fetchTrending({int page = 1}) async =>
      _fetchSummaryList(
        'trending/movie/week',
        query: <String, String>{'page': '$page'},
      );

  Future<List<MovieSummary>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      return <MovieSummary>[];
    }
    return _fetchSummaryList(
      'search/movie',
      query: <String, String>{'query': query, 'include_adult': 'false'},
    );
  }

  Future<MovieDetail> fetchMovieDetail(int id) async {
    final responses = await Future.wait<http.Response>(<Future<http.Response>>[
      client.get(_buildUri('movie/$id'), headers: _headers),
      client.get(_buildUri('movie/$id/credits'), headers: _headers),
    ]);

    for (final response in responses) {
      if (response.statusCode != 200) {
        throw MovieApiException(
          'TMDB devolvio ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    }

    final detailMap = json.decode(responses[0].body) as Map<String, dynamic>;
    final creditsMap = json.decode(responses[1].body) as Map<String, dynamic>;

    final crew = (creditsMap['crew'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => item as Map<String, dynamic>)
        .toList();
    final director =
        crew.firstWhere(
              (Map<String, dynamic> member) => member['job'] == 'Director',
              orElse: () => <String, dynamic>{},
            )['name']
            as String?;

    final castList = (creditsMap['cast'] as List<dynamic>? ?? <dynamic>[])
        .take(10)
        .map(
          (dynamic item) => PersonRole(
            name: (item as Map<String, dynamic>)['name'] as String? ?? '',
            role: item['character'] as String? ?? '',
            profilePath: item['profile_path'] as String?,
          ),
        )
        .toList();

    return MovieDetail.fromMap(detailMap, director: director, cast: castList);
  }

  Future<List<MovieSummary>> _fetchSummaryList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await client.get(
      _buildUri(path, query),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw MovieApiException(
        'TMDB devolvio ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? <dynamic>[];
    return results
        .map(
          (dynamic item) => MovieSummary.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }
}
