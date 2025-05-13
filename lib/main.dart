import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_proxy_override/http_proxy_override.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'package:hackerkit_next/core/theme/app_theme.dart';
import 'package:hackerkit_next/config/router/app_router.dart';
import 'package:hackerkit_next/core/services/update_checker.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.initializeAppVersion();

  //只在Android或iOS上获取代理
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      HttpProxyOverride httpProxyOverride = await HttpProxyOverride.createHttpProxy();
      HttpOverrides.global = httpProxyOverride;
      if (httpProxyOverride.host != null && httpProxyOverride.host!.isNotEmpty) {
        debugPrint("\n成功获取本地代理: ${httpProxyOverride.host}:${httpProxyOverride.port}");
        AppConstants.hasProxy = true;
      }
    } catch (e) {
      debugPrint("获取系统代理出错: $e");
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
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