import 'package:flutter/material.dart';
import '../../widgets/binary_bits_display.dart';
import '../viewmodels/binary_code_calculator_viewmodel.dart';

class BinaryCodeCalculatorPage extends StatefulWidget {
  const BinaryCodeCalculatorPage({super.key});

  @override
  State<BinaryCodeCalculatorPage> createState() => _BinaryCodeCalculatorPageState();
}

class _BinaryCodeCalculatorPageState extends State<BinaryCodeCalculatorPage> with SingleTickerProviderStateMixin {
  late BinaryCodeCalculatorViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = BinaryCodeCalculatorViewModel();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: _buildBitSizeSelector(),
            ),

            //剩余部分保持原有的边距
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    _buildInputCard(),
                    const SizedBox(height: 16),
                    _buildResultsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBitSizeSelector() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('选择位数:', style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [8, 16, 32, 64].map((size) => _buildBitOption(size)).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  Widget _buildBitOption(int bitSize) {
    final isSelected = _viewModel.bitSize == bitSize;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () => _viewModel.setBitSize(bitSize),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            '$bitSize位',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input_rounded, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  '输入整数',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _viewModel.inputController,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              style: theme.textTheme.headlineSmall,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                hintText: '输入一个整数...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _viewModel.inputController.clear(),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: AnimatedBuilder(
                  animation: _viewModel,
                  builder: (context, child) {
                    return ElevatedButton.icon(
                      onPressed: _viewModel.isProcessing ? null : () => _viewModel.calculate(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _viewModel.isProcessing
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                          : Icon(Icons.calculate_outlined),
                      label: Text(
                        '计算',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final theme = Theme.of(context);

    return AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: theme.colorScheme.primary),
                      SizedBox(width: 8),
                      Text(
                        '编码结果',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  //原码
                  _buildCodeResultSection(
                    title: '原码',
                    code: _viewModel.originalCode,
                    color: theme.colorScheme.primary,
                    icon: Icons.code,
                  ),
                  Divider(height: 24),

                  //反码
                  _buildCodeResultSection(
                    title: '反码',
                    code: _viewModel.inverseCode,
                    color: theme.colorScheme.secondary,
                    icon: Icons.swap_horiz,
                  ),
                  Divider(height: 24),

                  //补码
                  _buildCodeResultSection(
                    title: '补码',
                    code: _viewModel.complementCode,
                    color: theme.colorScheme.tertiary,
                    icon: Icons.add_circle_outline,
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildCodeResultSection({
    required String title,
    required String code,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.content_copy, size: 20),
              color: color,
              onPressed: () => _viewModel.copyToClipboard(code),
              tooltip: '复制到剪贴板',
            ),
          ],
        ),
        SizedBox(height: 8),
        BinaryBitsDisplay(
          binaryCode: code,
          accentColor: color,
        ),
      ],
    );
  }
}