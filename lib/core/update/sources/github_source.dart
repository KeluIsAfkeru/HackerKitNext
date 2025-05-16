import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/update/update_source.dart';

//Github的更新源，继承更新资源接口
class GitHubSource extends UpdateSource {
  final String owner;
  final String repo;

  GitHubSource({required this.owner, required this.repo});

  @override
  String get id => 'github';

  @override
  String get name => 'GitHub';

  @override
  IconData get icon => Icons.code;

  @override
  String getLatestReleaseUrl() {
    return 'https://api.github.com/repos/$owner/$repo/releases/latest';
  }

  @override
  String getAllReleasesUrl() {
    return 'https://api.github.com/repos/$owner/$repo/releases';
  }

  @override
  Map<String, dynamic>? parseReleaseData(String responseBody) {
    try {
      //GitHub API返回单个release对象
      return json.decode(responseBody);
    } catch (e) {
      debugPrint('GitHub数据解析错误: $e');
      return null;
    }
  }
}