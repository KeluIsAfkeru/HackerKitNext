import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.8)
        : Colors.black.withOpacity(0.3);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: shadowColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 58,
                      color: theme.colorScheme.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms).scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack),

                    const SizedBox(height: 28),

                    Text(
                      '功能开发中',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack),

                    const SizedBox(height: 16),

                    Text(
                      '我们正在努力打造更多精彩功能，敬请期待！\n您可以先使用已有的功能开始体验。',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: (0.7 * 255)),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 320.ms)
                        .slideY(begin: 0.22, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 32),

                    FilledButton.tonal(
                      onPressed: () {
                        //先尝试pop，如果不能pop则跳首页
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/'); //使用go_router跳首页
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          backgroundColor: theme.colorScheme.primaryContainer
                      ),
                      child: Text(
                        '返回首页',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 500.ms)
                        .slideY(begin: 0.18, end: 0, curve: Curves.easeOut),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 80.ms)
                  .slideY(begin: 0.10, end: 0, curve: Curves.easeOutSine),
            ),
          ),
        ),
      ),
    );
  }
}