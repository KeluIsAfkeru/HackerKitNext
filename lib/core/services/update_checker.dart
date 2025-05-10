import 'dart:async';
import 'package:flutter/material.dart';
import '../../presentation/widgets/update_dialog.dart';
import 'update_service.dart';

class UpdateChecker {
  static bool isDialogShowing = false;
  //添加新的标志，记录当前会话中是否已显示过更新对话框
  static bool hasShownDialogThisSession = false;

  static Future<void> initialize(BuildContext context) async {
    //在后台线程检查更新，不阻塞主线程
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.run(() async {
        await _checkForUpdates(context);
      });
    });
  }

  static Future<void> _checkForUpdates(BuildContext context) async {
    //如果对话框正在显示或本次会话已经显示过则不再显示
    if (isDialogShowing || hasShownDialogThisSession) return;

    try {
      isDialogShowing = true;
      final updateInfo = await UpdateService.checkForUpdates();

      //有更新显示更新对话框
      if (updateInfo != null && updateInfo['hasUpdate'] == true) {
        if (context.mounted) {
          //标记本次会话已经显示过对话框
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
      //静默失败
      isDialogShowing = false;
      debugPrint('检查更新出错: $e');
    }
  }

  //手动检查更新方法
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
          //已经是最新版本提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('您当前使用的已经是最新版本'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          isDialogShowing = false;
        }
      }
    } catch (e) {
      isDialogShowing = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查更新失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
