import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../../core/services/toast_service.dart';

enum BaseFormat {
  decimal,
  hexadecimal,
  binary,
  base64,
}

class BaseConverterViewModel extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  BaseFormat _sourceFormat = BaseFormat.decimal;
  BaseFormat _targetFormat = BaseFormat.hexadecimal;

  String _sourceSeparator = '';
  String _targetSeparator = '';
  bool _isProcessing = false;

  //Format names mapping
  final Map<BaseFormat, String> formatNames = {
    BaseFormat.decimal: '十进制',
    BaseFormat.hexadecimal: '十六进制',
    BaseFormat.binary: '二进制',
    BaseFormat.base64: 'Base64',
  };

  //Separator options
  final List<String> separatorOptions = ['无', '逗号 (,)', '空格 ( )', '分号 (;)', '自定义'];

  //Separator mapping
  final Map<String, String> separatorValues = {
    '无': '',
    '逗号 (,)': ',',
    '空格 ( )': ' ',
    '分号 (;)': ';',
    '自定义': 'custom',
  };

  String _customSourceSeparator = '';
  String _customTargetSeparator = '';
  bool _isCustomSourceSeparator = false;
  bool _isCustomTargetSeparator = false;

  //Getters
  List<String> get formatList => formatNames.values.toList();
  BaseFormat get sourceFormat => _sourceFormat;
  BaseFormat get targetFormat => _targetFormat;
  String get sourceFormatName => formatNames[_sourceFormat] ?? '十进制';
  String get targetFormatName => formatNames[_targetFormat] ?? '十六进制';
  String get sourceSeparator => _isCustomSourceSeparator ? _customSourceSeparator : _sourceSeparator;
  String get targetSeparator => _isCustomTargetSeparator ? _customTargetSeparator : _targetSeparator;
  bool get isProcessing => _isProcessing;
  bool get isCustomSourceSeparator => _isCustomSourceSeparator;
  bool get isCustomTargetSeparator => _isCustomTargetSeparator;
  Map<String, String> get separatorMap => separatorValues;

  void setSourceFormatByName(String name) {
    final entry = formatNames.entries.firstWhere(
          (entry) => entry.value == name,
      orElse: () => MapEntry(BaseFormat.decimal, '十进制'),
    );

    _sourceFormat = entry.key;
    notifyListeners();
  }

  void setTargetFormatByName(String name) {
    final entry = formatNames.entries.firstWhere(
          (entry) => entry.value == name,
      orElse: () => MapEntry(BaseFormat.hexadecimal, '十六进制'),
    );

    _targetFormat = entry.key;
    notifyListeners();
  }

  void setSourceSeparator(String option) {
    if (option == '自定义') {
      _isCustomSourceSeparator = true;
    } else {
      _isCustomSourceSeparator = false;
      _sourceSeparator = separatorValues[option] ?? '';
    }
    notifyListeners();
  }

  void setTargetSeparator(String option) {
    if (option == '自定义') {
      _isCustomTargetSeparator = true;
    } else {
      _isCustomTargetSeparator = false;
      _targetSeparator = separatorValues[option] ?? '';
    }
    notifyListeners();
  }

  void setCustomSourceSeparator(String value) {
    _customSourceSeparator = value;
  }

  void setCustomTargetSeparator(String value) {
    _customTargetSeparator = value;
  }

  Future<void> convertText() async {
    if (inputController.text.isEmpty) {
      ToastService.showInfoToast('请输入需要转换的文本');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _performConversion();
      outputController.text = result;
    } catch (e) {
      ToastService.showErrorToast('转换失败：${e.toString()}');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> _performConversion() async {
    final inputText = inputController.text;
    final effectiveSourceSeparator = sourceSeparator;
    final effectiveTargetSeparator = targetSeparator;

    List<int> bytes = _parseInput(inputText, _sourceFormat, effectiveSourceSeparator);

    return _convertToFormat(bytes, _targetFormat, effectiveTargetSeparator);
  }

  List<int> _parseInput(String input, BaseFormat format, String separator) {
    List<int> result = [];

    try {
      switch (format) {
        case BaseFormat.decimal:
          if (separator.isEmpty) {
            result = [int.parse(input)];
          } else {
            result = input
                .split(separator)
                .where((s) => s.trim().isNotEmpty)
                .map((s) => int.parse(s.trim()))
                .toList();
          }
          break;

        case BaseFormat.hexadecimal:
          if (separator.isEmpty) {
            final cleanInput = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
            for (int i = 0; i < cleanInput.length; i += 2) {
              if (i + 1 >= cleanInput.length) {
                result.add(int.parse(cleanInput.substring(i, i + 1), radix: 16));
              } else {
                result.add(int.parse(cleanInput.substring(i, i + 2), radix: 16));
              }
            }
          } else {
            result = input
                .split(separator)
                .where((s) => s.trim().isNotEmpty)
                .map((s) {
              String hexValue = s.trim();
              if (hexValue.startsWith('0x')) {
                hexValue = hexValue.substring(2);
              }
              return int.parse(hexValue, radix: 16);
            })
                .toList();
          }
          break;

        case BaseFormat.binary:
          if (separator.isEmpty) {
            final cleanInput = input.replaceAll(RegExp(r'[^01]'), '');
            for (int i = 0; i < cleanInput.length; i += 8) {
              final end = (i + 8 <= cleanInput.length) ? i + 8 : cleanInput.length;
              final chunk = cleanInput.substring(i, end);
              result.add(int.parse(chunk, radix: 2));
            }
          } else {
            result = input
                .split(separator)
                .where((s) => s.trim().isNotEmpty)
                .map((s) {
              String binaryValue = s.trim();
              if (binaryValue.startsWith('0b')) {
                binaryValue = binaryValue.substring(2);
              }
              return int.parse(binaryValue, radix: 2);
            })
                .toList();
          }
          break;

        case BaseFormat.base64:
          final decoded = base64.decode(input);
          result = decoded;
          break;
      }

      return result;
    } catch (e) {
      throw '无法解析输入：${e.toString()}';
    }
  }

  String _convertToFormat(List<int> bytes, BaseFormat format, String separator) {
    try {
      switch (format) {
        case BaseFormat.decimal:
          return bytes.map((b) => b.toString()).join(separator);

        case BaseFormat.hexadecimal:
          return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(separator);

        case BaseFormat.binary:
          return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join(separator);

        case BaseFormat.base64:
          return base64.encode(bytes);

        default:
          throw '不支持的目标格式';
      }
    } catch (e) {
      throw '转换失败：${e.toString()}';
    }
  }

  Future<void> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      inputController.text = clipboardData.text!;
    }
  }

  void copyToClipboard() {
    if (outputController.text.isEmpty) {
      return;
    }

    Clipboard.setData(ClipboardData(text: outputController.text));
    ToastService.showSuccessToast('已复制到剪贴板');
  }

  void clearInput() {
    inputController.clear();
  }

  void clearOutput() {
    outputController.clear();
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }
}