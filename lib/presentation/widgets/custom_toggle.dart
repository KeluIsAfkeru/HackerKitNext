import 'package:flutter/material.dart';

//自定义的切换按钮
class CustomToggle extends StatelessWidget {
  final bool isFirstOptionSelected;
  final String firstOptionLabel;
  final String secondOptionLabel;
  final VoidCallback onFirstOptionSelected;
  final VoidCallback onSecondOptionSelected;

  const CustomToggle({
    super.key,
    required this.isFirstOptionSelected,
    required this.firstOptionLabel,
    required this.secondOptionLabel,
    required this.onFirstOptionSelected,
    required this.onSecondOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: isFirstOptionSelected ? 0 : constraints.maxWidth / 2,
                width: constraints.maxWidth / 2,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildToggleButton(
                    context: context,
                    label: firstOptionLabel,
                    isSelected: isFirstOptionSelected,
                    onTap: onFirstOptionSelected,
                    colorScheme: colorScheme,
                  ),
                  _buildToggleButton(
                    context: context,
                    label: secondOptionLabel,
                    isSelected: !isFirstOptionSelected,
                    onTap: onSecondOptionSelected,
                    colorScheme: colorScheme,
                  ),
                ],
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
                duration: Duration(milliseconds: 300),
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