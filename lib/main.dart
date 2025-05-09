import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hackerkit_next/config/router/app_router.dart';
import 'package:hackerkit_next/core/theme/app_theme.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';

import 'core/theme/theme_mode_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()), // 新加
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'HackerKit',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
