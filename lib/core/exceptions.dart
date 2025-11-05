class MovieApiException implements Exception {
  MovieApiException(this.message);
  final String message;

  @override
  String toString() => 'MovieApiException: $message';
}

class MovieApiKeyMissingException extends MovieApiException {
  MovieApiKeyMissingException()
    : super(
        'TMDB_READ_ACCESS_TOKEN no esta configurado. '
        'Ejecuta la app con --dart-define=TMDB_READ_ACCESS_TOKEN=tu_token o actualiza core/config.dart.',
      );
}
