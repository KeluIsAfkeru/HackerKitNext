import 'package:flutter/cupertino.dart';

class ActionButton {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });
}