import 'package:flutter/material.dart';
import 'package:hackerkit_next/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hackerkit_next/features/text_encoding/presentation/pages/text_encoding_page.dart';
import 'package:hackerkit_next/features/coming_soon/presentation/pages/coming_soon_page.dart';
import '../../features/base_converter/presentation/pages/base_converter_page.dart';
import '../../features/binary_code_calculator/presentation/pages/binary_code_calculator_page.dart';
import '../../features/jwt_tool/presentation/pages/jwt_tool_page.dart';

class PageContainer extends StatefulWidget {
  final String currentPath;

  const PageContainer({
    super.key,
    required this.currentPath,
  });

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  //预初始化所有页面
  static final Map<String, Widget> _pageMap = {
    'dashboard': const DashboardPage(),
    'TextEncodingConverter': const TextEncodingPage(),
    'BaseConverter': const BaseConverterPage(),
    'BinaryCodeCalculator': const BinaryCodeCalculatorPage(),
    'JWTTool': const JwtToolPage(),
    'coming-soon': const ComingSoonPage(),
  };

  late String _viewType;

  @override
  void initState() {
    super.initState();
    _updateViewType();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadPageResources();
    });
  }

  void _preloadPageResources() {
    _pageMap.forEach((key, widget) {
      //图片资源需要预加载在着添加
    });
  }

  void _updateViewType() {
    if (widget.currentPath == '/') {
      _viewType = 'dashboard';
    } else if (widget.currentPath == '/coming-soon') {
      _viewType = 'coming-soon';
    } else if (widget.currentPath.startsWith('/module/')) {
      _viewType = widget.currentPath.substring('/module/'.length);
    } else {
      _viewType = 'coming-soon';
    }
  }

  @override
  void didUpdateWidget(PageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _updateViewType();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _pageMap[_viewType] ?? const ComingSoonPage();
  }
}