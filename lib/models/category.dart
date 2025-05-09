import 'package:flutter/material.dart';
import 'package:hackerkit_next/models/module.dart';

@immutable
class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<Module> modules;
  final bool isCollapsible;
  final Color? accentColor;
  final String description;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.modules,
    this.isCollapsible = true,
    this.accentColor,
    this.description = '',
  });

  //序列化支持
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconData': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'modules': modules.map((module) => module.toJson()).toList(),
    'isCollapsible': isCollapsible,
    'accentColor': accentColor?.value,
    'description': description,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['iconData'],
        fontFamily: json['iconFontFamily'],
      ),
      modules: (json['modules'] as List)
          .map((module) => Module.fromJson(module))
          .toList(),
      isCollapsible: json['isCollapsible'] ?? true,
      accentColor: json['accentColor'] != null
          ? Color(json['accentColor'])
          : null,
      description: json['description'] ?? '',
    );
  }

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<Module>? modules,
    bool? isCollapsible,
    Color? accentColor,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      modules: modules ?? this.modules,
      isCollapsible: isCollapsible ?? this.isCollapsible,
      accentColor: accentColor ?? this.accentColor,
      description: description ?? this.description,
    );
  }
}
