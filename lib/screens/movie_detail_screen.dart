import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/movie_controller.dart';
import '../core/image_urls.dart';
import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../widgets/cast_avatar.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final MovieSummary movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<MovieController>();
      controller.resetDetail();
      controller.selectMovie(widget.movie.id);
    });
  }

  @override
  void dispose() {
    context.read<MovieController>().resetDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovieController>();
    final MovieDetail? detail = controller.selectedDetail;

    final posterUrl = buildPosterUrl(
      detail?.posterPath ?? widget.movie.posterPath,
    );
    final backdropUrl =
        buildBackdropUrl(detail?.backdropPath ?? widget.movie.backdropPath) ??
        posterUrl;

    final String title = detail?.title ?? widget.movie.title;
    final double ratingValue = detail?.voteAverage ?? widget.movie.voteAverage;
    final String ratingText = ratingValue.toStringAsFixed(1);
    final String overview = detail?.overview ?? widget.movie.overview;
    final String year =
        detail?.releaseYearLabel() ?? widget.movie.releaseYearLabel() ?? '--';
    final String genre = detail != null && detail.genres.isNotEmpty
        ? detail.genres.first
        : 'Sin genero';
    final String runtime = detail?.runtimeLabel() ?? '--';
    final String director = (detail?.director ?? '').isEmpty
        ? 'Sin datos'
        : detail!.director!;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          if (backdropUrl != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Hero(
                tag: 'poster-${widget.movie.id}',
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: CachedNetworkImage(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.35),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const <double>[0.0, 0.65],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 220, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _MovieSummaryCard(
                    title: title,
                    ratingText: ratingText,
                    ratingValue: ratingValue,
                    year: year,
                    genre: genre,
                    runtime: runtime,
                    director: director,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Plot Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    overview.isNotEmpty ? overview : 'Sinopsis no disponible.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (detail != null && detail.genres.isNotEmpty) ...<Widget>[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: detail.genres
                          .map(
                            (String name) => Chip(
                              label: Text(name),
                              backgroundColor: const Color(0xFFFFEEF2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text('Cast', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (detail != null && detail.cast.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: detail.cast.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (BuildContext context, int index) {
                          return CastAvatar(person: detail.cast[index]);
                        },
                      ),
                    )
                  else
                    const Text('Informacion de reparto no disponible.'),
                  if (controller.isLoading) ...<Widget>[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieSummaryCard extends StatelessWidget {
  const _MovieSummaryCard({
    required this.title,
    required this.ratingText,
    required this.ratingValue,
    required this.year,
    required this.genre,
    required this.runtime,
    required this.director,
  });

  final String title;
  final String ratingText;
  final double ratingValue;
  final String year;
  final String genre;
  final String runtime;
  final String director;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildStars(ratingValue),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ratingText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C518),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'IMDb',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetadataItem(label: 'Year', value: year),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetadataItem(label: 'Type', value: genre),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetadataItem(label: 'Hour', value: runtime),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetadataItem(label: 'Director', value: director),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    final double normalized = (rating / 2).clamp(0, 5);
    return List<Widget>.generate(5, (int index) {
      final double value = normalized - index;
      IconData icon;
      if (value >= 1) {
        icon = Icons.star_rounded;
      } else if (value > 0) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_outline_rounded;
      }
      return Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(icon, color: Colors.amber, size: 20),
      );
    });
  }
}

class _MetadataItem extends StatelessWidget {
  const _MetadataItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
