import 'package:flutter/material.dart';
import 'package:hackerkit_next/models/category.dart';
import 'package:hackerkit_next/models/module.dart';
import 'package:hackerkit_next/models/module_item.dart';

///预定义的所有工具模块数据
class AppModules {
  //使用factory单例模式
  static final AppModules _instance = AppModules._internal();
  factory AppModules() => _instance;

  AppModules._internal();

  List<Category> get categories => [
    Category(
      id: 'hacker_tools',
      name: '嘿壳工具',
      icon: Icons.handyman,
      modules: [
        Module(
          id: 'protobuf',
          name: 'Protobuf编码解码',
          icon: Icons.code,
          items: [
            ModuleItem(
              id: 'protobuf_converter',
              name: 'Protobuf编码解码',
              icon: Icons.transform,
              viewType: 'ProtobufConverter',
            ),
          ],
        ),
        Module(
          id: 'qq_fake_file',
          name: 'QQ FakeFile生成',
          icon: Icons.attach_file,
          items: [
            ModuleItem(
              id: 'fake_file_generator',
              name: 'QQFakeFile生成',
              icon: Icons.attach_file,
              viewType: 'FakeFile',
            ),
          ],
        ),
      ],
    ),
    Category(
      id: 'digital_encoding',
      name: '数字编码',
      icon: Icons.code,
      accentColor: Colors.blue.shade700,
      modules: [
        Module(
          id: 'text_encoding',
          name: '文本编码',
          icon: Icons.data_object,
          items: [
            ModuleItem(
              id: 'text_encoding_converter',
              name: '文本编码',
              icon: Icons.translate,
              viewType: 'TextEncodingConverter',
            ),
          ],
        ),
        Module(
          id: 'base_converter',
          name: '进制转换 (单字节)',
          icon: Icons.swap_horiz,
          items: [
            ModuleItem(
              id: 'base_converter_tool',
              name: '进制转换 (单字节)',
              icon: Icons.swap_calls,
              viewType: 'BaseConverter',
            ),
          ],
        ),
        Module(
          id: 'binary_code_calculator',
          name: '原码/反码/补码计算',
          icon: Icons.calculate,
          items: [
            ModuleItem(
              id: 'binary_code_calculator_tool',
              name: '原码/反码/补码计算',
              icon: Icons.calculate,
              viewType: 'BinaryCodeCalculator',
            ),
          ],
        ),
        Module(
          id: 'jwt_parser',
          name: 'JWT解析器',
          icon: Icons.key,
          items: [
            ModuleItem(
              id: 'jwt_tool',
              name: 'JWT解析器',
              icon: Icons.vpn_key,
              viewType: 'JWTTool',
            ),
          ],
        ),
      ],
    ),
    Category(
      id: 'encryption',
      name: '加密解密',
      icon: Icons.lock,
      accentColor: Colors.purple.shade700,
      modules: [
        Module(
          id: 'aes_encryption',
          name: 'AES加密',
          icon: Icons.enhanced_encryption,
          items: [
            ModuleItem(
              id: 'aes_encryption_tool',
              name: 'AES加密',
              icon: Icons.security,
              viewType: 'AesEncryption',
            ),
            ModuleItem(
              id: 'md5_hash_tool',
              name: 'MD5哈希',
              icon: Icons.fingerprint,
              viewType: 'Md5Hash',
            ),
          ],
        ),
      ],
    ),
  ];
}
