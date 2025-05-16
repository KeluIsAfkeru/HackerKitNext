import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/services/toast_service.dart';

class BinaryCodeCalculatorViewModel extends ChangeNotifier {
  final TextEditingController inputController = TextEditingController();

  String _originalCode = '';
  String _inverseCode = '';
  String _complementCode = '';

  int _bitSize = 8;
  bool _isProcessing = false;

  //Getters
  String get originalCode => _originalCode;
  String get inverseCode => _inverseCode;
  String get complementCode => _complementCode;
  int get bitSize => _bitSize;
  bool get isProcessing => _isProcessing;

  void setBitSize(int size) {
    _bitSize = size;
    notifyListeners();
  }

  Future<void> calculate() async {
    if (inputController.text.isEmpty) {
      ToastService.showInfoToast('请输入一个整数');
      return;
    }

    int? value;
    try {
      value = int.parse(inputController.text);
    } catch (e) {
      ToastService.showErrorToast('无效的整数输入');
      return;
    }

    //检查输入值是否在范围内
    final minValue = -1 * (1 << (_bitSize - 1));
    final maxValue = (1 << (_bitSize - 1)) - 1;

    if (value < minValue || value > maxValue) {
      ToastService.showWarningToast('数值超出$_bitSize位整数范围 ($minValue 到 $maxValue)');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      _calculateCodes(value);
    } catch (e) {
      ToastService.showErrorToast('计算失败：${e.toString()}');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _calculateCodes(int value) {
    //计算原码
    _originalCode = _calculateOriginalCode(value);

    //计算反码
    _inverseCode = _calculateInverseCode(value);

    //计算补码
    _complementCode = _calculateComplementCode(value);

    notifyListeners();
  }

  //原码
  String _calculateOriginalCode(int value) {
    String result = '';

    if (value < 0) {
      result = '1';
    } else {
      result = '0';
    }

    int absValue = value.abs();
    String valueBits = absValue.toRadixString(2).padLeft(_bitSize - 1, '0');

    if (valueBits.length > _bitSize - 1) {
      valueBits = valueBits.substring(valueBits.length - (_bitSize - 1));
    }

    result += valueBits;

    return result;
  }

  //反码
  String _calculateInverseCode(int value) {
    if (value >= 0) {
      //正数的反码与原码相同
      return _calculateOriginalCode(value);
    } else {
      //负数的反码是符号位为1，其余位是绝对值按位取反
      String originalCode = _calculateOriginalCode(value);
      String inverseBits = '1'; //负数符号位保持为1

      //数值位按位取反
      for (int i = 1; i < originalCode.length; i++) {
        inverseBits += (originalCode[i] == '0') ? '1' : '0';
      }

      return inverseBits;
    }
  }

  //补码
  String _calculateComplementCode(int value) {
    if (value >= 0) {
      return _calculateOriginalCode(value);
    } else {
      String inverseCode = _calculateInverseCode(value);

      List<String> bits = inverseCode.split('');
      int carry = 1;

      for (int i = bits.length - 1; i > 0; i--) {
        if (bits[i] == '0' && carry == 1) {
          bits[i] = '1';
          carry = 0;
        } else if (bits[i] == '1' && carry == 1) {
          bits[i] = '0';
          carry = 1;
        }
      }

      return bits.join('');
    }
  }

  Future<void> copyToClipboard(String code) async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
    } catch (e) {
      ToastService.showErrorToast('复制失败：${e.toString()}');
    }
  }
}