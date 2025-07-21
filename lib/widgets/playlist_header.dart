/*🔧 Under Design · DotStudios*/

import 'package:flutter/material.dart';
import 'package:elunae/extensions/l10n.dart';

class PlaylistHeader extends StatelessWidget {
  const PlaylistHeader(this.image, this.title, this.songsLength, {super.key});

  final Widget image;
  final String title;
  final int songsLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'regular',
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$songsLength ${context.l10n!.songs}'.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'regular',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
