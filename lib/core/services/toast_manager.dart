import 'package:flutter/material.dart';

import '../../models/toast_gravity.dart';

//Toast管理器，可以显示多个气泡提示框
class ToastManager {
  static final List<OverlayEntry> _toastEntries = [];
  static BuildContext? _context;

  //显示的气泡框数量
  static int get activeToastCount => _toastEntries.length;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static void showToast({
    required Widget toastWidget,
    ToastGravity gravity = ToastGravity.top,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (_context == null) {
      debugPrint('Warning: ToastManager未初始化，无法显示提示');
      return;
    }

    //每个新Toast都会根据已有Toast数量向下偏移
    final double? topOffset = gravity == ToastGravity.top
        ? 60 + (_toastEntries.length * 10)
        : null;

    final double? bottomOffset = gravity == ToastGravity.bottom
        ? 60 + (_toastEntries.length * 10)
        : null;

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          return _ToastOverlayWidget(
            toast: toastWidget,
            gravity: gravity,
            duration: duration,
            topOffset: topOffset,
            bottomOffset: bottomOffset,
            onDismiss: () {
              _removeToast(overlayEntry);
            },
          );
        }
    );

    _toastEntries.add(overlayEntry);
    Overlay.of(_context!).insert(overlayEntry);

    //定时器自动移除
    Future.delayed(duration, () {
      _removeToast(overlayEntry);
    });
  }

  static void _removeToast(OverlayEntry entry) {
    if (_toastEntries.contains(entry)) {
      try {
        entry.remove();
      } catch (e) {
        debugPrint('移除Toast出错: $e');
      }
      _toastEntries.remove(entry);
    }
  }

  //移除所有Toast
  static void removeAllToasts() {
    for (var entry in List.from(_toastEntries)) {
      _removeToast(entry);
    }
    _toastEntries.clear();
  }
}

class _ToastOverlayWidget extends StatefulWidget {
  final Widget toast;
  final ToastGravity gravity;
  final Duration duration;
  final double? topOffset;
  final double? bottomOffset;
  final VoidCallback onDismiss;

  const _ToastOverlayWidget({
    required this.toast,
    required this.gravity,
    required this.duration,
    this.topOffset,
    this.bottomOffset,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    //滑动动画效果
    _slideAnimation = Tween<Offset>(
      begin: widget.gravity == ToastGravity.top ? const Offset(0, -0.2) : const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    //退出动画
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.gravity == ToastGravity.top ? widget.topOffset : null,
      bottom: widget.gravity == ToastGravity.bottom ? widget.bottomOffset : null,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: widget.toast,
              ),
            ),
          ),
        ),
      ),
    );
  }
}