import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 浏览器标签页模型
class TabModel extends ChangeNotifier {
  final String id;
  String title;
  String url;
  String favicon;
  bool isLoading;
  int loadingProgress;
  WebViewController? controller;
  bool canGoBack;
  bool canGoForward;
  bool javaScriptEnabled;

  TabModel({
    required this.id,
    this.title = '新标签页',
    this.url = 'https://www.baidu.com',
    this.favicon = '',
    this.isLoading = false,
    this.loadingProgress = 0,
    this.controller,
    this.canGoBack = false,
    this.canGoForward = false,
    this.javaScriptEnabled = true,
  });

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateUrl(String newUrl) {
    url = newUrl;
    notifyListeners();
  }

  void updateLoadingProgress(int progress) {
    loadingProgress = progress;
    isLoading = progress < 100;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    if (!loading) {
      loadingProgress = 100;
    }
    notifyListeners();
  }

  void updateNavigationState(bool back, bool forward) {
    canGoBack = back;
    canGoForward = forward;
    notifyListeners();
  }

  void setController(WebViewController? newController) {
    controller = newController;
    notifyListeners();
  }

  void setJavaScriptEnabled(bool enabled) {
    javaScriptEnabled = enabled;
    notifyListeners();
  }

  /// 提取页面内容（用于 AI 分析）
  Future<Map<String, String>> extractPageContent() async {
    if (controller == null) {
      return {
        'title': title,
        'content': '无法提取页面内容',
        'url': url,
      };
    }

    try {
      // 使用 JavaScript 提取页面内容
      final content = await controller!.runJavaScriptReturningResult('''
        (function() {
          // 获取页面标题
          var title = document.title || '';
          
          // 获取页面主要文本内容
          var body = document.body;
          if (!body) return JSON.stringify({title: title, content: '页面未加载完成'});
          
          // 移除脚本和样式标签
          var clone = body.cloneNode(true);
          var scripts = clone.getElementsByTagName('script');
          var styles = clone.getElementsByTagName('style');
          
          for (var i = scripts.length - 1; i >= 0; i--) {
            scripts[i].remove();
          }
          for (var i = styles.length - 1; i >= 0; i--) {
            styles[i].remove();
          }
          
          // 获取文本内容
          var text = clone.innerText || clone.textContent || '';
          
          // 清理多余空白
          text = text.replace(/\\s+/g, ' ').trim();
          
          // 限制长度（前 5000 字符）
          if (text.length > 5000) {
            text = text.substring(0, 5000);
          }
          
          return JSON.stringify({
            title: title,
            content: text
          });
        })();
      ''') as String;

      // 解析 JSON
      final contentStr = content.replaceAll('"', '').replaceAll("'", '');

      // 如果提取失败，返回基本信息
      if (contentStr.isEmpty || contentStr == 'null') {
        return {
          'title': title,
          'content': '页面内容提取中...',
          'url': url,
        };
      }

      return {
        'title': title,
        'content': contentStr,
        'url': url,
      };
    } catch (e) {
      debugPrint('提取页面内容失败: $e');
      return {
        'title': title,
        'content': '页面内容提取失败: $e',
        'url': url,
      };
    }
  }

  /// 获取网页源代码
  Future<String> getPageSource() async {
    if (controller == null) {
      return '无法获取源代码：WebView 未初始化';
    }

    try {
      final source = await controller!.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      ) as String;

      // 移除 JavaScript 返回的字符串引号
      if (source.startsWith('"') && source.endsWith('"')) {
        return source
            .substring(1, source.length - 1)
            .replaceAll(r'\"', '"')
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\t', '\t');
      }

      return source;
    } catch (e) {
      debugPrint('获取源代码失败: $e');
      return '获取源代码失败: $e';
    }
  }
}
