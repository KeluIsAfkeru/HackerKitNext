import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/action_button.dart';
import '../../../../presentation/widgets/control_card.dart';
import '../../../../presentation/widgets/enhanced_dropdown.dart';
import '../../../../presentation/widgets/text_area_card.dart';
import '../viewmodels/base_converter_viewmodel.dart';

class BaseConverterPage extends StatefulWidget {
  const BaseConverterPage({super.key});

  @override
  State<BaseConverterPage> createState() => _BaseConverterPageState();
}

class _BaseConverterPageState extends State<BaseConverterPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BaseConverterViewModel(),
      child: Consumer<BaseConverterViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      ControlCard(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "源格式",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          EnhancedDropdown<String>(
                                            items: viewModel.formatList,
                                            selectedValue: viewModel.sourceFormatName,
                                            onChanged: viewModel.setSourceFormatByName,
                                            itemLabelBuilder: (item) => item,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "目标格式",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          EnhancedDropdown<String>(
                                            items: viewModel.formatList,
                                            selectedValue: viewModel.targetFormatName,
                                            onChanged: viewModel.setTargetFormatByName,
                                            itemLabelBuilder: (item) => item,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "源分隔符",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          EnhancedDropdown<String>(
                                            items: viewModel.separatorOptions,
                                            selectedValue: viewModel.isCustomSourceSeparator
                                                ? '自定义'
                                                : viewModel.separatorOptions.firstWhere(
                                                  (option) => viewModel.separatorMap[option] == viewModel.sourceSeparator,
                                              orElse: () => '无',
                                            ),
                                            onChanged: viewModel.setSourceSeparator,
                                            itemLabelBuilder: (item) => item,
                                          ),
                                          if (viewModel.isCustomSourceSeparator)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: TextField(
                                                onTapOutside: (event) {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "自定义分隔符",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  isDense: true, //使TextField更紧凑
                                                ),
                                                textAlignVertical: TextAlignVertical.center, //文本垂直居中
                                                onChanged: viewModel.setCustomSourceSeparator,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "目标分隔符",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          EnhancedDropdown<String>(
                                            items: viewModel.separatorOptions,
                                            selectedValue: viewModel.isCustomTargetSeparator
                                                ? '自定义'
                                                : viewModel.separatorOptions.firstWhere(
                                                  (option) => viewModel.separatorMap[option] == viewModel.targetSeparator,
                                              orElse: () => '无',
                                            ),
                                            onChanged: viewModel.setTargetSeparator,
                                            itemLabelBuilder: (item) => item,
                                          ),
                                          if (viewModel.isCustomTargetSeparator)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: TextField(
                                                onTapOutside: (event) {
                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "自定义分隔符",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  isDense: true, //使TextField更紧凑
                                                ),
                                                textAlignVertical: TextAlignVertical.center, //文本垂直居中
                                                onChanged: viewModel.setCustomTargetSeparator, //修正：使用正确的目标设置方法
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      //输入区域
                      TextAreaCard(
                        controller: viewModel.inputController,
                        hintText: "在这里输入要转换的内容",
                        leadingWidget: ElevatedButton.icon(
                          onPressed: viewModel.convertText,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            '转换',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        actions: [
                          ActionButton(
                            icon: Icons.content_paste_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            tooltip: '粘贴',
                            onPressed: viewModel.pasteFromClipboard,
                          ),
                          ActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                            tooltip: '清空',
                            onPressed: viewModel.clearInput,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      //输出区域
                      TextAreaCard(
                        title: '转换结果',
                        controller: viewModel.outputController,
                        hintText: '处理结果将显示在这里...',
                        readOnly: true,
                        actions: [
                          ActionButton(
                            icon: Icons.content_copy_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            tooltip: '复制',
                            onPressed: viewModel.copyToClipboard,
                          ),
                          ActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                            tooltip: '清空',
                            onPressed: viewModel.clearOutput,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '转换示例：',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _buildExampleItem(
                                '• 输入：-118,70,255，源格式：十进制，源分隔符：逗号，目标格式：十六进制，目标分隔符：逗号',
                                '  结果：8a,46,ff',
                              ),

                              _buildExampleItem(
                                '• 输入：8a,46,ff，源格式：十六进制，源分隔符：逗号，目标格式：十进制，目标分隔符：逗号',
                                '  结果：138,70,255',
                              ),

                              _buildExampleItem(
                                '• 输入：5Lit5Zu9YWJj，源格式：Base64，源分隔符：无，目标格式：十六进制，目标分隔符：逗号',
                                '  结果：e4,b8,ad,e5,9b,bd,61,62,63',
                              ),

                              _buildExampleItem(
                                '• 输入：e4,b8,ad,e5,9b,bd,61,62,63，源格式：十六进制，源分隔符：逗号，目标格式：Base64，目标分隔符：无',
                                '  结果：5Lit5Zu9YWJj',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildExampleItem(String description, String result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              result,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
