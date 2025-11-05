import 'config.dart';

String? buildPosterUrl(String? path) =>
    path == null ? null : '$imageBaseUrl/$posterSize$path';

String? buildBackdropUrl(String? path) =>
    path == null ? null : '$imageBaseUrl/$backdropSize$path';
