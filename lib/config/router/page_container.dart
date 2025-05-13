import 'package:flutter/material.dart';
import 'package:hackerkit_next/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hackerkit_next/features/text_encoding/presentation/pages/text_encoding_page.dart';
import 'package:hackerkit_next/features/coming_soon/presentation/pages/coming_soon_page.dart';

class PageContainer extends StatelessWidget {
  final String currentPath;

  const PageContainer({
    super.key,
    required this.currentPath,
  });

  static final Map<String, Widget> _pageMap = {
    'dashboard': const DashboardPage(),
    'TextEncodingConverter': const TextEncodingPage(),
    'coming-soon': const ComingSoonPage(),
  };

  @override
  Widget build(BuildContext context) {
    String viewType = '';

    if (currentPath == '/') {
      viewType = 'dashboard';
    } else if (currentPath == '/coming-soon') {
      viewType = 'coming-soon';
    } else if (currentPath.startsWith('/module/')) {
      viewType = currentPath.substring('/module/'.length);
    }

    return _pageMap[viewType] ?? const ComingSoonPage();
  }
}