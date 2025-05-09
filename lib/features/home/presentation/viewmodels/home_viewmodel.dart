import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hackerkit_next/core/data/modules_data.dart';
import 'package:hackerkit_next/models/category.dart';
import 'package:hackerkit_next/models/module.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Category> _categories = AppModules().categories;
  final Map<String, bool> _expandedCategories = {};
  String? _selectedModuleId;
  bool _sidebarExpanded = false;

  HomeViewModel() {
    _sidebarExpanded = false;
    _loadState();
  }

  //公开访问器
  List<Category> get categories => _categories;
  bool get isSidebarExpanded => _sidebarExpanded;
  String? get selectedModuleId => _selectedModuleId;

  bool isCategoryExpanded(String categoryId) => _expandedCategories[categoryId] ?? false;
  bool isModuleSelected(String moduleId) => _selectedModuleId == moduleId;

  Module? getModuleById(String id) {
    for (var category in _categories) {
      for (var module in category.modules) {
        if (module.id == id) return module;
      }
    }
    return null;
  }

  //状态管理方法
  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    _saveState();
    notifyListeners();
  }

  void toggleCategory(String categoryId) {
    _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    _saveState();
    notifyListeners();
  }

  void expandCategory(String categoryId) {
    //重置所有分类为收起状态
    for (var id in _expandedCategories.keys.toList()) {
      _expandedCategories[id] = false;
    }

    //展开选中的分类
    _expandedCategories[categoryId] = true;

    //确保侧边栏展开
    _sidebarExpanded = true;

    _saveState();
    notifyListeners();
  }

  void selectModule(String moduleId) {
    _selectedModuleId = moduleId;

    //自动展开所属分类
    for (var category in _categories) {
      for (var module in category.modules) {
        if (module.id == moduleId) {
          _expandedCategories[category.id] = true;
          break;
        }
      }
    }

    _saveState();
    notifyListeners();
  }

  //状态持久化
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      //读取已展开的分类
      final expandedList = prefs.getStringList('expanded_categories') ?? [];
      for (var id in expandedList) {
        _expandedCategories[id] = true;
      }

      _selectedModuleId = prefs.getString('selected_module_id');
      _sidebarExpanded = prefs.getBool('sidebar_expanded') ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('加载状态失败: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      //保存已展开的分类
      final expandedList = _expandedCategories.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await prefs.setStringList('expanded_categories', expandedList);

      if (_selectedModuleId != null) {
        await prefs.setString('selected_module_id', _selectedModuleId!);
      }

      await prefs.setBool('sidebar_expanded', _sidebarExpanded);
    } catch (e) {
      debugPrint('保存状态失败: $e');
    }
  }
}