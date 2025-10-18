import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 全局错误处理器 - 针对 Android 15 闪退问题
class ErrorHandler {
  /// 初始化错误处理
  static void init() {
    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      // 开发模式下显示详细错误
      if (kDebugMode) {
        FlutterError.presentError(details);
      } else {
        // 生产模式下记录错误但不崩溃
        debugPrint('Flutter Error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      }
    };

    // 捕获异步错误
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Async Error: $error');
      debugPrint('Stack trace: $stack');
      return true; // 返回 true 表示已处理，不会导致应用崩溃
    };
  }

  /// 显示友好的错误提示
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// 安全执行异步操作
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    BuildContext? context,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      debugPrint('SafeAsync Error: $e');
      debugPrint('Stack trace: $stack');

      if (context != null && context.mounted) {
        showErrorSnackBar(
          context,
          errorMessage ?? '操作失败: ${e.toString()}',
        );
      }

      return null;
    }
  }

  /// 安全执行同步操作
  static T? safeSync<T>(
    T Function() operation, {
    String? errorMessage,
    BuildContext? context,
  }) {
    try {
      return operation();
    } catch (e, stack) {
      debugPrint('SafeSync Error: $e');
      debugPrint('Stack trace: $stack');

      if (context != null && context.mounted) {
        showErrorSnackBar(
          context,
          errorMessage ?? '操作失败: ${e.toString()}',
        );
      }

      return null;
    }
  }
}
