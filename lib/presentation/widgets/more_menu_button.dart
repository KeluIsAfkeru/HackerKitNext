import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerkit_next/core/constants/app_icons.dart';
import 'about_sheet.dart';
import 'settings_sheet.dart';

class MoreMenuButton extends StatelessWidget {
  const MoreMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      offset: const Offset(0, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        AppIcons.more,
        color: theme.colorScheme.onSurface,
      ),
      elevation: 2,
      position: PopupMenuPosition.under,
      color: theme.colorScheme.surface,
      itemBuilder: (context) => [
        _buildPopupItem(context, 'home', AppIcons.home, '主页'),
        _buildPopupItem(context, 'about', AppIcons.about, '关于'),
        _buildPopupItem(context, 'settings', AppIcons.settings, '设置'),
      ],
      onSelected: (value) {
        switch (value) {
          case 'home':
            context.go('/');
            break;
          case 'about':
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AboutSheet(),
            );
            break;
          case 'settings':
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const SettingsSheet(),
            );
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _buildPopupItem(
      BuildContext context,
      String value,
      IconData icon,
      String text
      ) {
    final theme = Theme.of(context);

    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}