/*🔧 Under Design · DotStudios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/screens/playlist_folder_page.dart';
import 'package:elunae/screens/playlist_page.dart';
import 'package:elunae/utilities/common_variables.dart';

class PlaylistBar extends StatelessWidget {
  PlaylistBar(
    this.playlistTitle, {
    super.key,
    this.playlistId,
    this.playlistArtwork,
    this.playlistData,
    this.onPressed,
    this.onDelete,
    this.cubeIcon = Hicons.musicnoteLightOutline,
    this.showBuildActions = true,
    this.isAlbum = false,
    this.borderRadius = BorderRadius.zero,
  }) : playlistLikeStatus = ValueNotifier<bool>(
         isPlaylistAlreadyLiked(playlistId),
       );

  final Map? playlistData;
  final String? playlistId;
  final String playlistTitle;
  final String? playlistArtwork;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;
  final IconData cubeIcon;
  final bool? isAlbum;
  final bool showBuildActions;
  final BorderRadius borderRadius;

  static const double artworkSize = 60;
  static const double iconSize = 27;

  final ValueNotifier<bool> playlistLikeStatus;

  static const likeStatusToIconMapper = {
    true: Hicons.heart3Bold,
    false: Hicons.heart3LightOutline
  };

  // Helper to determine if this is a folder
  bool get isFolder =>
      playlistData != null && playlistData!.containsKey('playlists');

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;
    Map<dynamic, dynamic>? updatedPlaylist;

    return Padding(
      padding: commonBarPadding,
      child: GestureDetector(
        onTap: onPressed ??
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(
                    playlistId: playlistId,
                    playlistData: updatedPlaylist ?? playlistData,
                  ),
                ),
              ).then((isPlaylistUpdated) {
                if (playlistId != null &&
                    isPlaylistUpdated != null &&
                    isPlaylistUpdated) {
                  getPlaylistInfoForWidget(
                    playlistId,
                  ).then((result) => updatedPlaylist = result);
                }
              });
            },
        child:  GlassmorphicContainer(
          width: double.infinity,
          height: 75,
          borderRadius: 20,
          blur: 15,
          border: 1,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 5),
          padding: EdgeInsets.zero, // we'll handle padding inside ListTile

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

          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12), // 👈 Fix here
            leading: isFolder
                ? _buildFolderIcon(primaryColor)
                : _buildPlaylistIcon(primaryColor),
            title: Text(
              playlistTitle,
              style: commonBarTitleStyle.copyWith(color: primaryColor),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: isFolder ? _buildFolderSubtitle(context) : null,
            trailing: showBuildActions
                ? _buildActionButtons(context, primaryColor)
                : null,
            onTap: onPressed ?? _getDefaultOnPressed(context, updatedPlaylist),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistIcon(Color primaryColor) {
    if (playlistArtwork != null && playlistArtwork!.isNotEmpty) {
      // Use artwork if available
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image:
                playlistArtwork!.startsWith('http')
                    ? NetworkImage(playlistArtwork!) as ImageProvider
                    : AssetImage(playlistArtwork!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Use icon with consistent styling
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: primaryColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(cubeIcon, color: primaryColor, size: 24),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.surface,
      icon: Icon(Hicons.menuMeatballsBold, color: primaryColor),
      onSelected: (String value) {
        switch (value) {
          case 'like':
            if (playlistId != null) {
              final newValue = !playlistLikeStatus.value;
              playlistLikeStatus.value = newValue;
              updatePlaylistLikeStatus(playlistId!, newValue);
              currentLikedPlaylistsLength.value += newValue ? 1 : -1;
            }
            break;
          case 'delete':
            if (onDelete != null) onDelete!();
            break;
          case 'moveToFolder':
            _showMoveToFolderDialog(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (onDelete == null)
            PopupMenuItem<String>(
              value: 'like',
              child: Row(
                children: [
                  Icon(
                    likeStatusToIconMapper[playlistLikeStatus.value],
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    playlistLikeStatus.value
                        ? context.l10n!.removeFromLikedPlaylists
                        : context.l10n!.addToLikedPlaylists,
                  ),
                ],
              ),
            ),
          if (playlistData != null &&
              !isFolder &&
              (playlistData!['source'] == 'user-created' ||
                  playlistData!['source'] == 'user-youtube'))
            PopupMenuItem<String>(
              value: 'moveToFolder',
              child: Row(
                children: [
                  Icon(Hicons.folder1LightOutline, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(context.l10n!.moveToFolder),
                ],
              ),
            ),
          if (onDelete != null)
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Hicons.delete1LightOutline,
                    color:
                        isFolder
                            ? Theme.of(context).colorScheme.error
                            : primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFolder
                        ? context.l10n!.deleteFolder
                        : context.l10n!.deletePlaylist,
                    style:
                        isFolder
                            ? TextStyle(
                              color: Theme.of(context).colorScheme.error, fontFamily: 'thin'
                            )
                            : null,
                  ),
                ],
              ),
            ),
        ];
      },
    );
  }

  void _showMoveToFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n!.moveToFolder),
          content: SizedBox(
            width: double.maxFinite,
            child: ValueListenableBuilder<List>(
              valueListenable: userPlaylistFolders,
              builder: (context, folders, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Option to remove from folder (move to main library)
                    ListTile(
                      leading: Icon(
                        HugeIcons.strokeRoundedBookshelf03,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(context.l10n!.library),
                      onTap: () {
                        Navigator.pop(context);
                        if (playlistData != null) {
                          movePlaylistToFolder(playlistData!, null, context);
                        }
                      },
                    ),
                    const Divider(),
                    // List of available folders
                    if (folders.isNotEmpty)
                      ...folders.map((folder) {
                        return ListTile(
                          leading: Icon(
                            Hicons.folder1LightOutline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            folder['name'],
                            style: TextStyle(
                              fontFamily: 'regular', // Replace with your font's name
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white, // Or use Theme.of(context).colorScheme...
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (playlistData != null) {
                              movePlaylistToFolder(
                                playlistData!,
                                folder['id'],
                                context,
                              );
                            }
                          },
                        );
                      })
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.l10n!.noCustomPlaylists,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n!.cancel),
            ),
          ],
        );
      },
    );
  }

  // Helper methods for folder display
  Widget _buildFolderIcon(Color primaryColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Hicons.folder1Bold, color: primaryColor, size: 24),
    );
  }

  Widget? _buildFolderSubtitle(BuildContext context) {
    if (!isFolder || playlistData == null) return null;

    final playlistCount = (playlistData!['playlists'] as List?)?.length ?? 0;
    return Text(
      playlistCount == 1
          ? '1 ${context.l10n!.playlist.toLowerCase()}'
          : '$playlistCount ${context.l10n!.playlists.toLowerCase()}',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        fontSize: 12,
      ),
    );
  }

  VoidCallback? _getDefaultOnPressed(
    BuildContext context,
    Map<dynamic, dynamic>? updatedPlaylist,
  ) {
    if (isFolder && playlistData != null) {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlaylistFolderPage(
                  folderId: playlistData!['id'],
                  folderName: playlistTitle,
                ),
          ),
        );
      };
    } else {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PlaylistPage(
                  playlistId: playlistId,
                  playlistData: updatedPlaylist ?? playlistData,
                ),
          ),
        ).then((isPlaylistUpdated) {
          if (playlistId != null &&
              isPlaylistUpdated != null &&
              isPlaylistUpdated) {
            getPlaylistInfoForWidget(
              playlistId,
            ).then((result) => {updatedPlaylist = result});
          }
        });
      };
    }
  }
}
