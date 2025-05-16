import 'dart:async';
import 'package:flutter/material.dart';
import '../../presentation/widgets/update_dialog.dart';
import '../services/toast_service.dart';
import '../update/update_source_manager.dart';
import 'update_service.dart';

class UpdateChecker {
  static bool isDialogShowing = false;
  static bool hasShownDialogThisSession = false;

  static Future<void> initialize(BuildContext context, UpdateSourceManager sourceManager) async {
    ToastService.initialize(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.run(() async {
        await _checkForUpdates(context, sourceManager);
      });
    });
  }

  static Future<void> _checkForUpdates(BuildContext context, UpdateSourceManager sourceManager) async {
    if (isDialogShowing || hasShownDialogThisSession) return;

    try {
      isDialogShowing = true;
      final updateInfo = await UpdateService.checkForUpdates(sourceManager);

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

  static Future<void> checkForUpdatesManually(BuildContext context, UpdateSourceManager sourceManager) async {
    if (isDialogShowing) return;
    isDialogShowing = true;

    try {
      ToastService.showInfoToast('正在检查更新...');

      final updateInfo = await UpdateService.checkForUpdates(sourceManager);
      debugPrint('更新检查结果: $updateInfo');

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
          if (updateInfo != null) {
            ToastService.showSuccessToast(
                '您当前使用的已经是最新版本 (${updateInfo['currentVersion']})'
            );
          } else {
            ToastService.showWarningToast('无法获取更新信息，请稍后再试');
          }
          isDialogShowing = false;
        }
      }
    } catch (e, stack) {
      debugPrint('手动检查更新出错: $e');
      debugPrint('异常堆栈: $stack');
      isDialogShowing = false;
      if (context.mounted) {
        ToastService.showErrorToast('检查更新失败: $e');
      }
    }
  }
}