import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'package:http_proxy_override/http_proxy_override.dart';
import 'package:hackerkit_next/core/theme/app_theme.dart';
import 'package:hackerkit_next/config/router/app_router.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.initializeAppVersion();

  //获取系统代理设置
  //只在iOS和Android执行
  if (Platform.isAndroid || Platform.isIOS) {
    HttpProxyOverride? httpProxyOverride = await HttpProxyOverride.createHttpProxy();
    HttpOverrides.global = httpProxyOverride;
    if (httpProxyOverride.host != null && httpProxyOverride.port != null) {
      debugPrint('成功获取系统代理: ${httpProxyOverride.host}:${httpProxyOverride.port}');
    } else {
      debugPrint('未检测到系统代理或设备未配置代理');
    }
  } else {
    debugPrint('当前平台无需设置 HttpProxyOverride');
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