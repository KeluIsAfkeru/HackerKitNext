import 'package:flutter/material.dart';

///ICON辅助类
class IconHelper {
  ///通过名称返回material icon的 icon data
  static IconData getIconByName(String name) {
    switch (name) {
      case 'Handyman':
        return Icons.handyman;
      case 'Code':
        return Icons.code;
      case 'Transform':
        return Icons.transform;
      case 'AttachFile':
        return Icons.attach_file;
      case 'DataObject':
        return Icons.data_object;
      case 'Translate':
        return Icons.translate;
      case 'SwapHoriz':
        return Icons.swap_horiz;
      case 'SwapCalls':
        return Icons.swap_calls;
      case 'Calculate':
        return Icons.calculate;
      case 'Key':
        return Icons.key;
      case 'VpnKey':
        return Icons.vpn_key;
      case 'Lock':
        return Icons.lock;
      case 'EnhancedEncryption':
        return Icons.enhanced_encryption;
      case 'Security':
        return Icons.security;
      case 'Fingerprint':
        return Icons.fingerprint;
      default:
        return Icons.circle;
    }
  }
}