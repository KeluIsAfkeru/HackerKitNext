import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/update/update_source.dart';

//根据系统代理状态自动选择更新源，讲人话就是你开了代理就走github，没开就走gitee
class AutoSourceByProxy extends UpdateSource {
  final UpdateSource giteeSource;
  final UpdateSource githubSource;
  final bool Function() proxyChecker;

  AutoSourceByProxy({
    required this.giteeSource,
    required this.githubSource,
    required this.proxyChecker,
  });

  @override
  String get id => 'auto';

  @override
  String get name => '自动选择';

  @override
  IconData get icon => Icons.auto_awesome;

  //根据代理状态返回适当的源
  UpdateSource get _actualSource =>
      proxyChecker() ? githubSource : giteeSource;

  @override
  String getLatestReleaseUrl() => _actualSource.getLatestReleaseUrl();

  @override
  String getAllReleasesUrl() => _actualSource.getAllReleasesUrl();

  @override
  Map<String, dynamic>? parseReleaseData(String responseBody) =>
      _actualSource.parseReleaseData(responseBody);
}