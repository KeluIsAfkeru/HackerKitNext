import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hackerkit_next/core/constants/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:hackerkit_next/models/category.dart';
import 'package:hackerkit_next/models/module.dart';

import '../../core/constants/app_constants.dart';

class ModernSidebar extends StatelessWidget {
  const ModernSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = Provider.of<HomeViewModel>(context);

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      width: AppConstants.sidebarWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: (0.05 * 255).toDouble()), //透明度
            blurRadius: 3, //模糊半径
            offset: const Offset(1, 0), //偏移
          ),
        ],
      ),
      child: Column(
        children: [
          //头像和信息
          _buildProfileHeader(context),

          const Divider(height: 1),

          //分类和模块列表
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: viewModel.categories
                  .map((category) => _buildCategorySection(context, category, viewModel))
                  .toList(),
            ),
          ),

          //版本信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: (0.7 * 255).toDouble()),
                ),
                const SizedBox(width: 8),
                Text(
                  AppConstants.appVersion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: (0.7 * 255).toDouble()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final Uint8List afkeruPfpBytes = base64Decode(AppIcons.afkeruPfp);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          //圆形头像
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
              radius: 24,
              backgroundColor: theme.colorScheme.surface,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: ClipOval(
                  child: Image.memory(
                    afkeruPfpBytes,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          //作者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appAuthor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.authorTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context,
      Category category,
      HomeViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final isExpanded = viewModel.isCategoryExpanded(category.id);


    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          //类别标题
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.moduleItemBorderRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => viewModel.toggleCategory(category.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (theme.colorScheme.secondary).withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: 250.ms,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //模块列表
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              children: category.modules.map((module) =>
                  _buildModuleItem(context, module, viewModel)
              ).toList(),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: 300.ms,
            sizeCurve: Curves.easeInOutCubicEmphasized,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(
      BuildContext context,
      Module module,
      HomeViewModel viewModel,
      ) {
    final theme = Theme.of(context);
    final isSelected = viewModel.isModuleSelected(module.id);

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, right: 4, bottom: 2),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            //选中模块
            viewModel.selectModule(module.id);

            //导航到模块页面
            if (module.items.isEmpty) {
              context.go('/coming-soon');
            } else {
              viewModel.selectModule(module.id);
              context.go('/module/${module.items.first.viewType}');
            }

            //在移动设备上自动折叠侧边栏
            if (MediaQuery.of(context).size.width < 1200) {
              viewModel.toggleSidebar();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  module.icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    module.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 200.ms, delay: 50.ms)
        .slideX(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOutCubic);
  }
}
