import 'package:flutter/material.dart';

import 'action_button.dart';

class TextAreaCard extends StatelessWidget {
  final String? title;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final List<ActionButton> actions;
  final Widget? leadingWidget;

  const TextAreaCard({
    super.key,
    this.title,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    required this.actions,
    this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                if (leadingWidget != null)
                  Expanded(child: leadingWidget!)
                else if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                if (title != null) const Spacer(),
                // Action buttons
                ...actions.map((action) =>
                    IconButton(
                      icon: Icon(action.icon, color: action.color, size: 20),
                      tooltip: action.tooltip,
                      onPressed: action.onPressed,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minHeight: 120,
              maxHeight: 200,
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              minLines: 5,
              readOnly: readOnly,
              style: TextStyle(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}