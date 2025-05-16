import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:hackerkit_next/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:hackerkit_next/presentation/widgets/modern_sidebar.dart';
import 'package:hackerkit_next/presentation/widgets/more_menu_button.dart';
import '../../../../config/router/app_router.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/services/update_checker.dart';
import '../../../../core/update/update_source_manager.dart';
import '../../../../utils/proxy_detector.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuart,
      ),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  void _syncSidebarAnim(bool expanded) {
    if (expanded && _controller.status != AnimationStatus.forward) {
      _controller.forward();
    } else if (!expanded && _controller.status != AnimationStatus.reverse) {
      _controller.reverse();
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _syncSidebarAnim(viewModel.isSidebarExpanded);

      if (mounted) {
        final sourceManager = Provider.of<UpdateSourceManager>(context, listen: false);

        //检查系统代理状态
        final hasProxy = await ProxyDetector.hasSystemProxy();
        sourceManager.hasProxy = hasProxy;

        //加载保存的更新源设置
        await sourceManager.loadSavedSelection();
        UpdateChecker.initialize(context, sourceManager);
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    _syncSidebarAnim(viewModel.isSidebarExpanded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            //主内容
            Positioned.fill(
              child: Column(
                children: [
                  _buildAppBar(context, viewModel),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),

            if (isMobile)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !viewModel.isSidebarExpanded,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => viewModel.toggleSidebar(),
                      child: Container(
                        color: Colors.black.withOpacity(_fadeAnimation.value * 0.5),
                      ),
                    ),
                  ),
                ),
              ),

            //侧边栏
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: _slideAnimation.value * 280,
                  top: 0,
                  bottom: 0,
                  width: 280,
                  child: RepaintBoundary(
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: const ModernSidebar(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile && !viewModel.isSidebarExpanded
          ? Container(
        margin: const EdgeInsets.only(bottom: 0, right: 8),
        child: SizedBox(
          height: 48,
          width: 48,
          child: FloatingActionButton(
            elevation: 2,
            backgroundColor: theme.colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () => viewModel.toggleSidebar(),
            child: Icon(
              AppIcons.menu,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar(BuildContext context, HomeViewModel viewModel) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => viewModel.toggleSidebar(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  viewModel.isSidebarExpanded
                      ? Icons.menu_open_rounded
                      : Icons.menu_rounded,
                  key: ValueKey(viewModel.isSidebarExpanded),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              tooltip: viewModel.isSidebarExpanded ? '收起菜单' : '展开菜单',
            ),
          ),

          Center(
            child: Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: MoreMenuButton(),
          ),
        ],
      ),
    );
  }
}