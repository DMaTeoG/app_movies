import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/image_urls.dart';
import '../models/person.dart';

class CastAvatar extends StatelessWidget {
  const CastAvatar({super.key, required this.person});

  final PersonRole person;

  @override
  Widget build(BuildContext context) {
    final profileUrl = buildPosterUrl(person.profilePath);
    return SizedBox(
      width: 90,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFEDE7F6),
            backgroundImage: profileUrl != null
                ? CachedNetworkImageProvider(profileUrl)
                : null,
            child: profileUrl == null
                ? Text(
                    person.name.isNotEmpty ? person.name[0] : '?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            person.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            person.role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
