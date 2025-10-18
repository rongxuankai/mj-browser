import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/tab_model.dart';
import '../models/bookmark_model.dart';
import '../models/history_model.dart';
import '../services/bookmark_service.dart';
import '../services/history_service.dart';

/// 浏览器状态管理
class BrowserProvider extends ChangeNotifier {
  final List<TabModel> _tabs = [];
  int _currentTabIndex = 0;
  final BookmarkService _bookmarkService = BookmarkService();
  final HistoryService _historyService = HistoryService();
  List<BookmarkModel> _bookmarks = [];
  List<HistoryModel> _history = [];

  List<TabModel> get tabs => _tabs;
  int get currentTabIndex => _currentTabIndex;
  TabModel? get currentTab => _tabs.isEmpty ? null : _tabs[_currentTabIndex];
  List<BookmarkModel> get bookmarks => _bookmarks;
  List<HistoryModel> get history => _history;

  BrowserProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadBookmarks();
    await loadHistory();

    // 创建默认标签页
    if (_tabs.isEmpty) {
      addNewTab();
    }
  }

  /// 添加新标签页
  void addNewTab({String? url}) {
    final newTab = TabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url ?? 'about:blank', // 默认显示主页
    );
    _tabs.add(newTab);
    _currentTabIndex = _tabs.length - 1;
    notifyListeners();
  }

  /// 关闭标签页
  void closeTab(int index) {
    if (_tabs.length <= 1) {
      // 至少保留一个标签页
      return;
    }

    _tabs.removeAt(index);

    if (_currentTabIndex >= _tabs.length) {
      _currentTabIndex = _tabs.length - 1;
    }

    notifyListeners();
  }

  /// 切换标签页
  void switchTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  /// 加载书签
  Future<void> loadBookmarks() async {
    _bookmarks = await _bookmarkService.getBookmarks();
    notifyListeners();
  }

  /// 添加书签
  Future<void> addBookmark(String title, String url) async {
    final bookmark = BookmarkModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      createdAt: DateTime.now(),
    );
    await _bookmarkService.addBookmark(bookmark);
    await loadBookmarks();
  }

  /// 删除书签
  Future<void> removeBookmark(String id) async {
    await _bookmarkService.removeBookmark(id);
    await loadBookmarks();
  }

  /// 检查是否已收藏
  Future<bool> isBookmarked(String url) async {
    return await _bookmarkService.isBookmarked(url);
  }

  /// 加载历史记录
  Future<void> loadHistory() async {
    _history = await _historyService.getHistory();
    notifyListeners();
  }

  /// 添加历史记录
  Future<void> addHistory(String title, String url) async {
    final history = HistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      visitedAt: DateTime.now(),
    );
    await _historyService.addHistory(history);
    await loadHistory();
  }

  /// 删除历史记录
  Future<void> removeHistory(String id) async {
    await _historyService.removeHistory(id);
    await loadHistory();
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    await _historyService.clearHistory();
    await loadHistory();
  }

  /// 搜索历史记录
  Future<List<HistoryModel>> searchHistory(String query) async {
    return await _historyService.searchHistory(query);
  }
}
