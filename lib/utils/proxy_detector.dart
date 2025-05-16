import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http_proxy_override/http_proxy_override.dart';

import '../core/constants/app_constants.dart';

class ProxyDetector {

  static Future<bool> hasSystemProxy() async {
    //只在Android或iOS上获取代理
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        HttpProxyOverride httpProxyOverride = await HttpProxyOverride.createHttpProxy();
        HttpOverrides.global = httpProxyOverride;
        if (httpProxyOverride.host != null && httpProxyOverride.host!.isNotEmpty) {
          debugPrint("\n成功获取本地代理: ${httpProxyOverride.host}:${httpProxyOverride.port}");
          AppConstants.hasProxy = true;
        }
      } catch (e) {
        debugPrint("获取系统代理出错: $e");
      }
    }

    debugPrint('未检测到系统代理');
    return false;
  }
}