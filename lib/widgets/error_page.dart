import 'package:flutter/material.dart';

/// 自定义错误页面 - 符合应用UI风格
class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final String? url;
  final VoidCallback onRetry;
  final VoidCallback? onGoHome;

  const ErrorPage({
    super.key,
    required this.errorMessage,
    this.url,
    required this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface,
                ]
              : [
                  theme.colorScheme.errorContainer.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 错误图标
                _buildErrorIcon(theme),

                const SizedBox(height: 32),

                // 错误标题
                Text(
                  '网页加载失败',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // 错误描述
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getErrorDescription(errorMessage),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (url != null && url!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          url!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 操作按钮
                _buildActionButtons(theme),

                const SizedBox(height: 24),

                // 建议提示
                _buildSuggestions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.error.withOpacity(0.2),
            theme.colorScheme.error.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _getErrorIcon(errorMessage),
          size: 50,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // 重试按钮
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新加载'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ),

        if (onGoHome != null) ...[
          const SizedBox(height: 12),
          // 返回主页按钮
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: onGoHome,
              icon: const Icon(Icons.home_rounded),
              label: const Text('返回主页'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '建议',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getSuggestions().map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  IconData _getErrorIcon(String error) {
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('connection')) {
      return Icons.wifi_off_rounded;
    } else if (error.toLowerCase().contains('timeout')) {
      return Icons.access_time_rounded;
    } else if (error.toLowerCase().contains('not found') ||
        error.toLowerCase().contains('404')) {
      return Icons.search_off_rounded;
    } else {
      return Icons.error_outline_rounded;
    }
  }

  String _getErrorDescription(String error) {
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('internet') ||
        error.toLowerCase().contains('connection')) {
      return '网络连接失败，请检查您的网络设置';
    } else if (error.toLowerCase().contains('timeout')) {
      return '加载超时，服务器响应时间过长';
    } else if (error.toLowerCase().contains('not found') ||
        error.toLowerCase().contains('404')) {
      return '找不到该网页，网址可能已失效';
    } else if (error.toLowerCase().contains('host')) {
      return '无法解析该网址，请检查网址是否正确';
    } else {
      return '网页加载时发生错误';
    }
  }

  List<String> _getSuggestions() {
    return [
      '检查网络连接是否正常',
      '确认网址拼写是否正确',
      '尝试刷新页面或稍后重试',
      '清除浏览器缓存后重试',
    ];
  }
}
