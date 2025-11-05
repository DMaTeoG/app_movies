import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/movie_controller.dart';
import 'core/exceptions.dart';
import 'screens/home_screen.dart';
import 'services/movie_service.dart';
import 'theme/app_theme.dart';

void main() {
  MovieService? service;
  String? initialError;

  try {
    service = MovieService();
  } on MovieApiException catch (error) {
    initialError = error.message;
  } catch (error) {
    initialError = error.toString();
  }

  runApp(MoviesApp(service: service, initialError: initialError));
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key, required this.service, this.initialError});

  final MovieService? service;
  final String? initialError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MovieController>(
      create: (_) =>
          MovieController(service: service, initialError: initialError)
            ..bootstrap(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movie Explorer',
        theme: AppTheme.buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
