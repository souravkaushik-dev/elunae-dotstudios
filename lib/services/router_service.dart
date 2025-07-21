/*🔧 Under Design · DotStudios*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:elunae/API/version.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/screens/about_page.dart';
import 'package:elunae/screens/bottom_navigation_page.dart';
import 'package:elunae/screens/home_page.dart';
import 'package:elunae/screens/library_page.dart';
import 'package:elunae/screens/search_page.dart';
import 'package:elunae/screens/settings_page.dart';
import 'package:elunae/screens/splash_new.dart'; // ✅ import your splash screen
import 'package:elunae/screens/user_songs_page.dart';
import 'package:elunae/services/settings_manager.dart';

class NavigationManager {
  factory NavigationManager() {
    return _instance;
  }

  NavigationManager._internal() {
    _setupRouter();
  }

  void _setupRouter() {
    final routes = [
      /// ✅ Splash screen as the first route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      /// ✅ Main app wrapped in bottom nav using StatefulShellRoute
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: parentNavigatorKey,
        branches: _getRouteBranches(),
        pageBuilder: (context, state, navigationShell) {
          return getPage(
            child: BottomNavigationPage(child: navigationShell),
            state: state,
          );
        },
      ),
    ];

    router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: '/', // ✅ Splash screen is now first
      routes: routes,
      restorationScopeId: 'router',
      debugLogDiagnostics: kDebugMode,
      routerNeglect: true,
      redirect: (context, state) {
        // Handle offline mode redirects
        final isOffline = offlineMode.value;
        final currentPath = state.matchedLocation;

        if (isOffline && currentPath == searchPath) {
          return homePath;
        }

        return null;
      },
    );
  }

  static final NavigationManager _instance = NavigationManager._internal();

  static NavigationManager get instance => _instance;

  static late final GoRouter router;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> searchTabNavigatorKey =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> libraryTabNavigatorKey =
  GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> settingsTabNavigatorKey =
  GlobalKey<NavigatorState>();

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String homePath = '/home';
  static const String settingsPath = '/settings';
  static const String searchPath = '/search';
  static const String libraryPath = '/library';

  /// Force router to re-evaluate when offline mode changes
  static void refreshRouter() {
    router.refresh();
  }

  List<StatefulShellBranch> _getRouteBranches() {
    return [
      // 🔹 Branch 0: Home
      StatefulShellBranch(
        navigatorKey: homeTabNavigatorKey,
        routes: [
          GoRoute(
            path: homePath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: ValueListenableBuilder<bool>(
                  valueListenable: offlineMode,
                  builder: (context, isOffline, _) {
                    return isOffline
                        ? const UserSongsPage(page: 'offline')
                        : const HomePage();
                  },
                ),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: 'library',
                builder: (context, state) => const LibraryPage(),
              ),
            ],
          ),
        ],
      ),

      // 🔹 Branch 1: Search
      StatefulShellBranch(
        navigatorKey: searchTabNavigatorKey,
        routes: [
          GoRoute(
            path: searchPath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(
                child: ValueListenableBuilder<bool>(
                  valueListenable: offlineMode,
                  builder: (context, isOffline, _) {
                    return isOffline
                        ? const _OfflineSearchPlaceholder()
                        : const SearchPage();
                  },
                ),
                state: state,
              );
            },
          ),
        ],
      ),

      // 🔹 Branch 2: Library
      StatefulShellBranch(
        navigatorKey: libraryTabNavigatorKey,
        routes: [
          GoRoute(
            path: libraryPath,
            pageBuilder: (context, GoRouterState state) {
              return getPage(child: const LibraryPage(), state: state);
            },
            routes: [
              GoRoute(
                path: 'userSongs/:page',
                builder: (context, state) {
                  return UserSongsPage(
                    page: state.pathParameters['page'] ?? 'liked',
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // 🔹 Branch 3: Settings
      StatefulShellBranch(
        navigatorKey: settingsTabNavigatorKey,
        routes: [
          GoRoute(
            path: settingsPath,
            pageBuilder: (context, state) {
              return getPage(child: const SettingsPage(), state: state);
            },
            routes: [
              GoRoute(
                path: 'license',
                builder: (context, state) => const LicensePage(
                  applicationName: 'elunae',
                  applicationVersion: appVersion,
                ),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static Page getPage({required Widget child, required GoRouterState state}) {
    return MaterialPage(key: state.pageKey, child: child);
  }
}

class _OfflineSearchPlaceholder extends StatelessWidget {
  const _OfflineSearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n!.search)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n!.error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
