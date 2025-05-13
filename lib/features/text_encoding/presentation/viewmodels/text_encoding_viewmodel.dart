import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:punycode_converter/punycode_converter.dart';
import 'dart:convert';
import '../../../../../core/services/toast_service.dart';

enum EncodingType {
  base64,
  url,
  unicode,
  hex,
  ascii,
  html,
  utf8,
  utf32,
  punycode,
}

class TextEncodingViewModel extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  EncodingType _selectedEncodingType = EncodingType.base64;
  bool _isEncoding = true;
  bool _isProcessing = false;

  //编码类型名称映射
  final Map<EncodingType, String> encodingTypeNames = {
    EncodingType.base64: 'Base64',
    EncodingType.hex: 'Hex',
    EncodingType.url: 'URL',
    EncodingType.unicode: 'Unicode',
    EncodingType.ascii: 'ASCII',
    EncodingType.html: 'HTML实体',
    EncodingType.utf8: 'UTF-8',
    EncodingType.utf32: 'UTF-32',
    EncodingType.punycode: 'Punycode'
  };

  List<String> get encodingTypeList => encodingTypeNames.values.toList();

  //Getters
  EncodingType get selectedEncodingType => _selectedEncodingType;
  String get selectedEncodingName => encodingTypeNames[_selectedEncodingType] ?? 'Base64';
  bool get isEncoding => _isEncoding;
  bool get isProcessing => _isProcessing;

  void setEncodingTypeByName(String name) {
    final entry = encodingTypeNames.entries.firstWhere(
          (entry) => entry.value == name,
      orElse: () => MapEntry(EncodingType.base64, 'Base64'),
    );

    _selectedEncodingType = entry.key;
    notifyListeners();
  }

  set selectedEncodingType(EncodingType value) {
    _selectedEncodingType = value;
    notifyListeners();
  }

  void toggleMode() {
    _isEncoding = !_isEncoding;
    notifyListeners();
  }

  Future<void> processText() async {
    if (inputController.text.isEmpty) {
      ToastService.showInfoToast('请输入需要处理的文本');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      if (_isEncoding) {
        await _encodeText();
      } else {
        await _decodeText();
      }
    } catch (e) {
      ToastService.showErrorToast('处理失败：${e.toString()}');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  //编码文本
  Future<void> _encodeText() async {
    final inputText = inputController.text;
    String result;

    switch (_selectedEncodingType) {
      case EncodingType.base64:
        result = base64Encode(utf8.encode(inputText));
        break;

      case EncodingType.url:
        result = Uri.encodeComponent(inputText);
        break;

      case EncodingType.unicode:
        result = _convertToUnicode(inputText);
        break;

      case EncodingType.hex:
        result = _convertToHex(inputText);
        break;

      case EncodingType.ascii:
        try {
          result = _convertToAscii(inputText);
        } catch (e) {
          throw e.toString();
        }
        break;

      case EncodingType.html:
        result = _htmlEncode(inputText);
        break;

      case EncodingType.utf8:
        result = _convertToUtf8(inputText);
        break;

      case EncodingType.utf32:
        result = _convertToUtf32(inputText);
        break;

      case EncodingType.punycode:
        result = _convertToPunycode(inputText);
        break;

    }

    outputController.text = result;
  }

  //解码文本
  Future<void> _decodeText() async {
    final inputText = inputController.text;
    String result;

    switch (_selectedEncodingType) {
      case EncodingType.base64:
        try {
          final decoded = base64Decode(inputText);
          result = utf8.decode(decoded);
        } catch (e) {
          throw '无效的Base64编码';
        }
        break;

      case EncodingType.url:
        try {
          result = Uri.decodeComponent(inputText);
        } catch (e) {
          throw '无效的URL编码';
        }
        break;

      case EncodingType.unicode:
        result = _convertFromUnicode(inputText);
        break;

      case EncodingType.hex:
        try {
          result = _convertFromHex(inputText);
        } catch (e) {
          throw '无效的Hex编码：${e.toString()}';
        }
        break;

      case EncodingType.ascii:
        result = _convertFromAscii(inputText);
        break;

      case EncodingType.html:
        result = _htmlDecode(inputText);
        break;

      case EncodingType.utf8:
        try {
          result = _convertFromUtf8(inputText);
        } catch (e) {
          throw '无效的UTF-8编码';
        }
        break;

      case EncodingType.utf32:
        try {
          result = _convertFromUtf32(inputText);
        } catch (e) {
          throw '无效的UTF-32编码';
        }
        break;

      case EncodingType.punycode:
        result = _convertFromPunycode(inputText);
        break;
    }

    outputController.text = result;
  }

  //Unicode编码
  String _convertToUnicode(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      buffer.write('\\u${codeUnit.toRadixString(16).padLeft(4, '0')}');
    }
    return buffer.toString();
  }

  //Unicode解码
  String _convertFromUnicode(String input) {
    final pattern = RegExp(r'\\u([0-9a-fA-F]{4})');
    return input.replaceAllMapped(pattern, (match) {
      final hexCode = match.group(1)!;
      final codeUnit = int.parse(hexCode, radix: 16);
      return String.fromCharCode(codeUnit);
    });
  }

  //Hex编码
  String _convertToHex(String input) {
    final bytes = utf8.encode(input);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  //Hex解码
  String _convertFromHex(String input) {
    final cleanInput = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (cleanInput.length % 2 != 0) {
      throw '无效的Hex编码：长度不是偶数';
    }

    final bytes = <int>[];
    for (int i = 0; i < cleanInput.length; i += 2) {
      bytes.add(int.parse(cleanInput.substring(i, i + 2), radix: 16));
    }
    try {
      return utf8.decode(bytes);
    } catch (e) {
      throw '无效的UTF-8序列';
    }
  }

  //ASCII编码
  String _convertToAscii(String input) {
    final buffer = StringBuffer();
    for (final char in input.codeUnits) {
      if (char > 127) {
        throw '包含非ASCII字符';
      }
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(char.toString());
    }
    return buffer.toString();
  }

  //ASCII解码
  String _convertFromAscii(String input) {
    final values = input.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty);
    final buffer = StringBuffer();

    for (final value in values) {
      final intValue = int.tryParse(value);
      if (intValue != null) {
        buffer.write(String.fromCharCode(intValue));
      }
    }

    return buffer.toString();
  }

  //HTML实体编码
  String _htmlEncode(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  //HTML实体解码
  String _htmlDecode(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  //UTF-8编码
  String _convertToUtf8(String input) {
    final bytes = utf8.encode(input);
    return bytes.map((byte) => byte.toString()).join(', ');
  }

  //UTF-8解码
  String _convertFromUtf8(String input) {
    try {
      final bytesString = input.trim();
      final bytesList = bytesString.split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s.trim()))
          .toList();
      return utf8.decode(bytesList);
    } catch (e) {
      throw '无效的UTF-8编码';
    }
  }

  //UTF-32编码
  String _convertToUtf32(String input) {
    final buffer = StringBuffer();
    for (final codePoint in input.runes) {
      final hexValue = codePoint.toRadixString(16).padLeft(8, '0');
      buffer.write('U+$hexValue ');
    }
    return buffer.toString().trim();
  }

  //UTF-32解码
  String _convertFromUtf32(String input) {
    final pattern = RegExp(r'U\+([0-9A-Fa-f]{1,8})');
    final buffer = StringBuffer();

    for (final match in pattern.allMatches(input)) {
      final hexCode = match.group(1)!;
      final codePoint = int.parse(hexCode, radix: 16);
      buffer.writeCharCode(codePoint);
    }

    return buffer.toString();
  }

  //Punycode编码
  String _convertToPunycode(String input) {
    try {
      return Punycode.encode(input);
    } catch (e) {
      try {
        return Punycode.domainEncode(input);
      } catch (e) {
        throw 'Punycode编码失败：${e.toString()}';
      }
    }
  }

  //Punycode解码
  String _convertFromPunycode(String input) {
    try {
      if (input.contains('.') || input.startsWith('xn--')) {
        return Punycode.domainDecode(input);
      } else {
        return Punycode.decode(input);
      }
    } catch (e) {
      throw '无效的Punycode编码：${e.toString()}';
    }
  }


  //剪贴板粘贴
  Future<void> pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      inputController.text = clipboardData.text!;
    }
  }

  //剪贴板复制
  void copyToClipboard() {
    if (outputController.text.isEmpty) {
      return;
    }

    Clipboard.setData(ClipboardData(text: outputController.text));
    ToastService.showSuccessToast('已复制到剪贴板');
  }

  //清空输入
  void clearInput() {
    inputController.clear();
  }

  //清空输出
  void clearOutput() {
    outputController.clear();
  }

  //获取输入提示文本
  String getInputHint() {
    return isEncoding
        ? '输入需要编码的文本...'
        : '输入需要解码的$selectedEncodingName文本...';
  }

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }
}
