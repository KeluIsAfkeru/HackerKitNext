import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/toast_service.dart';

class BinaryBitsDisplay extends StatelessWidget {
  final String binaryCode;
  final Color accentColor;

  const BinaryBitsDisplay({
    super.key,
    required this.binaryCode,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: binaryCode.isEmpty
                ? Text(
              '等待计算...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            )
                : Row(
              children: [
                //符号位
                _buildBit(context, binaryCode[0], isSignBit: true, accentColor: accentColor),
                const SizedBox(width: 8),

                //数值位
                ...List.generate(binaryCode.length - 1, (index) {
                  final bitIndex = index + 1;
                  final bit = binaryCode[bitIndex];

                  //每4位添加间隔，提高可读性
                  final needsSpaceAfter = (index + 1) % 4 == 0 && bitIndex < binaryCode.length - 1;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBit(context, bit, accentColor: accentColor),
                      if (needsSpaceAfter) const SizedBox(width: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBit(BuildContext context, String bit, {bool isSignBit = false, required Color accentColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    //根据位的值和类型确定颜色
    Color bitColor;
    Color backgroundColor;

    if (isSignBit) {
      if (bit == '1') {  //负数
        bitColor = theme.colorScheme.onErrorContainer;
        backgroundColor = theme.colorScheme.errorContainer.withOpacity(isDark ? 0.7 : 0.5);
      } else {  //正数
        bitColor = theme.colorScheme.onPrimaryContainer;
        backgroundColor = theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.7 : 0.5);
      }
    } else {
      if (bit == '1') {
        bitColor = isDark ? accentColor : theme.colorScheme.onSecondaryContainer;
        backgroundColor = isDark
            ? accentColor.withOpacity(0.2)
            : theme.colorScheme.secondaryContainer.withOpacity(0.7);
      } else {
        bitColor = theme.colorScheme.onSurfaceVariant;
        backgroundColor = theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
      }
    }

    return Container(
      width: 24,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSignBit ? accentColor.withOpacity(0.3) : theme.colorScheme.outline.withOpacity(0.1),
          width: isSignBit ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          bit,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: bitColor,
            fontWeight: isSignBit ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ToastService.showSuccessToast('已复制到剪贴板');
  }
}