import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/update/update_source.dart';

class GiteeSource extends UpdateSource {
  final String owner;
  final String repo;

  GiteeSource({required this.owner, required this.repo});

  @override
  String get id => 'gitee';

  @override
  String get name => 'Gitee';

  @override
  IconData get icon => Icons.cloud_outlined;

  @override
  String getLatestReleaseUrl() {
    return 'https://gitee.com/api/v5/repos/$owner/$repo/releases?page=1&per_page=1&direction=desc';
  }

  @override
  String getAllReleasesUrl() {
    return 'https://gitee.com/api/v5/repos/$owner/$repo/releases';
  }

  @override
  Map<String, dynamic>? parseReleaseData(String responseBody) {
    try {
      //Gitee API返回releases数组
      final List<dynamic> releases = json.decode(responseBody);
      if (releases.isEmpty) return null;
      return releases[0]; //第一个是最新版本
    } catch (e) {
      debugPrint('Gitee数据解析错误: $e');
      return null;
    }
  }
}