import 'package:flutter/material.dart';

@immutable
class ModuleItem {
  final String id;
  final String name;
  final IconData icon;
  final String viewType;
  final Map<String, dynamic>? params;

  const ModuleItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.viewType,
    this.params,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconData': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'viewType': viewType,
    'params': params,
  };

  factory ModuleItem.fromJson(Map<String, dynamic> json) {
    return ModuleItem(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['iconData'],
        fontFamily: json['iconFontFamily'],
      ),
      viewType: json['viewType'],
      params: json['params'],
    );
  }

  ModuleItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? viewType,
    Map<String, dynamic>? params,
  }) {
    return ModuleItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      viewType: viewType ?? this.viewType,
      params: params ?? this.params,
    );
  }
}
