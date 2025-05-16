import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class EnhancedDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T selectedValue;
  final Function(T) onChanged;
  final String Function(T) itemLabelBuilder;

  const EnhancedDropdown({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemLabelBuilder,
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabelBuilder(item),
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ))
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.expand_more_rounded,
              color: colorScheme.primary,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface,
            ),
            offset: const Offset(0, -4),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}