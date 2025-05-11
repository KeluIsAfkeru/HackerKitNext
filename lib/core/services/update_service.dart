import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';

class UpdateService {
  //检查更新
  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      final currentVersionString = AppConstants.appVersion;
      debugPrint('应用当前版本: $currentVersionString');

      Version? currentVersion;
      try {
        currentVersion = Version.parse(currentVersionString);
      } catch (e) {
        debugPrint('当前版本号解析错误: $e');
        return null;
      }

      //根据hasProxy使用不同的API端点
      final response = await http.get(
        Uri.parse(AppConstants.latestReleaseUrl),
        headers: {'Content-Type': 'application/json;charset=UTF-8'},
      );

      debugPrint('API响应状态码: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('获取releases失败: ${response.statusCode}');
        return null;
      }

      //根据不同API解析响应数据
      dynamic releaseData;
      if (AppConstants.hasProxy) {
        //GitHub API返回单个release对象
        releaseData = json.decode(response.body);
      } else {
        //Gitee API返回release数组
        final List<dynamic> releases = json.decode(response.body);
        if (releases.isEmpty) {
          debugPrint('没有找到任何发布版本');
          return null;
        }
        releaseData = releases[0]; //第一个为最新版本
      }

      debugPrint('远程release数据: $releaseData');

      final latestVersionString = releaseData['tag_name'] as String? ?? '';
      debugPrint('远程版本tag: $latestVersionString');

      if (latestVersionString.isEmpty) {
        debugPrint('远程版本号为空');
        return null;
      }

      final latestVersionClean = latestVersionString.startsWith('v')
          ? latestVersionString.substring(1)
          : latestVersionString;

      Version? latestVersion;
      try {
        latestVersion = Version.parse(latestVersionClean);
      } catch (e) {
        debugPrint('远程版本号解析错误: $e');
        return null;
      }

      final hasUpdate = latestVersion > currentVersion;
      debugPrint('版本比较结果: $latestVersion > $currentVersion = $hasUpdate');

      if (hasUpdate) {
        final downloadUrl = _getDownloadUrlForPlatform(releaseData);
        debugPrint('下载链接: $downloadUrl');
        return {
          'hasUpdate': true,
          'currentVersion': currentVersionString,
          'latestVersion': latestVersionClean,
          'releaseNotes': releaseData['body'] as String? ?? '没有提供更新说明',
          'downloadUrl': downloadUrl,
          'releaseData': releaseData,
        };
      } else {
        return {
          'hasUpdate': false,
          'currentVersion': currentVersionString,
          'latestVersion': latestVersionClean,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('检查更新时出错: $e');
      debugPrint('堆栈跟踪: $stackTrace');
      return null;
    }
  }


  //根据架构获取下载URL
  static String? _getDownloadUrlForPlatform(Map<String, dynamic> releaseData) {
    final assets = releaseData['assets'] as List<dynamic>? ?? [];

    String? assetPattern;

    if (Platform.isAndroid) {
      //根据CPU架构选择正确的APK
      String cpuArchitecture = _getCpuArchitecture();
      assetPattern = cpuArchitecture;
    } else if (Platform.isWindows) {
      assetPattern = 'windows';
    } else if (Platform.isLinux) {
      assetPattern = 'linux';
    } else if (Platform.isMacOS) {
      assetPattern = 'macos';
    }

    if (assetPattern != null) {
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.contains(assetPattern)) {
          return asset['browser_download_url'] as String?;
        }
      }
    }

    return null;
  }

  //获取CPU架构
  static String _getCpuArchitecture() {
    try {
      if (Platform.isAndroid) {
        if (Platform.version.contains('arm64')) {
          return 'arm64-v8a';
        } else if (Platform.version.contains('armeabi')) {
          return 'armeabi-v7a';
        } else if (Platform.version.contains('x86_64')) {
          return 'x86_64';
        }
      }
    } catch (e) {
      debugPrint('获取CPU架构错误: $e');
    }

    //默认返回arm64
    return 'arm64-v8a';
  }

  //获取下载目录路径
  static Future<String?> _getDownloadDirectoryPath() async {
    try {
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          //尝试获取标准下载目录
          final downloadDir = Directory('${directory.path}/../Download');
          if (await downloadDir.exists()) {
            return downloadDir.path;
          }
          return directory.path;
        }
      } else {
        //其他平台尝试获取下载目录
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          return directory.path;
        }
      }
    } catch (e) {
      debugPrint('获取下载目录出错: $e');
    }
    return null;
  }

  //下载并安装更新
  static Future<void> downloadAndInstallUpdate(
      String url,
      void Function(double progress) onProgress,
      VoidCallback onSuccess,
      Function(String error) onError
      ) async {
    try {
      //获取合适的下载目录
      final String? downloadDir = await _getDownloadDirectoryPath();
      final String fileName = url.split('/').last;
      String filePath;

      if (downloadDir != null) {
        filePath = '$downloadDir/$fileName';
      } else {
        //如果无法获取下载目录，则使用临时目录
        final tempDir = await getTemporaryDirectory();
        filePath = '${tempDir.path}/$fileName';
      }

      //下载文件
      Dio dio = Dio(BaseOptions(
        validateStatus: (_) => true,
      ));

      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            onProgress(progress);
          }
        },
      );

      //下载完成，处理安装或打开
      if (Platform.isAndroid) {
        //调用onSuccess关闭进度对话框
        onSuccess();

        try {
          //安装APK，支持新旧Android版本
          final flutterAppInstaller = FlutterAppInstaller();
          await flutterAppInstaller.installApk(
            filePath: filePath,
          );
        } catch (e) {
          debugPrint('安装APK失败，尝试其他方法: $e');

          try {
            await _openFileDirectory();
          } catch (e2) {
            debugPrint('所有安装方法都失败: $e2');
            await _openFileDirectory();
          }
        }
      } else {
        //其他平台打开文件目录
        onSuccess();
        await _openFileDirectory();
      }
    } catch (e) {
      onError('下载或安装更新时出错: $e');
    }
  }

  //打开文件管理器/目录
  static Future<void> _openFileDirectory() async {
    try {
      if (Platform.isAndroid) {
        //Android打开下载目录
        openFileManager(
          androidConfig: AndroidConfig(
            folderType: AndroidFolderType.download,
          ),
        );
      } else if (Platform.isMacOS) {
        //macOS使用open_file_manager
        openFileManager();
      } else {
        //其他平台使用默认设置
        openFileManager();
      }
    } catch (e) {
      debugPrint('打开文件管理器失败: $e');
    }
  }
}

//保留此函数以向后兼容
Future<void> downloadAndInstallApk(
    String url,
    void Function(double) onProgress,
    VoidCallback onSuccess,
    Function(String) onError,
    ) async {
  await UpdateService.downloadAndInstallUpdate(url, onProgress, onSuccess, onError);
}
