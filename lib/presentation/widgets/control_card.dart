import 'package:flutter/material.dart';

class ControlCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const ControlCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}