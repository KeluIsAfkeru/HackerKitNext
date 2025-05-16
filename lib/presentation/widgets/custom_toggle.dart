import 'package:flutter/material.dart';

// 自定义的切换按钮，支持多个选项
class CustomToggle extends StatelessWidget {
  // 新增支持多选项的参数
  final List<String>? options;
  final int? selectedIndex;
  final Function(int)? onOptionSelected;

  // 保留原有参数以兼容旧代码
  final bool isFirstOptionSelected;
  final String firstOptionLabel;
  final String secondOptionLabel;
  final VoidCallback onFirstOptionSelected;
  final VoidCallback onSecondOptionSelected;

  // 构造函数同时支持两种模式
  CustomToggle({
    super.key,
    this.options,
    this.selectedIndex,
    this.onOptionSelected,
    this.isFirstOptionSelected = true,
    this.firstOptionLabel = '',
    this.secondOptionLabel = '',
    this.onFirstOptionSelected = _emptyCallback,
    this.onSecondOptionSelected = _emptyCallback,
  }) : assert((options != null && selectedIndex != null && onOptionSelected != null) ||
      (firstOptionLabel.isNotEmpty && secondOptionLabel.isNotEmpty));

  static void _emptyCallback() {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 使用新API或兼容旧API
    final bool useNewApi = options != null && selectedIndex != null && onOptionSelected != null;
    final List<String> displayOptions = useNewApi
        ? options!
        : [firstOptionLabel, secondOptionLabel];
    final int currentIndex = useNewApi
        ? selectedIndex!
        : (isFirstOptionSelected ? 0 : 1);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final optionWidth = constraints.maxWidth / displayOptions.length;

          return Stack(
            children: [
              // 动画选择器背景
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: currentIndex * optionWidth,
                width: optionWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // 选项行
              Row(
                children: List.generate(displayOptions.length, (index) {
                  return _buildToggleButton(
                    context: context,
                    label: displayOptions[index],
                    isSelected: currentIndex == index,
                    onTap: () {
                      if (useNewApi) {
                        onOptionSelected!(index);
                      } else {
                        index == 0 ? onFirstOptionSelected() : onSecondOptionSelected();
                      }
                    },
                    colorScheme: colorScheme,
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      flex: 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}