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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
        if (_previousOfflineMode != null && _previousOfflineMode != isOfflineMode) {
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
                Column(children: [Expanded(child: widget.child)]),

                // Mini player
                StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem.distinct(_mediaItemEquals),
                  builder: (context, snapshot) {
                    final metadata = snapshot.data;
                    if (metadata == null) return const SizedBox.shrink();
                    return Positioned(
                      bottom: 130,
                      left: 16,
                      right: 16,
                      child: MiniPlayer(metadata: metadata),
                    );
                  },
                ),

                // iOS 26-style nav bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemsList = _getNavigationItems(offlineMode.value);
                        final homeItem = itemsList[0];
                        final groupedItems = itemsList.sublist(1); // search, library, settings

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildFloatingSideButton(homeItem, 0),
                            const SizedBox(width: 12),

                            // Grouped glass pill nav
                            LiquidGlass(
                              opacity: 0.08,
                              blur: 30,
                              borderRadius: BorderRadius.circular(40),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    groupedItems.length,
                                        (i) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: _buildCenterNavItem(groupedItems[i], i + 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildFloatingSideButton(_NavigationItem item, int index) {
    final selected = widget.child.currentIndex == item.shellIndex;
    final tapped = _tappedIcons.contains(index);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => _onTabTapped(index, _getNavigationItems(offlineMode.value)),
      child: AnimatedScale(
        scale: tapped ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          height: 64, // Match center nav bar
          constraints: const BoxConstraints(minWidth: 70), // Wider for balance
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
          ),
          child: LiquidGlass(
            blur: 30,
            opacity: 0.10,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 20,
                      color: selected ? primaryColor : _getUnselectedIconColor(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: selected ? primaryColor : _getUnselectedIconColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildCenterNavItem(_NavigationItem item, int index) {
    final selected = widget.child.currentIndex == item.shellIndex;
    final tapped = _tappedIcons.contains(index);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => _onTabTapped(index, _getNavigationItems(offlineMode.value)),
      child: selected
          ? LiquidGlass(
        opacity: 0.15,
        blur: 30,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: _buildAnimatedIconLabel(item, selected, tapped, primaryColor),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: _buildAnimatedIconLabel(item, selected, tapped, primaryColor),
      ),
    );
  }

  Widget _buildAnimatedIconLabel(
      _NavigationItem item, bool selected, bool tapped, Color primaryColor) {
    final iconColor = selected ? primaryColor : _getUnselectedIconColor(context);
    final labelColor = selected ? primaryColor : _getUnselectedIconColor(context);

    return AnimatedScale(
      scale: tapped ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? item.selectedIcon : item.icon,
            size: 20,
            color: iconColor,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
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
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
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
    switch (route) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/library':
        return 2;
      case '/settings':
        return 3;
      default:
        return 0;
    }
  }
}
