import 'package:flutter/material.dart';
import '../models/tab_model.dart';
import 'ai_analysis_sheet.dart';
import 'qr_share_dialog.dart';

/// 浏览器底部工具栏
class BrowserBottomBar extends StatelessWidget {
  final TabModel tab;

  const BrowserBottomBar({
    super.key,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 后退按钮
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(
                  Icons.arrow_back,
                  color: tab.canGoBack
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                onPressed:
                    tab.canGoBack ? () => tab.controller?.goBack() : null,
              ),

              // 前进按钮
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  color: tab.canGoForward
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                onPressed:
                    tab.canGoForward ? () => tab.controller?.goForward() : null,
              ),

              // 主页按钮 - 返回搜索页面
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(Icons.home, color: colorScheme.primary),
                onPressed: () {
                  // 返回到搜索页面（about:blank）
                  tab.updateUrl('about:blank');
                },
              ),

              // 分享按钮
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(Icons.share, color: colorScheme.primary),
                onPressed: () => _shareUrl(context, tab.url),
              ),

              // AI 分析按钮
              IconButton(
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(Icons.psychology, color: colorScheme.secondary),
                onPressed: () => _showAIAnalysis(context),
                tooltip: 'AI 分析',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareUrl(BuildContext context, String url) {
    // 显示二维码分享对话框
    showDialog(
      context: context,
      builder: (context) => QrShareDialog(
        url: url,
        title: tab.title,
      ),
    );
  }

  /// 显示 AI 分析面板
  Future<void> _showAIAnalysis(BuildContext context) async {
    // 检查是否是主页
    if (tab.url == 'about:blank') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💡 请先浏览网页，AI 才能分析内容哦'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 提取页面内容
      final pageData = await tab.extractPageContent();

      // 关闭加载提示
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 显示 AI 分析面板
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AIAnalysisSheet(
            pageTitle: pageData['title'] ?? '',
            pageContent: pageData['content'] ?? '',
            pageUrl: pageData['url'] ?? '',
          ),
        );
      }
    } catch (e) {
      // 关闭加载提示
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 显示错误
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 提取页面内容失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
