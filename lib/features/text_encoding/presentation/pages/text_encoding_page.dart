import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/widgets/action_button.dart';
import '../../../../presentation/widgets/control_card.dart';
import '../../../../presentation/widgets/custom_toggle.dart';
import '../../../../presentation/widgets/enhanced_dropdown.dart';
import '../../../../presentation/widgets/text_area_card.dart';
import '../viewmodels/text_encoding_viewmodel.dart';

class TextEncodingPage extends StatefulWidget {
  const TextEncodingPage({super.key});

  @override
  State<TextEncodingPage> createState() => _TextEncodingPageState();
}

class _TextEncodingPageState extends State<TextEncodingPage> with SingleTickerProviderStateMixin {
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
      create: (_) => TextEncodingViewModel(),
      child: Consumer<TextEncodingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ControlCard(
                        children: [
                          Expanded(
                            flex: 3,
                            child: EnhancedDropdown<String>(
                              items: viewModel.encodingTypeList,
                              selectedValue: viewModel.selectedEncodingName,
                              onChanged: viewModel.setEncodingTypeByName,
                              itemLabelBuilder: (item) => item,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CustomToggle(
                              isFirstOptionSelected: viewModel.isEncoding,
                              firstOptionLabel: '编码',
                              secondOptionLabel: '解码',
                              onFirstOptionSelected: () {
                                if (!viewModel.isEncoding) viewModel.toggleMode();
                              },
                              onSecondOptionSelected: () {
                                if (viewModel.isEncoding) viewModel.toggleMode();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            TextAreaCard(
                              controller: viewModel.inputController,
                              hintText: viewModel.getInputHint(),
                              leadingWidget: ElevatedButton.icon(
                                onPressed: viewModel.processText,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: Icon(
                                  viewModel.isEncoding ? Icons.lock_outline : Icons.lock_open,
                                  size: 18,
                                ),
                                label: Text(
                                  viewModel.isEncoding ? '编码' : '解码',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                          ],
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
}