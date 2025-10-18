import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

/// 历史记录管理服务
class HistoryService {
  static const String _historyKey = 'history';
  static const int _maxHistoryItems = 500;

  /// 获取所有历史记录
  Future<List<HistoryModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);

    if (historyJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((json) => HistoryModel.fromJson(json)).toList();
  }

  /// 添加历史记录
  Future<void> addHistory(HistoryModel history) async {
    final historyList = await getHistory();

    // 移除重复的URL（保留最新访问）
    historyList.removeWhere((h) => h.url == history.url);

    // 插入到开头
    historyList.insert(0, history);

    // 限制历史记录数量
    if (historyList.length > _maxHistoryItems) {
      historyList.removeRange(_maxHistoryItems, historyList.length);
    }

    await _saveHistory(historyList);
  }

  /// 删除历史记录
  Future<void> removeHistory(String id) async {
    final historyList = await getHistory();
    historyList.removeWhere((h) => h.id == id);
    await _saveHistory(historyList);
  }

  /// 搜索历史记录
  Future<List<HistoryModel>> searchHistory(String query) async {
    final historyList = await getHistory();
    return historyList.where((h) {
      return h.title.toLowerCase().contains(query.toLowerCase()) ||
          h.url.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// 保存历史记录列表
  Future<void> _saveHistory(List<HistoryModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(history.map((h) => h.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  /// 清空所有历史记录
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
