import 'package:flutter/animation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  //基本信息
  static const String appName = 'HackerKit';
  static String appVersion = '1.0.0';
  static String appBuildNumber = '0';
  static const String appAuthor = 'Afkeru';
  static const String appDescription = 'HackerKit是一款实现了跨平台、高颜值、实用的系列工具集合，无论你是开发者、技术爱好者，还是日常需要高效工具的用户，这里都能为你提供各种实用工具，一站式解决你的需求';
  static const String authorTitle = '一只独自追求明星的狼~';
  static bool hasProxy = false; //是否存在系统代理

  //UI配置
  static const double sidebarWidth = 280.0;
  static const double appBarHeight = 64.0;
  static const double cardBorderRadius = 20.0;
  static const double moduleItemBorderRadius = 12.0;

  //动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOutCubicEmphasized;

  //取当前应用版本号和构建号
  static Future<void> initializeAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = "1.0.0";
    appBuildNumber = packageInfo.buildNumber;
  }
}