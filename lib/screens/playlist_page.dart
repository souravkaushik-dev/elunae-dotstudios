/*🔧 Under Design · DotStudios*/

import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/services/data_manager.dart';
import 'package:elunae/services/playlist_download_service.dart';
import 'package:elunae/services/playlist_sharing.dart';
import 'package:elunae/utilities/common_variables.dart';
import 'package:elunae/utilities/flutter_toast.dart';
import 'package:elunae/utilities/playlist_image_picker.dart';
import 'package:elunae/utilities/utils.dart';
import 'package:elunae/widgets/playlist_cube.dart';
import 'package:elunae/widgets/playlist_header.dart';
import 'package:elunae/widgets/song_bar.dart';
import 'package:elunae/widgets/spinner.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({
    super.key,
    this.playlistId,
    this.playlistData,
    this.cubeIcon = Hicons.musicnoteLightOutline,
    this.isArtist = false,
  });

  final String? playlistId;
  final dynamic playlistData;
  final IconData cubeIcon;
  final bool isArtist;

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<dynamic> _songsList = [];
  dynamic _playlist;

  bool _isLoading = true;
  bool _hasMore = true;
  final int _itemsPerPage = 35;
  var _currentPage = 0;
  var _currentLastLoadedId = 0;
  late final playlistLikeStatus = ValueNotifier<bool>(
    isPlaylistAlreadyLiked(widget.playlistId),
  );
  bool playlistOfflineStatus = false;

  @override
  void initState() {
    super.initState();
    _initializePlaylist();
  }

  Future<void> _initializePlaylist() async {
    try {
      if (widget.playlistData != null) {
        _playlist = widget.playlistData;
        // Check if the playlist has songs loaded
        final playlistList = _playlist!['list'] as List?;
        if (playlistList == null || playlistList.isEmpty) {
          // Songs not loaded, fetch them
          final fullPlaylist = await getPlaylistInfoForWidget(
            widget.playlistId,
            isArtist: widget.isArtist,
          );
          if (fullPlaylist != null) {
            _playlist = fullPlaylist;
          }
        }
      } else {
        _playlist = await getPlaylistInfoForWidget(
          widget.playlistId,
          isArtist: widget.isArtist,
        );
      }

      if (_playlist != null) {
        _loadMore();
      }
    } catch (e, stackTrace) {
      logger.log('Error initializing playlist:', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast(context, context.l10n!.error);
      }
    }
  }

  void _loadMore() {
    _isLoading = true;
    fetch()
        .then((List<dynamic> fetchedList) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (fetchedList.isEmpty) {
                _hasMore = false;
              } else {
                _songsList.addAll(fetchedList);
              }
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  Future<List<dynamic>> fetch() async {
    try {
      final list = <dynamic>[];
      final _count = _playlist['list'].length as int;
      final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);
      for (var i = 0; i < n; i++) {
        list.add(_playlist['list'][_currentLastLoadedId]);
        _currentLastLoadedId++;
      }

      _currentPage++;
      return list;
    } catch (e, stackTrace) {
      logger.log('Error fetching playlist songs:', e, stackTrace);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pop(context, widget.playlistData == _playlist),
        ),
        actions: [
          if (widget.playlistId != null) ...[_buildLikeButton()],
          const SizedBox(width: 10),
          if (_playlist != null) ...[
            _buildSyncButton(),
            const SizedBox(width: 10),
            _buildDownloadButton(),
            const SizedBox(width: 10),
            if (_playlist['source'] == 'user-created')
              IconButton(
                icon: const Icon(Hicons.send3LightOutline),
                onPressed: () async {
                  final encodedPlaylist = PlaylistSharingService.encodePlaylist(
                    _playlist,
                  );

                  final url = 'elunae://playlist/custom/$encodedPlaylist';
                  await Clipboard.setData(ClipboardData(text: url));
                },
              ),
            const SizedBox(width: 10),
          ],
          if (_playlist != null && _playlist['source'] == 'user-created') ...[
            _buildEditButton(),
            const SizedBox(width: 10),
          ],
        ],
      ),
      body:
          _playlist != null
              ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: buildPlaylistHeader(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: buildSongActionsRow(),
                    ),
                  ),
                  SliverPadding(
                    padding: commonListViewBottmomPadding,
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final isRemovable =
                              _playlist['source'] == 'user-created';
                          return _buildSongListItem(index, isRemovable);
                        },
                        childCount:
                            _hasMore
                                ? _songsList.length + 1
                                : _songsList.length,
                      ),
                    ),
                  ),
                ],
              )
              : SizedBox(
                height: MediaQuery.sizeOf(context).height - 100,
                child: const Spinner(),
              ),
    );
  }

  Widget _buildPlaylistImage() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLandscape = screenWidth > MediaQuery.sizeOf(context).height;
    return PlaylistCube(
      _playlist,
      size: isLandscape ? 300 : screenWidth / 2.5,
      cubeIcon: widget.cubeIcon,
    );
  }

  Widget buildPlaylistHeader() {
    final _songsLength = _playlist['list'].length;

    return PlaylistHeader(
      _buildPlaylistImage(),
      _playlist['title'],
      _songsLength,
    );
  }

  Widget _buildLikeButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: playlistLikeStatus,
      builder: (_, value, __) {
        return IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon:
              value
                  ? const Icon(Hicons.heart3Bold)
                  : const Icon(Hicons.heart3LightOutline),
          iconSize: 26,
          onPressed: () {
            playlistLikeStatus.value = !playlistLikeStatus.value;
            updatePlaylistLikeStatus(
              _playlist['ytid'],
              playlistLikeStatus.value,
            );
            currentLikedPlaylistsLength.value =
                value
                    ? currentLikedPlaylistsLength.value + 1
                    : currentLikedPlaylistsLength.value - 1;
          },
        );
      },
    );
  }

  Widget _buildSyncButton() {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: const Icon(Hicons.refresh1LightOutline),
      iconSize: 26,
      onPressed: _handleSyncPlaylist,
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: const Icon(Hicons.edit2LightOutline),
      iconSize: 26,
      onPressed:
          () => showDialog(
            context: context,
            builder: (BuildContext context) {
              String customPlaylistName = _playlist['title'];
              String? imageUrl = _playlist['image'];
              var imageBase64 =
                  (imageUrl != null && imageUrl.startsWith('data:'))
                      ? imageUrl
                      : null;
              if (imageBase64 != null) imageUrl = null;

              return StatefulBuilder(
                builder: (context, dialogSetState) {
                  Future<void> _pickImage() async {
                    final result = await pickImage();
                    if (result != null) {
                      dialogSetState(() {
                        imageBase64 = result;
                        imageUrl = null;
                      });
                    }
                  }

                  Widget _imagePreview() {
                    return buildImagePreview(
                      imageBase64: imageBase64,
                      imageUrl: imageUrl,
                    );
                  }

                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 7),
                          TextField(
                            controller: TextEditingController(
                              text: customPlaylistName,
                            ),
                            decoration: InputDecoration(
                              labelText: context.l10n!.customPlaylistName,
                            ),
                            onChanged: (value) {
                              customPlaylistName = value;
                            },
                          ),
                          if (imageBase64 == null) ...[
                            const SizedBox(height: 7),
                            TextField(
                              controller: TextEditingController(text: imageUrl),
                              decoration: InputDecoration(
                                labelText: context.l10n!.customPlaylistImgUrl,
                              ),
                              onChanged: (value) {
                                imageUrl = value;
                                imageBase64 = null;
                                dialogSetState(() {});
                              },
                            ),
                          ],
                          const SizedBox(height: 7),
                          if (imageUrl == null) ...[
                            buildImagePickerRow(
                              context,
                              _pickImage,
                              imageBase64 != null,
                            ),
                            _imagePreview(),
                          ],
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(context.l10n!.update.toUpperCase()),
                        onPressed: () {
                          final index = userCustomPlaylists.value.indexOf(
                            widget.playlistData,
                          );

                          if (index != -1) {
                            final newPlaylist = {
                              'title': customPlaylistName,
                              'source': 'user-created',
                              if (imageBase64 != null)
                                'image': imageBase64
                              else if (imageUrl != null)
                                'image': imageUrl,
                              'list': widget.playlistData['list'],
                            };
                            final updatedPlaylists = List<Map>.from(
                              userCustomPlaylists.value,
                            );
                            updatedPlaylists[index] = newPlaylist;
                            userCustomPlaylists.value = updatedPlaylists;
                            addOrUpdateData(
                              'user',
                              'customPlaylists',
                              userCustomPlaylists.value,
                            );
                            setState(() {
                              _playlist = newPlaylist;
                            });
                            showToast(context, context.l10n!.playlistUpdated);
                          }

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildDownloadButton() {
    final playlistId = widget.playlistId ?? _playlist['title'];

    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: offlinePlaylistService.offlinePlaylists,
      builder: (context, offlinePlaylists, _) {
        playlistOfflineStatus = offlinePlaylistService.isPlaylistDownloaded(
          playlistId,
        );

        if (playlistOfflineStatus) {
          return IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(Hicons.downloadLightOutline),
            iconSize: 26,
            onPressed: () => _showRemoveOfflineDialog(playlistId),
            tooltip: context.l10n!.removeOffline,
          );
        }

        return ValueListenableBuilder<DownloadProgress>(
          valueListenable: offlinePlaylistService.getProgressNotifier(
            playlistId,
          ),
          builder: (context, progress, _) {
            final isDownloading = offlinePlaylistService.isPlaylistDownloading(
              playlistId,
            );

            if (isDownloading) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.progress,
                    strokeWidth: 2,
                    backgroundColor: Colors.grey.withValues(alpha: .3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: const Icon(FluentIcons.dismiss_24_filled),
                    iconSize: 14,
                    onPressed:
                        () => offlinePlaylistService.cancelDownload(
                          context,
                          playlistId,
                        ),
                    tooltip: context.l10n!.cancel,
                  ),
                ],
              );
            }

            return IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Hicons.downloadLightOutline),
              iconSize: 26,
              onPressed:
                  () => offlinePlaylistService.downloadPlaylist(
                    context,
                    _playlist,
                  ),
              tooltip: context.l10n!.downloadPlaylist,
            );
          },
        );
      },
    );
  }

  void _showRemoveOfflineDialog(String playlistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n!.removeOfflinePlaylist),
          content: Text(context.l10n!.removeOfflinePlaylistConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n!.cancel.toUpperCase()),
            ),
            TextButton(
              onPressed: () {
                offlinePlaylistService.removeOfflinePlaylist(playlistId);
                Navigator.pop(context);
                showToast(context, context.l10n!.playlistRemovedFromOffline);
              },
              child: Text(context.l10n!.remove.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void _handleSyncPlaylist() async {
    if (_playlist['ytid'] != null) {
      _playlist = await updatePlaylistList(context, _playlist['ytid']);
      _hasMore = true;
      _songsList.clear();
      setState(() {
        _currentPage = 0;
        _currentLastLoadedId = 0;
        _loadMore();
      });
    } else {
      final updatedPlaylist = await getPlaylistInfoForWidget(widget.playlistId);
      if (updatedPlaylist != null) {
        setState(() {
          _songsList = updatedPlaylist['list'];
        });
      }
    }
  }

  void _updateSongsListOnRemove(int indexOfRemovedSong) {
    final dynamic songToRemove = _songsList.elementAt(indexOfRemovedSong);
    showToastWithButton(
      context,
      context.l10n!.songRemoved,
      context.l10n!.undo.toUpperCase(),
      () {
        addSongInCustomPlaylist(
          context,
          _playlist['title'],
          songToRemove,
          indexToInsert: indexOfRemovedSong,
        );
        _songsList.insert(indexOfRemovedSong, songToRemove);
        setState(() {});
      },
    );

    setState(() {
      _songsList.removeAt(indexOfRemovedSong);
    });
  }

  Widget _buildShuffleSongActionButton() {
    return IconButton(
      color: Theme.of(context).colorScheme.primary,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: const Icon(FluentIcons.arrow_shuffle_16_filled),
      iconSize: 25,
      onPressed: () {
        final _newList = List.of(_playlist['list'])..shuffle();
        setActivePlaylist({
          'title': _playlist['title'],
          'image': _playlist['image'],
          'list': _newList,
        });
      },
    );
  }

  Widget _buildSortSongActionButton() {
    return DropdownButton<String>(
      borderRadius: BorderRadius.circular(5),
      dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
      underline: const SizedBox.shrink(),
      iconEnabledColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      iconSize: 25,
      icon: const Icon(Hicons.filter3LightOutline),
      items:
          <String>[context.l10n!.name, context.l10n!.artist].map((
            String value,
          ) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
      onChanged: (item) {
        setState(() {
          final playlist = _playlist['list'];

          void sortBy(String key) {
            playlist.sort((a, b) {
              final valueA = a[key].toString().toLowerCase();
              final valueB = b[key].toString().toLowerCase();
              return valueA.compareTo(valueB);
            });
          }

          if (item == context.l10n!.name) {
            sortBy('title');
          } else if (item == context.l10n!.artist) {
            sortBy('artist');
          }

          _playlist['list'] = playlist;

          // Reset pagination and reload
          _hasMore = true;
          _songsList.clear();
          _currentPage = 0;
          _currentLastLoadedId = 0;
          _loadMore();
        });
      },
    );
  }

  Widget buildSongActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSortSongActionButton(),
        const SizedBox(width: 5),
        _buildShuffleSongActionButton(),
      ],
    );
  }

  Widget _buildSongListItem(int index, bool isRemovable) {
    if (index >= _songsList.length) {
      if (!_isLoading) {
        _loadMore();
      }
      return const Spinner();
    }

    final borderRadius = getItemBorderRadius(index, _songsList.length);

    return SongBar(
      _songsList[index],
      true,
      onRemove:
          isRemovable
              ? () => {
                if (removeSongFromPlaylist(
                  _playlist,
                  _songsList[index],
                  removeOneAtIndex: index,
                ))
                  {_updateSongsListOnRemove(index)},
              }
              : null,
      onPlay:
          () => {
            audioHandler.playPlaylistSong(
              playlist: activePlaylist != _playlist ? _playlist : null,
              songIndex: index,
            ),
          },
      isSongOffline: playlistOfflineStatus,
      borderRadius: borderRadius,
    );
  }
}
