import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/movie_controller.dart';
import '../core/image_urls.dart';
import '../models/movie_summary.dart';
import '../widgets/backdrop_preview.dart';
import '../widgets/date_chip.dart';
import '../widgets/movie_poster_card.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovieController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SearchBar(
                  controller: _queryController,
                  onChanged: controller.search,
                  onClear: () {
                    _queryController.clear();
                    controller.search('');
                  },
                ),
                const SizedBox(height: 24),
                if (controller.errorMessage != null) ...<Widget>[
                  _ErrorBanner(message: controller.errorMessage!),
                  const SizedBox(height: 20),
                ],
                Text('Explora', style: theme.textTheme.titleMedium),
                Text('Top Movies', style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                _buildCalendar(controller),
                const SizedBox(height: 24),
                if (controller.isLoading && controller.nowPlaying.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (controller.isSearching)
                  _SearchResults(
                    results: controller.searchResults,
                    onTap: (MovieSummary movie) => _openDetail(movie),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 340,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.moviesForSelectedDate.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(width: 20),
                          itemBuilder: (BuildContext context, int index) {
                            final movie =
                                controller.moviesForSelectedDate[index];
                            return MoviePosterCard(
                              movie: movie,
                              isLarge: true,
                              onTap: () => _openDetail(movie),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('Trailers', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.trending.length,
                          itemBuilder: (BuildContext context, int index) {
                            final movie = controller.trending[index];
                            return BackdropPreview(
                              movie: movie,
                              onTap: () => _openDetail(movie),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(MovieController controller) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.calendarDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final day = controller.calendarDays[index];
          return DateChip(
            date: day,
            isSelected: _isSameDay(controller.selectedDate, day),
            onTap: () => controller.selectDate(day),
          );
        },
      ),
    );
  }

  void _openDetail(MovieSummary movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar peliculas',
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onTap});

  final List<MovieSummary> results;
  final ValueChanged<MovieSummary> onTap;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Text('No encontramos resultados para tu busqueda.'),
      );
    }
    return Column(
      children: results.map((MovieSummary movie) {
        final posterUrl = buildPosterUrl(movie.posterPath);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Hero(
            tag: 'poster-${movie.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: posterUrl == null
                  ? const SizedBox(
                      width: 54,
                      child: ColoredBox(color: Color(0xFFEDE7F6)),
                    )
                  : Image.network(posterUrl, width: 54, fit: BoxFit.cover),
            ),
          ),
          title: Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            movie.overview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(movie),
        );
      }).toList(),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
