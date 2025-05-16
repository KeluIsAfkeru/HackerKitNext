import 'package:flutter/foundation.dart';
import 'package:hackerkit_next/core/update/sources/auto_source_by_proxy.dart';
import 'package:hackerkit_next/core/update/update_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sources/github_source.dart';
import 'sources/gitee_source.dart';

class UpdateSourceManager extends ChangeNotifier {
  static const String _prefsKey = 'selected_update_source';

  //仓库配置
  static const String _githubOwner = 'KeluIsAfkeru';
  static const String _githubRepo = 'HackerKitNext';
  static const String _giteeOwner = 'Afkeru';
  static const String _giteeRepo = 'hacker-kit-next_-release';

  //所有可用的更新源
  late final List<UpdateSource> _sources;

  //当前选中的源索引
  int _selectedIndex = 0;

  //代理状态
  bool _hasProxy = false;

  //构造函数-初始化源
  UpdateSourceManager() {
    //创建源实例
    final giteeSource = GiteeSource(
        owner: _giteeOwner,
        repo: _giteeRepo
    );

    final githubSource = GitHubSource(
        owner: _githubOwner,
        repo: _githubRepo
    );

    final autoSource = AutoSourceByProxy(
      giteeSource: giteeSource,
      githubSource: githubSource,
      proxyChecker: () => _hasProxy,
    );

    _sources = [
      autoSource,
      githubSource,
      giteeSource,
      //未来在这拓展更多的源
    ];
  }

  //获取所有可用源
  List<UpdateSource> get sources => List.unmodifiable(_sources);

  //获取当前选中的源
  UpdateSource get currentSource => _sources[_selectedIndex];

  //代理状态
  set hasProxy(bool value) {
    if (_hasProxy != value) {
      _hasProxy = value;
      notifyListeners();
    }
  }

  //获取代理状态
  bool get hasProxy => _hasProxy;

  //选择特定的源
  void selectSource(int index) {
    if (index >= 0 && index < _sources.length && _selectedIndex != index) {
      _selectedIndex = index;
      _saveSelection();
      notifyListeners();
    }
  }

  //通过ID选择源
  void selectSourceById(String id) {
    final index = _sources.indexWhere((source) => source.id == id);
    if (index != -1) {
      selectSource(index);
    }
  }

  //从首选项加载已保存的选择
  Future<void> loadSavedSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_prefsKey);

    if (savedId != null) {
      final index = _sources.indexWhere((source) => source.id == savedId);
      if (index != -1) {
        _selectedIndex = index;
        notifyListeners();
      }
    }
  }

  //保存当前选择到首选项
  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, currentSource.id);
  }
}