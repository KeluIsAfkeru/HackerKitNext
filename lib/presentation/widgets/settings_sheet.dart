import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/toast_service.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/services/update_checker.dart';
import '../../core/update/update_source_manager.dart';

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
    final sourceManager = Provider.of<UpdateSourceManager>(context);

    bool isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //基本设置
              _buildSectionHeader(theme, '基本设置'),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.surfaceContainerLowest,
                child: ListTile(
                  leading: Icon(Icons.brightness_6_rounded, color: theme.colorScheme.primary),
                  title: Text('暗色主题', style: theme.textTheme.bodyLarge),
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
              ),

              //应用更新
              const SizedBox(height: 20),
              _buildSectionHeader(theme, '更新设置'),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.surfaceContainerLowest,
                child: Column(
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        title: Row(
                          children: [
                            Icon(Icons.cloud_sync, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '更新源',
                              style: theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '当前: ${sourceManager.currentSource.name}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: sourceManager.sources.length,
                              itemBuilder: (context, index) {
                                final source = sourceManager.sources[index];
                                final isSelected = sourceManager.currentSource.id == source.id;

                                return ChoiceChip(
                                  label: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      source.name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) => sourceManager.selectSource(index),
                                  avatar: Icon(source.icon, size: 18),
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                  ),
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  selectedColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    //检查更新按钮
                    ListTile(
                      leading: Icon(Icons.system_update_rounded, color: theme.colorScheme.primary),
                      title: Text('检查更新', style: theme.textTheme.bodyLarge),
                      subtitle: Text('查看是否有新版本可用', style: theme.textTheme.bodySmall),
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
                      onTap: _isCheckingForUpdates ? null : () => _checkForUpdates(sourceManager),
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
      ),
    );

  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Future<void> _checkForUpdates(UpdateSourceManager sourceManager) async {
    setState(() {
      _isCheckingForUpdates = true;
    });

    await Future.microtask(() => null);

    try {
      await UpdateChecker.checkForUpdatesManually(context, sourceManager);
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
  }
}