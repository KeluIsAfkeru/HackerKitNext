import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../models/category.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getOptimalColumnCount(constraints.maxWidth);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                      _buildCategoryCard(context, viewModel.categories[index]),
                  childCount: viewModel.categories.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
            ),
          ],
        );
      },
    );
  }

  int _getOptimalColumnCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎使用',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 700.ms, delay: 100.ms),
          const SizedBox(height: 6),
          Text(
            AppConstants.appName,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.5,
              height: 1.1,
            ),
          ).animate().fadeIn(duration: 700.ms, delay: 300.ms),
          const SizedBox(height: 14),
          Text(
            '选择以下工具分类开始使用',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ).animate().fadeIn(duration: 700.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    final shadowColor = isDark
        ? Colors.black.withOpacity(0.8)
        : Colors.black.withOpacity(0.5);

    final iconBackgroundColor = theme.colorScheme.surfaceContainer.withOpacity(0.05);
    final iconColor = theme.colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (category.modules.length == 1) {
            final module = category.modules[0];
            viewModel.selectModule(module.id);
            context.go('/module/${module.items[0].viewType}');
            if (MediaQuery.of(context).size.width < 1200) {
              viewModel.toggleSidebar();
            }
          } else {
            viewModel.expandCategory(category.id);
          }
        },
        child: Card(
          color: cardColor,
          elevation: 12,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          surfaceTintColor: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: iconColor.withOpacity(0.12),
            highlightColor: iconColor.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      category.icon,
                      size: 40,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    category.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${category.modules.length} 个工具',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }

}
