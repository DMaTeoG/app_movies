import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/movie_controller.dart';
import '../core/image_urls.dart';
import '../models/movie_detail.dart';
import '../models/movie_summary.dart';
import '../widgets/cast_avatar.dart';
import '../widgets/info_badge.dart';

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

    final title = detail?.title ?? widget.movie.title;
    final rating = (detail?.voteAverage ?? widget.movie.voteAverage)
        .toStringAsFixed(1);
    final overview = detail?.overview ?? widget.movie.overview;
    final year =
        detail?.releaseYearLabel() ?? widget.movie.releaseYearLabel() ?? '--';
    final genre = detail?.genres.isNotEmpty == true
        ? detail!.genres.first
        : 'Sin genero';
    final runtime = detail?.runtimeLabel() ?? '--';
    final director = (detail?.director ?? '').isEmpty
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
                    Colors.black.withValues(alpha: 0.3),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  stops: const <double>[0.3, 0.8],
                ),
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 320,
                left: 24,
                right: 24,
                bottom: 36,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: posterUrl == null
                                  ? const SizedBox(
                                      width: 110,
                                      height: 160,
                                      child: ColoredBox(
                                        color: Color(0xFFEDE7F6),
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: posterUrl,
                                      width: 110,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(height: 1.2),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Text(
                                              'IMDb',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              rating,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            rating,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: <Widget>[
                                      InfoBadge(label: 'Anio', value: year),
                                      InfoBadge(label: 'Genero', value: genre),
                                      InfoBadge(
                                        label: 'Duracion',
                                        value: runtime,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Director',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          director,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Sinopsis',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          overview.isNotEmpty
                              ? overview
                              : 'Sinopsis no disponible.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        if (detail != null &&
                            detail.genres.isNotEmpty) ...<Widget>[
                          Text(
                            'Etiquetas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: detail.genres
                                .map(
                                  (String genre) => Chip(
                                    label: Text(genre),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 18),
                        ],
                        Text(
                          'Reparto',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (detail?.cast.isNotEmpty == true)
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: detail!.cast.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (BuildContext context, int index) {
                                return CastAvatar(person: detail.cast[index]);
                              },
                            ),
                          )
                        else
                          const Text('Informacion de reparto no disponible.'),
                      ],
                    ),
                  ),
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
