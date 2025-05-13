import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerkit_next/config/router/page_container.dart';
import 'package:hackerkit_next/features/home/presentation/pages/home_page.dart';

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
              child: const PageContainer(currentPath: '/'),
            ),
          ),
          GoRoute(
            path: '/module/:viewType',
            pageBuilder: (context, state) {
              final viewType = state.pathParameters['viewType'] ?? '';
              final path = '/module/$viewType';

              return _buildTransitionPage(
                key: state.pageKey,
                child: PageContainer(currentPath: path),
              );
            },
          ),
          GoRoute(
            path: '/coming-soon',
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: const PageContainer(currentPath: '/coming-soon'),
            ),
          ),
        ],
      ),
    ],
  );


  //动画转场
  static CustomTransitionPage _buildTransitionPage({required LocalKey key, required Widget child}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuint,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
