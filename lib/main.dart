import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hackerkit_next/utils/proxy_detector.dart';
import 'package:http_proxy_override/http_proxy_override.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'package:hackerkit_next/core/theme/app_theme.dart';
import 'package:hackerkit_next/config/router/app_router.dart';
import 'package:hackerkit_next/core/services/update_checker.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';

import 'core/update/update_source_manager.dart';

bool _pagesPreloaded = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.initializeAppVersion(); //初始化应用版本

  //预加载所有页面
  if (!_pagesPreloaded) {
    _pagesPreloaded = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      AppRouter.preloadPages();
    });
  }

  final sourceManager = UpdateSourceManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
        ChangeNotifierProvider<UpdateSourceManager>.value(value: sourceManager),
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