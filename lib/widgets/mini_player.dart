/*🔧 Under Design · DotStudios*/

import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:elunae/main.dart';
import 'package:elunae/models/position_data.dart';
import 'package:elunae/screens/now_playing_page.dart';
import 'package:elunae/widgets/marque.dart';
import 'package:elunae/widgets/song_artwork.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key, required this.metadata});

  final MediaItem metadata;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
    with SingleTickerProviderStateMixin {
  static const _playerHeight = 75.0;
  static const _progressBarHeight = 2.0;
  static const _artworkSize = 55.0;
  static const _artworkIconSize = 30.0;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller for visual feedback
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onVerticalDragUpdate: _handleVerticalDrag,
            onTap: _navigateToNowPlaying,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlayerBody(colorScheme),
                _buildProgressBar(colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerBody(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return GlassmorphicContainer(
      width: double.infinity,
      height: _playerHeight,
      borderRadius: 20,
      blur: 15,
      border: 1,
      alignment: Alignment.center,

      // ✅ Use internal padding instead of external
      padding: const EdgeInsets.symmetric(horizontal: 18),

      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.08),
          baseColor.withOpacity(0.03),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.05),
        ],
      ),

      child: Row(
        children: [
          _ArtworkWidget(metadata: widget.metadata),
          _MetadataWidget(
            title: widget.metadata.title,
            artist: widget.metadata.artist,
            titleColor: colorScheme.primary,
            artistColor: colorScheme.secondary,
          ),
          _ControlsWidget(colorScheme: colorScheme),
        ],
      ),
    );
  }


  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 2), // 👈 horizontal & vertical space
      child: StreamBuilder<PositionData>(
        stream: audioHandler.positionDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const SizedBox.shrink();
          }

          final positionData = snapshot.data ??
              PositionData(Duration.zero, Duration.zero, Duration.zero);
          final duration = positionData.duration;

          final progress = (positionData.position.inSeconds / duration.inSeconds)
              .clamp(0.0, 1.0);

          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 3, // vertical thickness
              width: double.infinity, // full width; or set to fixed width if needed
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          );
        },
      ),
    );
  }


  void _handleVerticalDrag(DragUpdateDetails details) {
    // Only navigate on upward swipe
    if (details.primaryDelta! < -10) {
      _navigateToNowPlaying();
    }
  }

  void _navigateToNowPlaying() {
    Navigator.push(context, _createSlideTransition());
  }

  PageRoute _createSlideTransition() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, _) => const NowPlayingPage(),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class _ArtworkWidget extends StatelessWidget {
  const _ArtworkWidget({required this.metadata});

  final MediaItem metadata;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 7, right: 15),
      child: Hero(
        tag: 'now_playing_artwork',
        child: SongArtworkWidget(
          metadata: metadata,
          size: _MiniPlayerState._artworkSize,
          errorWidgetIconSize: _MiniPlayerState._artworkIconSize,
          borderRadius: 20,
        ),
      ),
    );
  }
}

class _MetadataWidget extends StatelessWidget {
  const _MetadataWidget({
    required this.title,
    required this.artist,
    required this.titleColor,
    required this.artistColor,
  });

  final String title;
  final String? artist;
  final Color titleColor;
  final Color artistColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MarqueeWidget(
            manualScrollEnabled: false,
            animationDuration: const Duration(seconds: 8),
            backDuration: const Duration(seconds: 2),
            pauseDuration: const Duration(seconds: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontFamily:'thin',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (artist != null && artist!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    artist!,
                    style: TextStyle(
                      color: artistColor,
                      fontFamily: 'ultrathin',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsWidget extends StatelessWidget {
  const _ControlsWidget({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlayPauseButton(colorScheme: colorScheme),
        _NextButton(colorScheme: colorScheme),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState.distinct((previous, current) {
        // Only rebuild if relevant state changes
        return previous.playing == current.playing &&
            previous.processingState == current.processingState;
      }),
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final processingState = playbackState?.processingState;
        final isPlaying = playbackState?.playing ?? false;

        Widget iconWidget;
        VoidCallback? onPressed;

        if (processingState == AudioProcessingState.loading ||
            processingState == AudioProcessingState.buffering) {
          iconWidget = SizedBox(
            width: 35,
            height: 35,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          );
          onPressed = null;
        } else {
          final iconData =
              isPlaying
                  ? Hicons.stopLightOutline
                  : Hicons.playLightOutline;

          iconWidget = Icon(iconData, color: colorScheme.primary, size: 35);

          onPressed = isPlaying ? audioHandler.pause : audioHandler.play;
        }

        return GestureDetector(
          onTap: onPressed,
          child: Container(padding: const EdgeInsets.all(4), child: iconWidget),
        );
      },
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaItem>>(
      stream: audioHandler.queue,
      builder: (context, snapshot) {
        final hasNext = audioHandler.hasNext;

        if (!hasNext) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            onTap: audioHandler.skipToNext,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Hicons.nextLightOutline,
                color: colorScheme.primary,
                size: 25,
              ),
            ),
          ),
        );
      },
    );
  }
}
