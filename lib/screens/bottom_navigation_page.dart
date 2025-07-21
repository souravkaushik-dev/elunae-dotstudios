import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass/liquid_glass.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/services/settings_manager.dart';
import 'package:elunae/widgets/mini_player.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({required this.child, super.key});
  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  bool? _previousOfflineMode;
  final Set<int> _tappedIcons = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: offlineMode,
      builder: (context, isOfflineMode, _) {
        if (_previousOfflineMode != null &&
            _previousOfflineMode != isOfflineMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleOfflineModeChange(isOfflineMode);
          });
        }
        _previousOfflineMode = isOfflineMode;

        final items = _getNavigationItems(isOfflineMode);

        return SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: widget.child),
                  ],
                ),

                // Mini player
                StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem.distinct(_mediaItemEquals),
                  builder: (context, snapshot) {
                    final metadata = snapshot.data;
                    if (metadata == null) return const SizedBox.shrink();
                    return Positioned(
                      bottom: 115,
                      left: 16,
                      right: 16,
                      child: MiniPlayer(metadata: metadata),
                    );
                  },
                ),

                // Custom nav bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 50, // Increased to float above nav bar
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        double spaceWidth = totalWidth * 0.20;
                        double navBarWidth = totalWidth * 0.70;

                        return SizedBox(
                          height: 64,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSideNavItem(items[0], 0),
                              LiquidGlass(
                                opacity: 0.06,
                                borderRadius: BorderRadius.circular(30),
                                child: SizedBox(
                                  height: 64,
                                  width: navBarWidth,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: List.generate(
                                      items.length - 1,
                                          (i) =>
                                          _buildCenterNavItem(items[i + 1], i + 1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideNavItem(_NavigationItem item, int index) {
    final selected = widget.child.currentIndex == item.shellIndex;
    final tapped = _tappedIcons.contains(index);

    return GestureDetector(
      onTap: () => _onTabTapped(index, _getNavigationItems(offlineMode.value)),
      child: AnimatedScale(
        scale: tapped ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: LiquidGlass(
          opacity: 0.06,
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            height: 64,
            width: MediaQuery.of(context).size.width * 0.20,
            child: Icon(
              selected ? item.selectedIcon : item.icon,
              size: 22,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : _getUnselectedIconColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(_NavigationItem item, int index) {
    final selected = widget.child.currentIndex == item.shellIndex;
    final tapped = _tappedIcons.contains(index);

    return GestureDetector(
      onTap: () => _onTabTapped(index, _getNavigationItems(offlineMode.value)),
      child: AnimatedScale(
        scale: tapped ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Icon(
          selected ? item.selectedIcon : item.icon,
          size: 22,
          color: selected
              ? Theme.of(context).colorScheme.primary
              : _getUnselectedIconColor(context),
        ),
      ),
    );
  }

  List<_NavigationItem> _getNavigationItems(bool isOfflineMode) {
    final items = <_NavigationItem>[
      _NavigationItem(
        icon: Hicons.home2LightOutline,
        selectedIcon: Hicons.home2Bold,
        label: context.l10n?.home ?? 'Home',
        route: '/home',
        index: 0,
      ),
    ];

    if (!isOfflineMode) {
      items.add(_NavigationItem(
        icon: Hicons.search2LightOutline,
        selectedIcon: Hicons.search2Bold,
        label: context.l10n?.search ?? 'Search',
        route: '/search',
        index: 1,
      ));
    }

    final libraryIndex = isOfflineMode ? 1 : 2;
    final settingsIndex = isOfflineMode ? 2 : 3;

    items.addAll([
      _NavigationItem(
        icon: Hicons.folder2LightOutline,
        selectedIcon: Hicons.folder2Bold,
        label: context.l10n?.library ?? 'Library',
        route: '/library',
        index: libraryIndex,
      ),
      _NavigationItem(
        icon: Hicons.settingLightOutline,
        selectedIcon: Hicons.settingBold,
        label: context.l10n?.settings ?? 'Settings',
        route: '/settings',
        index: settingsIndex,
      ),
    ]);

    return items;
  }

  void _handleOfflineModeChange(bool isOfflineMode) {
    if (!mounted) return;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    if (isOfflineMode && currentRoute.startsWith('/search')) {
      widget.child.goBranch(0);
    }
  }

  void _onTabTapped(int index, List<_NavigationItem> items) {
    HapticFeedback.lightImpact();
    setState(() {
      widget.child.goBranch(items[index].shellIndex);
      _tappedIcons.add(index);
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _tappedIcons.remove(index);
        });
      }
    });
  }

  Color _getUnselectedIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white60 : Colors.black45;
  }

  static bool _mediaItemEquals(MediaItem? prev, MediaItem? curr) {
    if (prev == curr) return true;
    if (prev == null || curr == null) return false;

    return prev.id == curr.id &&
        prev.title == curr.title &&
        prev.artist == curr.artist &&
        prev.artUri == curr.artUri;
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.index,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final int index;

  int get shellIndex {
    if (route == '/home') return 0;
    if (route == '/search') return 1;
    if (route == '/library') return 2;
    if (route == '/settings') return 3;
    return 0;
  }
}
