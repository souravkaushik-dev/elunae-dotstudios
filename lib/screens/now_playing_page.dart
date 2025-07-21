/*🔧 Under Design · DotStudios*/

import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/models/position_data.dart';
import 'package:elunae/services/settings_manager.dart';
import 'package:elunae/utilities/common_variables.dart';
import 'package:elunae/utilities/flutter_bottom_sheet.dart';
import 'package:elunae/utilities/flutter_toast.dart';
import 'package:elunae/utilities/formatter.dart';
import 'package:elunae/utilities/mediaitem.dart';
import 'package:elunae/utilities/utils.dart';
import 'package:elunae/widgets/marque.dart';
import 'package:elunae/widgets/playback_icon_button.dart';
import 'package:elunae/widgets/song_artwork.dart';
import 'package:elunae/widgets/song_bar.dart';
import 'package:elunae/widgets/spinner.dart';

final _lyricsController = FlipCardController();

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLargeScreen = size.width > 800;
    const adjustedIconSize = 43.0;
    const adjustedMiniIconSize = 20.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 62,
            borderRadius: 18,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.2),
                Colors.transparent,
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
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 0,
              title: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Hicons.down2LightOutline),
                  iconSize: 32,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.white,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<MediaItem?>(
          stream: audioHandler.mediaItem.distinct((prev, curr) {
            if (prev == null || curr == null) return false;
            return prev.id == curr.id &&
                prev.title == curr.title &&
                prev.artist == curr.artist &&
                prev.artUri == curr.artUri;
          }),
          builder: (context, snapshot) {
            if (snapshot.data == null || !snapshot.hasData) {
              return const SizedBox.shrink();
            } else {
              final metadata = snapshot.data!;
              return isLargeScreen
                  ? _DesktopLayout(
                metadata: metadata,
                size: size,
                adjustedIconSize: adjustedIconSize,
                adjustedMiniIconSize: adjustedMiniIconSize,
              )
                  : _MobileLayout(
                metadata: metadata,
                size: size,
                adjustedIconSize: adjustedIconSize,
                adjustedMiniIconSize: adjustedMiniIconSize,
                isLargeScreen: isLargeScreen,
              );
            }
          },
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.metadata,
    required this.size,
    required this.adjustedIconSize,
    required this.adjustedMiniIconSize,
  });
  final MediaItem metadata;
  final Size size;
  final double adjustedIconSize;
  final double adjustedMiniIconSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 0,
      blur: 20,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.05),
          baseColor.withOpacity(0.02),
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
      padding: const EdgeInsets.all(8), // Optional outer padding
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 5),
                NowPlayingArtwork(size: size, metadata: metadata),
                const SizedBox(height: 5),
                if (!(metadata.extras?['isLive'] ?? false))
                  NowPlayingControls(
                    context: context,
                    size: size,
                    audioId: metadata.extras?['ytid'],
                    adjustedIconSize: adjustedIconSize,
                    adjustedMiniIconSize: adjustedMiniIconSize,
                    metadata: metadata,
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          const Expanded(child: QueueListView()),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.metadata,
    required this.size,
    required this.adjustedIconSize,
    required this.adjustedMiniIconSize,
    required this.isLargeScreen,
  });

  final MediaItem metadata;
  final Size size;
  final double adjustedIconSize;
  final double adjustedMiniIconSize;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return GlassmorphicContainer(
      width: double.infinity,
      borderRadius: 0,
      blur: 20,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.05),
          baseColor.withOpacity(0.02),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      height: 1100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NowPlayingArtwork(size: size, metadata: metadata),
          if (!(metadata.extras?['isLive'] ?? false))
            NowPlayingControls(
              context: context,
              size: size,
              audioId: metadata.extras?['ytid'],
              adjustedIconSize: adjustedIconSize,
              adjustedMiniIconSize: adjustedMiniIconSize,
              metadata: metadata,
            ),
          if (!isLargeScreen) ...[
            BottomActionsRow(
              context: context,
              audioId: metadata.extras?['ytid'],
              metadata: metadata,
              iconSize: adjustedMiniIconSize,
              isLargeScreen: isLargeScreen,
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

class NowPlayingArtwork extends StatelessWidget {
  const NowPlayingArtwork({
    super.key,
    required this.size,
    required this.metadata,
  });
  final Size size;
  final MediaItem metadata;

  @override
  Widget build(BuildContext context) {
    const _padding = 50;
    const _radius = 20.0;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isLandscape = screenWidth > screenHeight;
    final imageSize =
        isLandscape
            ? screenHeight * 0.40
            : (screenWidth + screenHeight) / 3.35 - _padding;
    const lyricsTextStyle = TextStyle(
      fontSize: 24,
      fontFamily: 'regular',
      fontWeight: FontWeight.w500,
    );

    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: !offlineMode.value,
      controller: _lyricsController,
      frontWidget: SongArtworkWidget(
        metadata: metadata,
        size: imageSize,
        errorWidgetIconSize: size.width / 8,
        borderRadius: _radius,
      ),
      backWidget: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: FutureBuilder<String?>(
          future: getSongLyrics(metadata.artist, metadata.title),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
            } else if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text(
                  context.l10n!.lyricsNotAvailable,
                  style: lyricsTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    snapshot.data ?? context.l10n!.lyricsNotAvailable,
                    style: lyricsTextStyle.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class QueueListView extends StatelessWidget {
  const QueueListView({super.key});

  @override
  Widget build(BuildContext context) {
    final _textColor = Theme.of(context).colorScheme.secondary;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            context.l10n!.playlist,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: _textColor),
          ),
        ),
        Expanded(
          child:
              activePlaylist['list'].isEmpty
                  ? Center(
                    child: Text(
                      context.l10n!.noSongsInQueue,
                      style: TextStyle(color: _textColor),
                    ),
                  )
                  : ListView.builder(
                    itemCount: activePlaylist['list'].length,
                    itemBuilder: (context, index) {
                      final borderRadius = getItemBorderRadius(
                        index,
                        activePlaylist['list'].length,
                      );
                      return SongBar(
                        activePlaylist['list'][index],
                        false,
                        onPlay: () {
                          audioHandler.playPlaylistSong(songIndex: index);
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: borderRadius,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class MarqueeTextWidget extends StatelessWidget {
  const MarqueeTextWidget({
    super.key,
    required this.text,
    required this.fontColor,
    required this.fontSize,
    required this.fontWeight,
  });
  final String text;
  final Color fontColor;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return MarqueeWidget(
      backDuration: const Duration(seconds: 1),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }
}

class NowPlayingControls extends StatelessWidget {
  const NowPlayingControls({
    super.key,
    required this.context,
    required this.size,
    required this.audioId,
    required this.adjustedIconSize,
    required this.adjustedMiniIconSize,
    required this.metadata,
  });
  final BuildContext context;
  final Size size;
  final dynamic audioId;
  final double adjustedIconSize;
  final double adjustedMiniIconSize;
  final MediaItem metadata;

  @override
  Widget build(BuildContext context) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          SizedBox(
            width: screenWidth * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MarqueeTextWidget(
                  text: metadata.title,
                  fontColor: Theme.of(context).colorScheme.primary,
                  fontSize: screenHeight * 0.028,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 10),
                if (metadata.artist != null)
                  MarqueeTextWidget(
                    text: metadata.artist!,
                    fontColor: Theme.of(context).colorScheme.secondary,
                    fontSize: screenHeight * 0.017,
                    fontWeight: FontWeight.w500,
                  ),
              ],
            ),
          ),
          const Spacer(),
          const PositionSlider(),
          const Spacer(),
          PlayerControlButtons(
            context: context,
            metadata: metadata,
            iconSize: adjustedIconSize,
            miniIconSize: adjustedMiniIconSize,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class PositionSlider extends StatefulWidget {
  const PositionSlider({super.key});

  @override
  State<PositionSlider> createState() => _PositionSliderState();
}

class _PositionSliderState extends State<PositionSlider> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<PositionData>(
        stream: audioHandler.positionDataStream.distinct(),
        builder: (context, snapshot) {
          final hasData = snapshot.hasData && snapshot.data != null;
          final positionData =
              hasData
                  ? snapshot.data!
                  : PositionData(Duration.zero, Duration.zero, Duration.zero);

          final maxDuration =
              positionData.duration.inSeconds > 0
                  ? positionData.duration.inSeconds.toDouble()
                  : 1.0;

          final currentValue =
              _isDragging
                  ? _dragValue
                  : positionData.position.inSeconds.toDouble();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Slider(
                value: currentValue.clamp(0.0, maxDuration),
                onChanged:
                    hasData
                        ? (value) {
                          setState(() {
                            _isDragging = true;
                            _dragValue = value;
                          });
                        }
                        : null,
                onChangeEnd:
                    hasData
                        ? (value) {
                          audioHandler.seek(Duration(seconds: value.toInt()));
                          setState(() {
                            _isDragging = false;
                          });
                        }
                        : null,
                max: maxDuration,
              ),
              _buildPositionRow(context, primaryColor, positionData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPositionRow(
    BuildContext context,
    Color fontColor,
    PositionData positionData,
  ) {
    final positionText = formatDuration(positionData.position.inSeconds);
    final durationText = formatDuration(positionData.duration.inSeconds);
    final textStyle = TextStyle(fontSize: 15, color: fontColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(positionText, style: textStyle),
          Text(durationText, style: textStyle),
        ],
      ),
    );
  }
}

class PlayerControlButtons extends StatelessWidget {
  const PlayerControlButtons({
    super.key,
    required this.context,
    required this.metadata,
    required this.iconSize,
    required this.miniIconSize,
  });
  final BuildContext context;
  final MediaItem metadata;
  final double iconSize;
  final double miniIconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _primaryColor = theme.colorScheme.primary;
    final _secondaryColor = theme.colorScheme.secondaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildShuffleButton(_primaryColor, _secondaryColor, miniIconSize),
          Row(
            children: [
              _buildPreviousButton(_primaryColor, _secondaryColor, iconSize),
              const SizedBox(width: 10),
              PlaybackIconButton(
                iconColor: _primaryColor,
                iconSize: iconSize, backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 10),
              _buildNextButton(_primaryColor, _secondaryColor, iconSize),
            ],
          ),
          _buildRepeatButton(_primaryColor, _secondaryColor, miniIconSize),
        ],
      ),
    );
  }

  Widget _buildShuffleButton(
    Color primaryColor,
    Color secondaryColor,
    double iconSize,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: shuffleNotifier,
      builder: (_, value, __) {
        return value
            ? IconButton.filled(
              icon: Icon(
                  Hicons.repeate1LightOutline,
                color: secondaryColor,
              ),
              iconSize: iconSize,
              onPressed: () {
                audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
              },
            )
            : IconButton.filledTonal(
              icon: Icon(
                Hicons.shuffle1LightOutline,
                color: primaryColor,
              ),
              iconSize: iconSize,
              onPressed: () {
                audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
              },
            );
      },
    );
  }

  Widget _buildPreviousButton(
    Color primaryColor,
    Color secondaryColor,
    double iconSize,
  ) {
    return ValueListenableBuilder<AudioServiceRepeatMode>(
      valueListenable: repeatNotifier,
      builder: (_, repeatMode, __) {
        return IconButton(
          icon: Icon(
          Hicons.previousLightOutline,
            color: audioHandler.hasPrevious ? primaryColor : secondaryColor,
          ),
          iconSize: iconSize / 1.7,
          onPressed: () => audioHandler.skipToPrevious(),
          splashColor: Colors.transparent,
        );
      },
    );
  }

  Widget _buildNextButton(
    Color primaryColor,
    Color secondaryColor,
    double iconSize,
  ) {
    return ValueListenableBuilder<AudioServiceRepeatMode>(
      valueListenable: repeatNotifier,
      builder: (_, repeatMode, __) {
        return IconButton(
          icon: Icon(
            Hicons.nextLightOutline,
            color: audioHandler.hasNext ? primaryColor : secondaryColor,
          ),
          iconSize: iconSize / 1.7,
          onPressed:
              () =>
                  repeatNotifier.value == AudioServiceRepeatMode.one
                      ? audioHandler.playAgain()
                      : audioHandler.skipToNext(),
          splashColor: Colors.transparent,
        );
      },
    );
  }

  Widget _buildRepeatButton(
    Color primaryColor,
    Color secondaryColor,
    double iconSize,
  ) {
    return ValueListenableBuilder<AudioServiceRepeatMode>(
      valueListenable: repeatNotifier,
      builder: (_, repeatMode, __) {
        return repeatMode != AudioServiceRepeatMode.none
            ? IconButton.filled(
              icon: Icon(
                repeatMode == AudioServiceRepeatMode.all
                    ? FluentIcons.arrow_repeat_all_24_filled
                    : Hicons.repeateOne3LightOutline,
                color: secondaryColor,
              ),
              iconSize: iconSize,
              onPressed: () {
                final newRepeatMode =
                    repeatMode == AudioServiceRepeatMode.all
                        ? AudioServiceRepeatMode.one
                        : AudioServiceRepeatMode.none;

                repeatNotifier.value = newRepeatMode;

                audioHandler.setRepeatMode(newRepeatMode);
              },
            )
            : IconButton.filledTonal(
              icon: Icon(
                Hicons.repeate1LightOutline,
              ),
              iconSize: iconSize,
              onPressed: () {
                final _isSingleSongPlaying = activePlaylist['list'].isEmpty;
                final newRepeatMode =
                    _isSingleSongPlaying
                        ? AudioServiceRepeatMode.one
                        : AudioServiceRepeatMode.all;

                repeatNotifier.value = newRepeatMode;

                if (repeatNotifier.value == AudioServiceRepeatMode.one)
                  audioHandler.setRepeatMode(newRepeatMode);
              },
            );
      },
    );
  }
}

class BottomActionsRow extends StatelessWidget {
  const BottomActionsRow({
    super.key,
    required this.context,
    required this.audioId,
    required this.metadata,
    required this.iconSize,
    required this.isLargeScreen,
  });
  final BuildContext context;
  final dynamic audioId;
  final MediaItem metadata;
  final double iconSize;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) {
    final songLikeStatus = ValueNotifier<bool>(isSongAlreadyLiked(audioId));
    final songOfflineStatus = ValueNotifier<bool>(
      isSongAlreadyOffline(audioId),
    );
    final _primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        _buildOfflineButton(songOfflineStatus, _primaryColor),
        if (!offlineMode.value) _buildAddToPlaylistButton(_primaryColor),
        if (activePlaylist['list'].isNotEmpty && !isLargeScreen)
          _buildQueueButton(context, _primaryColor),
        if (!offlineMode.value) ...[
          _buildLyricsButton(_primaryColor),
          _buildSleepTimerButton(context, _primaryColor),
          _buildLikeButton(songLikeStatus, _primaryColor),
        ],
      ],
    );
  }

  Widget _buildOfflineButton(ValueNotifier<bool> status, Color primaryColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: status,
      builder: (_, value, __) {
        return IconButton.filledTonal(
          icon: Icon(
            value
                ? HugeIcons.strokeRoundedWifiDisconnected02
                : Hicons.wifiLightOutline,
            color: primaryColor,
          ),
          iconSize: iconSize,
          onPressed: () {
            if (value) {
              removeSongFromOffline(audioId);
            } else {
              makeSongOffline(mediaItemToMap(metadata));
            }
            status.value = !status.value;
          },
        );
      },
    );
  }

  Widget _buildAddToPlaylistButton(Color primaryColor) {
    return IconButton.filledTonal(
      icon: Icon(Hicons.addSquareBold, color: primaryColor),
      iconSize: iconSize,
      onPressed: () {
        showAddToPlaylistDialog(context, mediaItemToMap(metadata));
      },
    );
  }

  Widget _buildQueueButton(BuildContext context, Color primaryColor) {
    return IconButton.filledTonal(
      icon: Icon(Hicons.menuHamburger1LightOutline, color: primaryColor),
      iconSize: iconSize,
      onPressed: () {
        showCustomBottomSheet(
          context,
          ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: commonListViewBottmomPadding,
            itemCount: activePlaylist['list'].length,
            itemBuilder: (BuildContext context, int index) {
              final borderRadius = getItemBorderRadius(
                index,
                activePlaylist['list'].length,
              );
              return SongBar(
                activePlaylist['list'][index],
                false,
                onPlay: () {
                  audioHandler.playPlaylistSong(songIndex: index);
                },
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: borderRadius,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLyricsButton(Color primaryColor) {
    return IconButton.filledTonal(
      icon: Icon(Hicons.textLightOutline, color: primaryColor),
      iconSize: iconSize,
      onPressed: _lyricsController.flipcard,
    );
  }

  Widget _buildSleepTimerButton(BuildContext context, Color primaryColor) {
    return ValueListenableBuilder<Duration?>(
      valueListenable: sleepTimerNotifier,
      builder: (_, value, __) {
        return IconButton.filledTonal(
          icon: Icon(
            value != null
                ? Hicons.timeCircle4Bold
                : Hicons.timeCircle4LightOutline,
            color: primaryColor,
          ),
          iconSize: iconSize,
          onPressed: () {
            if (value != null) {
              audioHandler.cancelSleepTimer();
              sleepTimerNotifier.value = null;
              showToast(
                context,
                context.l10n!.sleepTimerCancelled,
                duration: const Duration(seconds: 1, milliseconds: 500),
              );
            } else {
              _showSleepTimerDialog(context);
            }
          },
        );
      },
    );
  }

  Widget _buildLikeButton(ValueNotifier<bool> status, Color primaryColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: status,
      builder: (_, value, __) {
        final icon =
            value ? Hicons.heart2Bold : Hicons.heart2LightOutline;

        return IconButton.filledTonal(
          icon: Icon(icon, color: primaryColor),
          iconSize: iconSize,
          onPressed: () {
            updateSongLikeStatus(audioId, !status.value);
            status.value = !status.value;
          },
        );
      },
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final duration = sleepTimerNotifier.value ?? Duration.zero;
        var hours = duration.inMinutes ~/ 60;
        var minutes = duration.inMinutes % 60;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n!.setSleepTimer),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n!.selectDuration),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n!.hours),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (hours > 0) {
                                setState(() {
                                  hours--;
                                });
                              }
                            },
                          ),
                          Text('$hours'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                hours++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n!.minutes),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (minutes > 0) {
                                setState(() {
                                  minutes--;
                                });
                              }
                            },
                          ),
                          Text('$minutes'),
                          IconButton(
                            icon: Icon(Hicons.addLightOutline),
                            onPressed: () {
                              setState(() {
                                minutes++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final duration = Duration(hours: hours, minutes: minutes);
                    if (duration.inSeconds > 0) {
                      audioHandler.setSleepTimer(duration);
                      showToast(
                        context,
                        context.l10n!.sleepTimerSet,
                        duration: const Duration(seconds: 1, milliseconds: 500),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n!.setTimer),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
