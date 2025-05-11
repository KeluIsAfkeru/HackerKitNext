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

  //UI配置
  static const double sidebarWidth = 280.0;
  static const double appBarHeight = 64.0;
  static const double cardBorderRadius = 20.0;
  static const double moduleItemBorderRadius = 12.0;

  //动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOutCubicEmphasized;

  static bool hasProxy = false; // 是否存在系统带来，默认使用Gitee API，为true则使用GitHub
  //GitHub仓库
  static const String githubRepoOwner = 'KeluIsAfkeru';
  static const String githubRepoName = 'HackerKitNext';
  //Gitee仓库
  static const String giteeRepoOwner = 'Afkeru';
  static const String giteeRepoName = 'hacker-kit-next_-release';

  //取当前应用版本号和构建号
  static Future<void> initializeAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    appBuildNumber = packageInfo.buildNumber;
  }

  //动态获取APIURL的getter
  static String get apiReleasesUrl {
    if (hasProxy) {
      //GitHub API
      return 'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases';
    } else {
      //Gitee API
      return 'https://gitee.com/api/v5/repos/$giteeRepoOwner/$giteeRepoName/releases';
    }
  }

  //获取最新版本的URL
  static String get latestReleaseUrl {
    if (hasProxy) {
      //GitHub提供/latest端点
      return '$apiReleasesUrl/latest';
    } else {
      //Gitee需要获取列表并取第一个
      return '$apiReleasesUrl?page=1&per_page=1&direction=desc';
    }
  }
}