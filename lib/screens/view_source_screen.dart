import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 查看网页源代码页面
class ViewSourceScreen extends StatelessWidget {
  final String sourceCode;
  final String url;

  const ViewSourceScreen({
    super.key,
    required this.sourceCode,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('查看源代码'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制全部',
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // URL 信息栏
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    url,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 源代码显示区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                sourceCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 复制源代码到剪贴板
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: sourceCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 源代码已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
