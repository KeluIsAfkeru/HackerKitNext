import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerkit_next/features/home/presentation/pages/home_page.dart';
import 'package:hackerkit_next/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hackerkit_next/features/coming_soon/presentation/pages/coming_soon_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/module/:viewType',
            pageBuilder: (context, state) {
              final viewType = state.pathParameters['viewType'] ?? '';
              final page = _getModulePage(viewType);

              if (page != null) {
                return _buildTransitionPage(
                  key: state.pageKey,
                  child: page,
                );
              }

              //fallback
              return _buildTransitionPage(
                key: state.pageKey,
                child: const SizedBox.shrink(),
              );
            },
            redirect: (context, state) {
              final viewType = state.pathParameters['viewType'] ?? '';
              final page = _getModulePage(viewType);
              if (page == null) {
                return '/coming-soon';
              }
              return null;
            },
          ),
          GoRoute(
            path: '/coming-soon',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const ComingSoonPage(),
            ),
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => _buildTransitionPage(
      key: state.pageKey,
      child: const ComingSoonPage(),
    ),
  );

  //动画转场
  static CustomTransitionPage _buildTransitionPage({required LocalKey key, required Widget child}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 340),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  //根据viewType返回对应模块页面Widget，找不到返回null
  static Widget? _getModulePage(String viewType) {
    switch (viewType) {
      case 'coming-soon':
        return const ComingSoonPage();
      default:
        return null;
    }
  }
}