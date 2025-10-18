import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark_model.dart';

/// 书签管理服务
class BookmarkService {
  static const String _bookmarksKey = 'bookmarks';

  /// 获取所有书签
  Future<List<BookmarkModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString(_bookmarksKey);

    if (bookmarksJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(bookmarksJson);
    return decoded.map((json) => BookmarkModel.fromJson(json)).toList();
  }

  /// 添加书签
  Future<void> addBookmark(BookmarkModel bookmark) async {
    final bookmarks = await getBookmarks();
    bookmarks.insert(0, bookmark);
    await _saveBookmarks(bookmarks);
  }

  /// 删除书签
  Future<void> removeBookmark(String id) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b.id == id);
    await _saveBookmarks(bookmarks);
  }

  /// 检查URL是否已被收藏
  Future<bool> isBookmarked(String url) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b.url == url);
  }

  /// 保存书签列表
  Future<void> _saveBookmarks(List<BookmarkModel> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(_bookmarksKey, encoded);
  }

  /// 清空所有书签
  Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }
}
