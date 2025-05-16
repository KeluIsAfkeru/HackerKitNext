import 'package:flutter/material.dart';
import 'package:hackerkit_next/presentation/widgets/sponsor_card.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';
import 'package:hackerkit_next/core/constants/app_icons.dart';
import 'dart:typed_data';
import 'dart:convert';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Uint8List afkeruPfpBytes = base64Decode(AppIcons.afkeruPfp);
    final Uint8List admilkPfpBytes = base64Decode(AppIcons.admilkPfp);
    final Uint8List mapleLeafPfpBytes = base64Decode(AppIcons.mapleLeafPfp);
    final Uint8List dxPfpBytes = base64Decode(AppIcons.dxPfp);

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
            Container(
              height: 4,
              width: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //头像
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.surface,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: ClipOval(
                          child: Image.memory(
                            afkeruPfpBytes,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    AppConstants.appAuthor,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${AppConstants.appName} ${AppConstants.appVersion}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.3 : 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(isDark ? 0.1 : 0.05),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      AppConstants.appDescription,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //友情赞助
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "技术支持",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SponsorCard(
                          avatar: admilkPfpBytes,
                          name: "admilk",
                          description: "Node.js/Java/Python炼金术士\nBot大神",
                          theme: theme,
                        ),
                        SponsorCard(
                          avatar: mapleLeafPfpBytes,
                          name: "MapIeLeaf",
                          description: "在系统深喉与网络谜宫中游刃有余的现代嘿壳",
                          theme: theme,
                        ),
                        SponsorCard(
                          avatar: dxPfpBytes,
                          name: "DXiang",
                          description: "古希腊掌管单片机的神\n克鲁的好兄弟",
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
