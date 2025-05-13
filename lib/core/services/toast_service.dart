import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/services/toast_manager.dart';

import '../../models/toast_config.dart';
import '../../models/toast_gravity.dart';
import '../../models/toast_type.dart';

class ToastService {
  static BuildContext? _context;

  static void initialize(BuildContext context) {
    _context = context;
    ToastManager.initialize(context);
  }

  static void showToast({
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.top,
  }) {
    if (_context == null) {
      debugPrint('Warning: ToastService未初始化');
      return;
    }

    final theme = Theme.of(_context!);
    final isDark = theme.brightness == Brightness.dark;

    final ToastConfig config = _getToastConfig(type, theme, isDark);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: config.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: config.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              color: config.iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: config.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    ToastManager.showToast(
      toastWidget: toast,
      gravity: gravity,
      duration: duration,
    );
  }

  static ToastConfig _getToastConfig(ToastType type, ThemeData theme, bool isDark) {
    switch (type) {
      case ToastType.success:
        return ToastConfig(
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer.withOpacity(0.9),
          textColor: isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimaryContainer,
          icon: Icons.check_circle_outlined,
          iconColor: theme.colorScheme.primary,
          iconBgColor: isDark
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.1),
        );
      case ToastType.error:
        return ToastConfig(
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.errorContainer.withOpacity(0.9),
          textColor: isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onErrorContainer,
          icon: Icons.error_outline,
          iconColor: theme.colorScheme.error,
          iconBgColor: isDark
              ? theme.colorScheme.errorContainer.withOpacity(0.3)
              : theme.colorScheme.error.withOpacity(0.1),
        );
      case ToastType.warning:
        return ToastConfig(
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.secondaryContainer.withOpacity(0.9),
          textColor: isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSecondaryContainer,
          icon: Icons.warning_amber_outlined,
          iconColor: theme.colorScheme.secondary,
          iconBgColor: isDark
              ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
              : theme.colorScheme.secondary.withOpacity(0.1),
        );
      default: // info
        return ToastConfig(
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.tertiaryContainer.withOpacity(0.9),
          textColor: isDark
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onTertiaryContainer,
          icon: Icons.info_outline_rounded,
          iconColor: theme.colorScheme.tertiary,
          iconBgColor: isDark
              ? theme.colorScheme.tertiaryContainer.withOpacity(0.3)
              : theme.colorScheme.tertiary.withOpacity(0.1),
        );
    }
  }

  //简化API
  static void showSuccessToast(String message) {
    showToast(message: message, type: ToastType.success);
  }

  static void showErrorToast(String message) {
    showToast(message: message, type: ToastType.error);
  }

  static void showInfoToast(String message) {
    showToast(message: message, type: ToastType.info);
  }

  static void showWarningToast(String message) {
    showToast(message: message, type: ToastType.warning);
  }

  //移除所有显示的Toast
  static void removeAllToasts() {
    ToastManager.removeAllToasts();
  }
}