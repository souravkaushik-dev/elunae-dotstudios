/*🔧 Under Design · DotStudios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';

import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/utilities/common_variables.dart';
import 'package:elunae/utilities/utils.dart';
import 'package:elunae/widgets/confirmation_dialog.dart';
import 'package:elunae/widgets/playlist_bar.dart';

class PlaylistFolderPage extends StatefulWidget {
  const PlaylistFolderPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  final String folderId;
  final String folderName;

  @override
  State<PlaylistFolderPage> createState() => _PlaylistFolderPageState();
}

class _PlaylistFolderPageState extends State<PlaylistFolderPage> {
  late List<Map> _playlists;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  void _loadPlaylists() {
    setState(() {
      _playlists = getPlaylistsInFolder(widget.folderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Theme.of(context).colorScheme.surface,
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Hicons.delete1LightOutline,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n!.deleteFolder,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteFolderDialog();
              }
            },
          ),
        ],
      ),
      body:
          _playlists.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                padding: commonSingleChildScrollViewPadding,
                child: Column(children: [_buildPlaylistList()]),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Hicons.folderAdd1LightOutline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n!.emptyFolderMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _playlists.length,
      padding: commonListViewBottmomPadding,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        final borderRadius = getItemBorderRadius(index, _playlists.length);

        return PlaylistBar(
          key: ValueKey(playlist['ytid']),
          playlist['title'],
          playlistId: playlist['ytid'],
          playlistArtwork: playlist['image'],
          playlistData: playlist,
          onDelete: () => _showRemovePlaylistDialog(playlist),
          borderRadius: borderRadius,
        );
      },
    );
  }

  void _showRemovePlaylistDialog(Map playlist) {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            submitMessage: context.l10n!.remove,
            confirmationMessage: context.l10n!.removeFromFolder,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: () {
              Navigator.of(context).pop();
              movePlaylistToFolder(playlist, null, context);
              _loadPlaylists();
            },
          ),
    );
  }

  void _showDeleteFolderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            submitMessage: context.l10n!.delete,
            confirmationMessage: context.l10n!.deleteFolderQuestion,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: () {
              Navigator.of(context).pop();
              deletePlaylistFolder(widget.folderId, context);
              Navigator.of(context).pop(); // Go back to library
            },
          ),
    );
  }
}
