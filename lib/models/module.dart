import 'package:flutter/material.dart';
import 'package:hackerkit_next/models/module_item.dart';

@immutable
class Module {
  final String id;
  final String name;
  final IconData icon;
  final List<ModuleItem> items;
  final String description;
  final bool isEnabled;

  const Module({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
    this.description = '',
    this.isEnabled = true,
  });

  //序列化支持
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconData': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'items': items.map((item) => item.toJson()).toList(),
    'description': description,
    'isEnabled': isEnabled,
  };

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['iconData'],
        fontFamily: json['iconFontFamily'],
      ),
      items: (json['items'] as List)
          .map((item) => ModuleItem.fromJson(item))
          .toList(),
      description: json['description'] ?? '',
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  //创建单项目模块
  factory Module.singleItem({
    required String id,
    required String name,
    required IconData icon,
    required String viewType,
    String description = '',
  }) {
    return Module(
      id: id,
      name: name,
      icon: icon,
      description: description,
      items: [
        ModuleItem(
          id: id,
          name: name,
          icon: icon,
          viewType: viewType,
        ),
      ],
    );
  }

  // 复制构造函数
  Module copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<ModuleItem>? items,
    String? description,
    bool? isEnabled,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      items: items ?? this.items,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}