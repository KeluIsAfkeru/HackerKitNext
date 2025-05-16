import 'package:flutter/material.dart';
import 'package:hackerkit_next/core/services/toast_service.dart';
import 'package:provider/provider.dart';

import '../../../../presentation/widgets/action_button.dart';
import '../../../../presentation/widgets/control_card.dart';
import '../../../../presentation/widgets/custom_toggle.dart';
import '../../../../presentation/widgets/enhanced_dropdown.dart';
import '../../../../presentation/widgets/text_area_card.dart';
import '../viewmodels/jwt_tool_viewmodel.dart';

class JwtToolPage extends StatefulWidget {
  const JwtToolPage({super.key});

  @override
  State<JwtToolPage> createState() => _JwtToolPageState();
}

class _JwtToolPageState extends State<JwtToolPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late TextEditingController _payloadController;
  late TextEditingController _secretKeyController;
  late TextEditingController _privateKeyController;
  late TextEditingController _publicKeyController;
  late TextEditingController _jwtTokenController;

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

    //初始化控制器
    _payloadController = TextEditingController();
    _secretKeyController = TextEditingController();
    _privateKeyController = TextEditingController();
    _publicKeyController = TextEditingController();
    _jwtTokenController = TextEditingController();

    _animationController.forward();
  }

  @override
  void dispose() {
    _payloadController.dispose();
    _secretKeyController.dispose();
    _privateKeyController.dispose();
    _publicKeyController.dispose();
    _jwtTokenController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  //更新控制器文本但保持光标位置
  void _updateControllerText(TextEditingController controller, String text) {
    if (controller.text != text) {
      final selection = controller.selection;
      controller.text = text;

      if (selection.start <= text.length && selection.end <= text.length) {
        controller.selection = selection;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JwtToolViewModel(),
      child: Consumer<JwtToolViewModel>(
        builder: (context, vm, _) {
          _updateControllerText(_payloadController, vm.payloadJson);
          _updateControllerText(_secretKeyController, vm.secretKey);
          _updateControllerText(_privateKeyController, vm.privateKey);
          _updateControllerText(_publicKeyController, vm.publicKey);
          _updateControllerText(_jwtTokenController, vm.jwtToken);

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
                            child: CustomToggle(
                              options: const ['加密', '解密', '校验'],
                              selectedIndex: vm.selectedMode.index,
                              onOptionSelected: (index) {
                                vm.selectedMode = JwtMode.values[index];
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      //内容区域
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            if (vm.isEncryptMode) ...[
                              _buildEncryptionUI(context, vm),
                            ],

                            if (!vm.isEncryptMode) ...[
                              _buildDecryptionVerificationUI(context, vm),
                            ],

                            if (vm.hasResult) ...[
                              const SizedBox(height: 16),
                              _buildResultSection(context, vm),
                            ],
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

  Widget _buildEncryptionUI(BuildContext context, JwtToolViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextAreaCard(
          leadingWidget: EnhancedDropdown<String>(
            items: [
              'HS256', 'HS384', 'HS512',
              'RS256', 'RS384', 'RS512',
              'ES256', 'ES384', 'ES512',
            ],
            selectedValue: vm.selectedAlgorithm,
            onChanged: (value) => vm.selectedAlgorithm = value,
            itemLabelBuilder: (item) => item,
          ),
          controller: _payloadController,
          hintText: '输入JSON格式的Payload数据',
          actions: [
            ActionButton(
              icon: Icons.content_paste_rounded,
              color: Theme.of(context).colorScheme.secondary,
              tooltip: '粘贴',
              onPressed: () async {
                await vm.pasteFromClipboard();
                _updateControllerText(_payloadController, vm.payloadJson);
              },
            ),
            ActionButton(
              icon: Icons.restore_rounded,
              color: Theme.of(context).colorScheme.tertiary,
              tooltip: '重置载荷',
              onPressed: () {
                vm.resetPayload();
                _updateControllerText(_payloadController, vm.payloadJson);
              },
            ),
            ActionButton(
              icon: Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              tooltip: '清空',
              onPressed: () {
                _payloadController.clear();
                vm.payloadJson = '';
              },
            ),
          ],
          onChanged: (value) => vm.payloadJson = value,
        ),

        const SizedBox(height: 12),

        if (vm.isSymmetricAlgorithm)
          TextAreaCard(
            title: '密钥信息',
            controller: _secretKeyController,
            hintText: '输入至少256位(32字节)长度的密钥',
            actions: [
              ActionButton(
                icon: Icons.content_paste_rounded,
                color: Theme.of(context).colorScheme.secondary,
                tooltip: '粘贴',
                onPressed: () async {
                  await vm.pasteFromClipboard();
                  _updateControllerText(_secretKeyController, vm.secretKey);
                },
              ),
              ActionButton(
                icon: Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                tooltip: '清空',
                onPressed: () {
                  _secretKeyController.clear();
                  vm.secretKey = '';
                },
              ),
            ],
            onChanged: (value) => vm.secretKey = value,
          ),

        if (vm.isAsymmetricAlgorithm) ...[
          _buildKeypairSection(context, vm),
        ],

        const SizedBox(height: 16),

        //操作按钮
        ElevatedButton.icon(
          icon: Icon(vm.actionButtonIcon),
          label: Text(vm.actionButtonText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
          onPressed: vm.executeAction,
        ),
      ],
    );
  }

  Widget _buildKeypairSection(BuildContext context, JwtToolViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '私钥 (用于签名)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.vpn_key, size: 18),
                    label: const Text('生成密钥对'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () async {
                      try {
                        await vm.generateRSAKeyPair();
                        ToastService.showSuccessToast('密钥对生成成功');
                        _updateControllerText(_privateKeyController, vm.privateKey);
                        _updateControllerText(_publicKeyController, vm.publicKey);
                      } catch (e) {
                        ToastService.showWarningToast('生成密钥对失败: $e');
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _privateKeyController,
                  onChanged: (value) => vm.privateKey = value,
                  maxLines: 3,
                  minLines: 3,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    height: 1.5,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入PEM格式私钥',
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
        ),

        Container(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '公钥 (用于验证)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHigh.withOpacity(0.5)
                      : colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _publicKeyController,
                  onChanged: (value) => vm.publicKey = value,
                  readOnly: true,
                  maxLines: 3,
                  minLines: 3,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: '生成密钥对后显示公钥',
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
        ),
      ],
    );
  }

  Widget _buildDecryptionVerificationUI(BuildContext context, JwtToolViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextAreaCard(
          title: 'JWT令牌',
          controller: _jwtTokenController, //使用持久控制器
          hintText: '输入JWT令牌',
          actions: [
            ActionButton(
              icon: Icons.content_paste_rounded,
              color: Theme.of(context).colorScheme.secondary,
              tooltip: '粘贴',
              onPressed: () async {
                await vm.pasteFromClipboard();
                _updateControllerText(_jwtTokenController, vm.jwtToken);
              },
            ),
            ActionButton(
              icon: Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              tooltip: '清空',
              onPressed: () {
                _jwtTokenController.clear();
                vm.jwtToken = '';
              },
            ),
          ],
          onChanged: (value) => vm.jwtToken = value,
        ),

        const SizedBox(height: 12),

        if (vm.isVerifyMode && vm.isSymmetricAlgorithm)
          TextAreaCard(
            title: '密钥信息',
            controller: _secretKeyController, //使用持久控制器
            hintText: '输入用于验证的密钥',
            actions: [
              ActionButton(
                icon: Icons.content_paste_rounded,
                color: Theme.of(context).colorScheme.secondary,
                tooltip: '粘贴',
                onPressed: () async {
                  await vm.pasteFromClipboard();
                  _updateControllerText(_secretKeyController, vm.secretKey);
                },
              ),
              ActionButton(
                icon: Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                tooltip: '清空',
                onPressed: () {
                  _secretKeyController.clear();
                  vm.secretKey = '';
                },
              ),
            ],
            onChanged: (value) => vm.secretKey = value,
          ),

        if (vm.isVerifyMode && vm.isAsymmetricAlgorithm)
          TextAreaCard(
            title: '公钥信息',
            controller: _publicKeyController, //使用持久控制器
            hintText: '输入PEM格式公钥用于验证',
            actions: [
              ActionButton(
                icon: Icons.content_paste_rounded,
                color: Theme.of(context).colorScheme.secondary,
                tooltip: '粘贴',
                onPressed: () async {
                  await vm.pasteFromClipboard();
                  _updateControllerText(_publicKeyController, vm.publicKey);
                },
              ),
              ActionButton(
                icon: Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                tooltip: '清空',
                onPressed: () {
                  _publicKeyController.clear();
                  vm.publicKey = '';
                },
              ),
            ],
            onChanged: (value) => vm.publicKey = value,
          ),

        //解码信息
        if (vm.decodedHeader.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDecodedSection(context, vm),
        ],

        const SizedBox(height: 16),

        //操作按钮
        ElevatedButton.icon(
          icon: Icon(vm.actionButtonIcon),
          label: Text(vm.actionButtonText),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
          onPressed: vm.executeAction,
        ),
      ],
    );
  }

  Widget _buildDecodedSection(BuildContext context, JwtToolViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Header:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: SelectableText(
              vm.decodedHeader,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Payload:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: SelectableText(
              vm.decodedPayload,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          //过期时间信息
          if (vm.hasExpirationClaim && vm.expirationTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: vm.expirationTime!.isBefore(DateTime.now())
                      ? colorScheme.errorContainer.withOpacity(0.6)
                      : colorScheme.tertiaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      vm.expirationTime!.isBefore(DateTime.now())
                          ? Icons.timer_off_outlined
                          : Icons.timer_outlined,
                      size: 18,
                      color: vm.expirationTime!.isBefore(DateTime.now())
                          ? colorScheme.error
                          : colorScheme.tertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '过期时间: ${vm.expirationTime!.toLocal()} (${vm.expirationTime!.isBefore(DateTime.now()) ? "已过期" : "有效"})',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: vm.expirationTime!.isBefore(DateTime.now())
                              ? colorScheme.error
                              : colorScheme.tertiary,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, JwtToolViewModel vm) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    IconData statusIcon;

    if (vm.resultColor == Colors.green) {
      statusColor = colorScheme.primary;
      statusIcon = Icons.check_circle_outline;
    } else if (vm.resultColor == Colors.orange) {
      statusColor = colorScheme.tertiary;
      statusIcon = Icons.info_outline;
    } else {
      statusColor = colorScheme.error;
      statusIcon = Icons.error_outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                vm.resultTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.copy, color: colorScheme.primary, size: 20),
                tooltip: '复制结果',
                onPressed: vm.copyResultToClipboard,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                vm.resultText,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}