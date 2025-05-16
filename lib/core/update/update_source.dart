import 'package:flutter/material.dart';

//更新资源接口，方便拓展
abstract class UpdateSource {
  String get id;

  String get name;

  IconData get icon;

  String getLatestReleaseUrl();

  String getAllReleasesUrl();

  Map<String, dynamic>? parseReleaseData(String responseBody);
}