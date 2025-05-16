import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:pointycastle/export.dart' as pc;
import 'package:asn1lib/asn1lib.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../../../core/services/toast_service.dart';

enum JwtMode { encrypt, decrypt, verify }

class JwtToolViewModel extends ChangeNotifier {
  //当前模式
  JwtMode _selectedMode = JwtMode.encrypt;
  JwtMode get selectedMode => _selectedMode;
  set selectedMode(JwtMode value) {
    if (_selectedMode != value) {
      _selectedMode = value;
      _clearResult();
      notifyListeners();
    }
  }

  //算法
  String _selectedAlgorithm = 'HS256';
  String get selectedAlgorithm => _selectedAlgorithm;
  set selectedAlgorithm(String value) {
    if (_selectedAlgorithm != value) {
      _selectedAlgorithm = value;
      notifyListeners();
    }
  }

  //载荷JSON
  String _payloadJson = '';
  String get payloadJson => _payloadJson;
  set payloadJson(String value) {
    _payloadJson = value;
    notifyListeners();
  }

  //密钥（对称）
  String _secretKey = '';
  String get secretKey => _secretKey;
  set secretKey(String value) {
    _secretKey = value;
    notifyListeners();
  }

  //私钥（非对称）
  String _privateKey = '';
  String get privateKey => _privateKey;
  set privateKey(String value) {
    _privateKey = value;
    notifyListeners();
  }

  //公钥（非对称）
  String _publicKey = '';
  String get publicKey => _publicKey;
  set publicKey(String value) {
    _publicKey = value;
    notifyListeners();
  }

  //JWT令牌输入
  String _jwtToken = '';
  String get jwtToken => _jwtToken;
  set jwtToken(String value) {
    _jwtToken = value;
    _parseJwtToken(value);
    notifyListeners();
  }

  //解析后的header和payload
  String decodedHeader = '';
  String decodedPayload = '';

  bool hasExpirationClaim = false;
  DateTime? expirationTime;
  Color expirationColor = Colors.green;

  //结果显示
  bool hasResult = false;
  String resultTitle = '';
  String resultText = '';
  Color resultColor = Colors.green;

  //是否对称加密算法（HS）
  bool get isSymmetricAlgorithm => selectedAlgorithm.startsWith('HS');

  //是否非对称加密算法
  bool get isAsymmetricAlgorithm => !isSymmetricAlgorithm;

  bool get isEncryptMode => selectedMode == JwtMode.encrypt;
  bool get isDecryptMode => selectedMode == JwtMode.decrypt;
  bool get isVerifyMode => selectedMode == JwtMode.verify;

  String get actionButtonText {
    if (isDecryptMode) return '解析JWT令牌';
    if (isVerifyMode) return '验证JWT令牌';
    return '生成JWT令牌';
  }

  IconData get actionButtonIcon {
    if (isDecryptMode) return Icons.lock_open;
    if (isVerifyMode) return Icons.verified;
    return Icons.vpn_key;
  }

  JwtToolViewModel() {
    resetPayload();
    _secretKey = "this-is-a-very-secure-secret-key-with-sufficient-length-for-jwt-tokens";
  }

  void resetPayload() {
    final now = DateTime.now().toUtc();
    final exp = now.add(const Duration(hours: 1));
    final payload = {
      "role": "Hacker",
      "name": "MapleLeaf",
      "iat": now.millisecondsSinceEpoch ~/ 1000,
      "exp": exp.millisecondsSinceEpoch ~/ 1000,
    };
    _payloadJson = const JsonEncoder.withIndent('  ').convert(payload);
  }

  void _clearResult() {
    resultTitle = '';
    resultText = '';
    hasResult = false;
    decodedHeader = '';
    decodedPayload = '';
    hasExpirationClaim = false;
    expirationTime = null;
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null || data!.text!.isEmpty) {
      ToastService.showWarningToast('剪贴板为空');
      return;
    }
    final text = data.text!;

    _clearResult();

    if (isEncryptMode) {
      if (_isValidJson(text)) {
        payloadJson = _formatJson(text);
      } else {
        payloadJson = text;
      }
    } else {
      jwtToken = text;
    }
  }

  Future<void> copyResultToClipboard() async {
    if (!hasResult || resultText.isEmpty) {
      ToastService.showWarningToast('没有可复制的内容');
      return;
    }
    await Clipboard.setData(ClipboardData(text: resultText));
    ToastService.showWarningToast('已复制到剪贴板');
  }

  void clearAll() {
    if (isEncryptMode) {
      resetPayload();
      if (isSymmetricAlgorithm) {
        secretKey = "this-is-a-very-secure-secret-key-with-sufficient-length-for-jwt-tokens";
      } else {
        privateKey = '';
        publicKey = '';
      }
    } else {
      jwtToken = '';
      if (isSymmetricAlgorithm) {
        secretKey = '';
      } else {
        publicKey = '';
      }
      _clearResult();
    }
    notifyListeners();
  }

  void executeAction() {
    if (isEncryptMode) {
      _encryptJwt();
    } else if (isDecryptMode) {
      _decryptJwt();
    } else if (isVerifyMode) {
      _verifyJwt();
    }
  }

  void _encryptJwt() {
    if (!_isValidJson(payloadJson)) {
      _setResult("生成失败", "Payload不是有效的JSON格式", Colors.orange);
      return;
    }
    if (isSymmetricAlgorithm && secretKey.length < 32) {
      _setResult("生成失败", "密钥长度不足，至少32字节", Colors.orange);
      return;
    }
    if (isAsymmetricAlgorithm && privateKey.trim().isEmpty) {
      _setResult("生成失败", "请输入私钥", Colors.orange);
      return;
    }

    try {
      final payloadMap = json.decode(payloadJson);
      final jwt = JWT(payloadMap);

      String token;
      if (isSymmetricAlgorithm) {
        token = jwt.sign(SecretKey(secretKey), algorithm: _mapAlgorithm(selectedAlgorithm));
      } else {
        final key = RSAPrivateKey(privateKey);
        token = jwt.sign(key, algorithm: _mapAlgorithm(selectedAlgorithm));
      }
      _setResult("JWT生成成功", token, Colors.green);
    } catch (e) {
      _setResult("生成失败", "JWT生成异常: $e", Colors.red);
    }
  }

  void _decryptJwt() {
    if (jwtToken.trim().isEmpty) {
      _setResult("解析失败", "请输入JWT令牌", Colors.orange);
      return;
    }
    try {
      final jwt = JWT.decode(jwtToken);

      decodedHeader = const JsonEncoder.withIndent('  ').convert(jwt.header);
      decodedPayload = const JsonEncoder.withIndent('  ').convert(jwt.payload);

      if (jwt.payload.containsKey('exp')) {
        hasExpirationClaim = true;
        expirationTime = DateTime.fromMillisecondsSinceEpoch(jwt.payload['exp'] * 1000);
        expirationColor = expirationTime!.isBefore(DateTime.now()) ? Colors.red : Colors.green;
      } else {
        hasExpirationClaim = false;
        expirationTime = null;
      }

      _setResult("JWT解析成功", decodedPayload, Colors.green);
    } catch (e) {
      _setResult("解析失败", "JWT格式无效或解析错误: $e", Colors.red);
    }
  }

  void _verifyJwt() {
    if (jwtToken.trim().isEmpty) {
      _setResult("验证失败", "请输入JWT令牌", Colors.orange);
      return;
    }
    if (isSymmetricAlgorithm && secretKey.trim().isEmpty) {
      _setResult("验证失败", "请输入密钥", Colors.orange);
      return;
    }
    if (isAsymmetricAlgorithm && publicKey.trim().isEmpty) {
      _setResult("验证失败", "请输入公钥", Colors.orange);
      return;
    }

    try {
      JWT jwt;
      if (isSymmetricAlgorithm) {
        jwt = JWT.verify(jwtToken, SecretKey(secretKey));
      } else {
        final key = _parsePublicKey(selectedAlgorithm, publicKey);
        jwt = JWT.verify(jwtToken, key);
      }

      decodedHeader = const JsonEncoder.withIndent('  ').convert(jwt.header);
      decodedPayload = const JsonEncoder.withIndent('  ').convert(jwt.payload);

      _setResult("JWT验证成功", "该JWT令牌签名有效，可以信任", Colors.green);
      ToastService.showSuccessToast("JWT验证成功");
    } on JWTExpiredException {
      ToastService.showErrorToast("验证失败: JWT令牌已过期");
      _setResult("验证失败", "JWT令牌已过期", Colors.red);
    } on JWTException catch (ex) {
      ToastService.showErrorToast("验证失败: 签名无效: ${ex.message}");
      _setResult("验证失败", "签名无效: ${ex.message}", Colors.red);
    } catch (e) {
      ToastService.showErrorToast("验证失败: $e");
      _setResult("验证失败", "验证异常: $e", Colors.red);
    }
  }

  void _setResult(String title, String text, Color color) {
    resultTitle = title;
    resultText = text;
    resultColor = color;
    hasResult = true;
    notifyListeners();
  }

  bool _isValidJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _formatJson(String jsonStr) {
    try {
      final obj = json.decode(jsonStr);
      return const JsonEncoder.withIndent('  ').convert(obj);
    } catch (_) {
      return jsonStr;
    }
  }

  void _parseJwtToken(String token) {
    try {
      if (token.trim().isEmpty) {
        decodedHeader = '';
        decodedPayload = '';
        hasExpirationClaim = false;
        expirationTime = null;
        return;
      }
      final jwt = JWT.decode(token);
      decodedHeader = const JsonEncoder.withIndent('  ').convert(jwt.header);
      decodedPayload = const JsonEncoder.withIndent('  ').convert(jwt.payload);
      if (jwt.payload.containsKey('exp')) {
        hasExpirationClaim = true;
        expirationTime = DateTime.fromMillisecondsSinceEpoch(jwt.payload['exp'] * 1000);
        expirationColor = expirationTime!.isBefore(DateTime.now()) ? Colors.red : Colors.green;
      } else {
        hasExpirationClaim = false;
        expirationTime = null;
      }
    } catch (e) {
      decodedHeader = '';
      decodedPayload = '';
      hasExpirationClaim = false;
      expirationTime = null;
    }
  }

  JWTAlgorithm _mapAlgorithm(String alg) {
    switch (alg) {
      case 'HS256':
        return JWTAlgorithm.HS256;
      case 'HS384':
        return JWTAlgorithm.HS384;
      case 'HS512':
        return JWTAlgorithm.HS512;
      case 'RS256':
        return JWTAlgorithm.RS256;
      case 'RS384':
        return JWTAlgorithm.RS384;
      case 'RS512':
        return JWTAlgorithm.RS512;
      case 'ES256':
        return JWTAlgorithm.ES256;
      case 'ES384':
        return JWTAlgorithm.ES384;
      case 'ES512':
        return JWTAlgorithm.ES512;
      default:
        throw Exception('不支持的算法: $alg');
    }
  }

  dynamic _parsePrivateKey(String alg, String pem) {
    pem = pem.trim();
    if (alg.startsWith('RS')) {
      return RSAPrivateKey(pem);
    } else if (alg.startsWith('ES')) {
      return ECPrivateKey(pem);
    } else {
      throw Exception('不支持的非对称算法私钥解析: $alg');
    }
  }

  dynamic _parsePublicKey(String alg, String pem) {
    pem = pem.trim();
    if (alg.startsWith('RS')) {
      return RSAPublicKey(pem);
    } else if (alg.startsWith('ES')) {
      return ECPublicKey(pem);
    } else {
      throw Exception('不支持的非对称算法公钥解析: $alg');
    }
  }

  Future<pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>> generateRSAKeyPair({int bitLength = 2048}) async {
    final secureRandom = _getSecureRandom();

    final rsaParams = pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64);
    final params = pc.ParametersWithRandom(rsaParams, secureRandom);
    final keyGenerator = pc.RSAKeyGenerator();
    keyGenerator.init(params);
    return keyGenerator.generateKeyPair();
  }

  pc.SecureRandom _getSecureRandom() {
    final secureRandom = pc.FortunaRandom();
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(256));
    }
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  String encodePrivateKeyToPemPKCS1(pc.RSAPrivateKey privateKey) {
    final n = privateKey.n;
    final publicExponent = privateKey.publicExponent;
    final privateExponent = privateKey.privateExponent;
    final p = privateKey.p;
    final q = privateKey.q;

    if (n == null || publicExponent == null || privateExponent == null || p == null || q == null) {
      throw ArgumentError('RSAPrivateKey params cannot be null');
    }

    final topLevel = ASN1Sequence();
    topLevel.add(ASN1Integer(BigInt.zero));
    topLevel.add(ASN1Integer(n));
    topLevel.add(ASN1Integer(publicExponent));
    topLevel.add(ASN1Integer(privateExponent));
    topLevel.add(ASN1Integer(p));
    topLevel.add(ASN1Integer(q));
    topLevel.add(ASN1Integer(privateExponent % (p - BigInt.one)));
    topLevel.add(ASN1Integer(privateExponent % (q - BigInt.one)));
    topLevel.add(ASN1Integer(q.modInverse(p)));

    final dataBase64 = base64.encode(topLevel.encodedBytes);
    return '-----BEGIN RSA PRIVATE KEY-----\n${_chunked(dataBase64)}-----END RSA PRIVATE KEY-----\n';
  }

  String encodePublicKeyToPemPKCS1(pc.RSAPublicKey publicKey) {
    final n = publicKey.n;
    final exponent = publicKey.exponent;

    if (n == null || exponent == null) {
      throw ArgumentError('RSAPublicKey parameters cannot be null');
    }

    final topLevel = ASN1Sequence();
    topLevel.add(ASN1Integer(n));
    topLevel.add(ASN1Integer(exponent));

    final dataBase64 = base64.encode(topLevel.encodedBytes);
    return '-----BEGIN RSA PUBLIC KEY-----\n${_chunked(dataBase64)}-----END RSA PUBLIC KEY-----\n';
  }

  String _chunked(String str, {int chunkSize = 64}) {
    final chunks = <String>[];
    for (var i = 0; i < str.length; i += chunkSize) {
      chunks.add(str.substring(i, i + chunkSize > str.length ? str.length : i + chunkSize));
    }
    return '${chunks.join('\n')}\n';
  }
}