import 'dart:ui';

import 'package:elunae/screens/edit_name.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/screens/playlist_page.dart';
import 'package:elunae/services/settings_manager.dart';
import 'package:elunae/utilities/common_variables.dart';
import 'package:elunae/utilities/utils.dart';
import 'package:elunae/widgets/playlist_cube.dart';
import 'package:elunae/widgets/section_header.dart';
import 'package:elunae/widgets/song_bar.dart';
import 'package:elunae/widgets/spinner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  final List<String> _avatars = [
    'assets/avatars/boy.jpg',
    'assets/avatars/girl.webp',
    'assets/avatars/boy3.gif',
    'assets/avatars/girl2.avif',
    'assets/avatars/girl1.png',
    'assets/avatars/boy2.jpg',
    'assets/avatars/dance.gif',
    'assets/avatars/dance2.gif',
  ];

  String? _userName;
  int? _avatarIndex;

  @override
  void initState() {
    super.initState();
    _loadUserNameAndAvatar();
  }

  Future<void> _loadUserNameAndAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _avatarIndex = prefs.getInt('userAvatar') ?? 0;
    });
  }

  Future<void> _showAvatarPicker(TapDownDetails details) async {
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary.withOpacity(0.15); // Accent tinted blur
    final renderBox = context.findRenderObject() as RenderBox;
    final tapPosition = renderBox.globalToLocal(details.globalPosition);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: details.globalPosition.dx - 260,
          top: details.globalPosition.dy + 10,
          child: Material(
            color: Colors.transparent,
            child: AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: _avatars.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('userAvatar', index);
                              setState(() {
                                _avatarIndex = index;
                              });
                              HapticFeedback.selectionClick();
                              entry.remove();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                _avatars[index],
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),

                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    // Optional auto dismiss after a while
    await Future.delayed(const Duration(seconds: 6));
    if (entry.mounted) entry.remove();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSuggestedPlaylists(),
                _buildLikedPlaylists(),
                _buildRecommendedSongsAndArtists(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
          final roundedCorner = isCollapsed ? 20.0 : 30.0;

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 10.0, bottom: 30.0, right: 10.0),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                          alignment: Alignment.centerLeft,
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: () async {
                          final newName = await showDialog<String>(
                            context: context,
                            builder: (context) => EditNameDialog(currentName: _userName ?? 'Guest'),
                          );

                          if (newName != null && newName.trim().isNotEmpty) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('userName', newName.trim());
                            setState(() {
                              _userName = newName.trim();
                            });
                            HapticFeedback.lightImpact();
                          }
                        },
                        child: Text(
                          _userName == 'Guest' || _userName == null ? 'Elunian' : _userName!,
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: 'displaymedium',
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Welcome to the resonance',
                        style: TextStyle(
                          fontFamily: 'thin',
                          fontSize: 14.0,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: GestureDetector(
                    onTapDown: _showAvatarPicker,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _avatarIndex != null
                          ? Image.asset(
                        _avatars[_avatarIndex!],
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 38,
                        height: 38,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            background: Stack(
              children: [
                if (isCollapsed)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(roundedCorner)),
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }
  }
  Widget _buildSuggestedPlaylists() {
    return FutureBuilder<List<dynamic>>(
      future: getPlaylists(playlistsNum: recommendedCubesNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          logger.log('Error in _buildSuggestedPlaylists', snapshot.error, snapshot.stackTrace);
          return _buildErrorWidget(context);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildPlaylistSection(context, snapshot.data!);
      },
    );
  }

  Widget _buildLikedPlaylists() {
    return FutureBuilder<List<dynamic>>(
      future: getPlaylists(playlistsNum: recommendedCubesNumber, onlyLiked: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          logger.log('Error in _buildLikedPlaylists', snapshot.error, snapshot.stackTrace);
          return _buildErrorWidget(context);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildPlaylistSection(
          context,
          snapshot.data!,
          titleOverride: context.l10n!.backToFavorites,
        );
      },
    );
  }

  Widget _buildPlaylistSection(
      BuildContext context,
      List<dynamic> playlists, {
        String? titleOverride,
      }) {
    final playlistHeight = MediaQuery.sizeOf(context).height * 0.25 / 1.1;
    final itemCount = playlists.length.clamp(0, recommendedCubesNumber);

    return Column(
      children: [
        _buildSectionHeader(
          title: Text(
            titleOverride ?? context.l10n!.suggestedPlaylists,
            style: const TextStyle(
              fontFamily: 'thin',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: playlistHeight),
          child: CarouselView.weighted(
            flexWeights: const <int>[3, 2, 1],
            onTap: (index) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistPage(
                  playlistId: playlists[index]['ytid'],
                ),
              ),
            ),
            children: List.generate(itemCount, (index) {
              return PlaylistCube(
                playlists[index],
                size: playlistHeight,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongsAndArtists() {
    return ValueListenableBuilder<bool>(
      valueListenable: defaultRecommendations,
      builder: (_, recommendations, __) {
        return FutureBuilder<dynamic>(
          future: getRecommendedSongs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.log('Error in _buildRecommendedSongsAndArtists', snapshot.error, snapshot.stackTrace);
                return _buildErrorWidget(context);
              } else if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return _buildRecommendedContent(
                context: context,
                data: snapshot.data,
                showArtists: !recommendations,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildRecommendedContent({
    required BuildContext context,
    required List<dynamic> data,
    bool showArtists = true,
  }) {
    final contentHeight = MediaQuery.sizeOf(context).height * 0.25;
    final itemCount = data.length.clamp(0, recommendedCubesNumber);

    return Column(
      children: [
        if (showArtists)
          _buildSectionHeader(
            title: const Text(
              'elunae fav',
              style: TextStyle(fontFamily: 'thin', fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        if (showArtists)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: contentHeight),
            child: CarouselView.weighted(
              flexWeights: const <int>[3, 2, 1],
              onTap: (index) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(
                    cubeIcon: Hicons.headphone2LightOutline,
                    playlistId: data[index]['artist'].split('~')[0],
                    isArtist: true,
                  ),
                ),
              ),
              children: List.generate(itemCount, (index) {
                final artist = data[index]['artist'].split('~')[0];
                return PlaylistCube(
                  {'title': artist},
                  cubeIcon: Hicons.headphone2LightOutline,
                );
              }),
            ),
          ),
        _buildSectionHeader(
          title: const Text(
            'Discover More',
            style: TextStyle(fontFamily: 'thin', fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actionButton: IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: () {
              setActivePlaylist({
                'title': 'DISCOVER MORE',
                'list': data,
              });
            },
            icon: Icon(
              HugeIcons.strokeRoundedUnfoldMore,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          padding: commonListViewBottmomPadding,
          itemBuilder: (context, index) {
            final borderRadius = getItemBorderRadius(index, data.length);
            return SongBar(data[index], true, borderRadius: borderRadius);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Spinner(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        '${context.l10n!.error}!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required Text title, Widget? actionButton}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
