// core/services/update_checker.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../presentation/widgets/update_dialog.dart';
import '../services/toast_service.dart';
import 'update_service.dart';

class UpdateChecker {
  static bool isDialogShowing = false;
  static bool hasShownDialogThisSession = false;

  static Future<void> initialize(BuildContext context) async {
    ToastService.initialize(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.run(() async {
        await _checkForUpdates(context);
      });
    });
  }

  static Future<void> _checkForUpdates(BuildContext context) async {
    if (isDialogShowing || hasShownDialogThisSession) return;

    try {
      isDialogShowing = true;
      final updateInfo = await UpdateService.checkForUpdates();

      if (updateInfo != null && updateInfo['hasUpdate'] == true) {
        if (context.mounted) {
          hasShownDialogThisSession = true;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UpdateDialog(updateInfo: updateInfo),
          ).then((_) {
            isDialogShowing = false;
          });
        }
      } else {
        isDialogShowing = false;
      }
    } catch (e) {
      isDialogShowing = false;
      debugPrint('检查更新出错: $e');
    }
  }

  static Future<void> checkForUpdatesManually(BuildContext context) async {
    if (isDialogShowing) return;
    try {
      final updateInfo = await UpdateService.checkForUpdates();

      if (context.mounted) {
        if (updateInfo != null && updateInfo['hasUpdate'] == true) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => UpdateDialog(updateInfo: updateInfo),
          ).then((_) {
            isDialogShowing = false;
          });
        } else {
          ToastService.showSuccessToast('您当前使用的已经是最新版本');
          isDialogShowing = false;
        }
      }
    } catch (e) {
      isDialogShowing = false;
      if (context.mounted) {
        ToastService.showErrorToast('检查更新失败: $e');
      }
    }
  }
}