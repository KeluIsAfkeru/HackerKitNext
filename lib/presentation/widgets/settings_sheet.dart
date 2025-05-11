import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/toast_service.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/services/update_checker.dart'; 

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _isCheckingForUpdates = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeModeProvider>(context);

    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '基本设置',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.surfaceContainerLowest,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.brightness_6_rounded, color: theme.colorScheme.primary),
                    title: Text(
                      '暗色主题',
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        themeProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                    onTap: () {
                      themeProvider.setThemeMode(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                  const Divider(height: 1),

                  //检查更新选项
                  ListTile(
                    leading: Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
                    title: Text(
                      '检查更新',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      '查看是否有新版本可用',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: _isCheckingForUpdates
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    )
                        : Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: _isCheckingForUpdates
                        ? null
                        : () async {
                      setState(() {
                        _isCheckingForUpdates = true;
                      });

                      try {
                        await UpdateChecker.checkForUpdatesManually(context);
                      } catch (e) {
                        if (context.mounted) {
                          ToastService.showErrorToast('检查更新失败: $e');
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isCheckingForUpdates = false;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }
}
