import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/browser_provider.dart';
import '../widgets/address_bar.dart';
import '../widgets/browser_bottom_bar.dart';
import '../widgets/tab_switcher.dart';
import '../widgets/error_page.dart';
import '../widgets/loading_indicator.dart';
import '../services/ai_settings_service.dart';
import 'bookmarks_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'home_page.dart';
import 'view_source_screen.dart';

/// 浏览器主界面
class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  bool _showTabSwitcher = false;

  // 错误处理机制（已移除自动重试，避免死循环）
  final Map<String, int> _retryCount = {}; // URL -> 重试次数（保留用于追踪）
  final Map<String, String> _errorMessages = {}; // URL -> 错误信息
  final Map<String, bool> _isRetrying = {}; // URL -> 是否正在重试（保留用于状态管理）

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁止直接退出
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        body: SafeArea(
          child: _showTabSwitcher ? _buildTabSwitcher() : _buildBrowserView(),
        ),
      ),
    );
  }

  /// 处理物理返回键
  Future<void> _handleBackPressed() async {
    // 如果正在显示标签切换器，先关闭它
    if (_showTabSwitcher) {
      setState(() {
        _showTabSwitcher = false;
      });
      return;
    }

    final provider = Provider.of<BrowserProvider>(context, listen: false);
    final currentTab = provider.currentTab;

    if (currentTab != null && currentTab.controller != null) {
      // 检查 WebView 是否可以后退
      final canGoBack = await currentTab.controller!.canGoBack();

      if (canGoBack) {
        // WebView 后退
        await currentTab.controller!.goBack();
        return;
      }
    }

    // 如果不能后退，显示退出确认
    if (mounted) {
      final shouldExit = await _showExitConfirmDialog();
      if (shouldExit == true) {
        SystemNavigator.pop(); // 退出应用
      }
    }
  }

  /// 显示退出确认对话框
  Future<bool?> _showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出应用'),
        content: const Text('确定要退出明鉴浏览器吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return TabSwitcher(
      onClose: () {
        setState(() {
          _showTabSwitcher = false;
        });
      },
    );
  }

  Widget _buildBrowserView() {
    return Consumer<BrowserProvider>(
      builder: (context, provider, child) {
        final currentTab = provider.currentTab;

        if (currentTab == null) {
          return const Center(child: Text('没有打开的标签页'));
        }

        // 同时监听当前 tab 的变化
        return ListenableBuilder(
          listenable: currentTab,
          builder: (context, _) {
            return Column(
              children: [
                // 地址栏
                AddressBar(
                  tab: currentTab,
                  onMenuTap: () => _showMenu(context),
                  onTabSwitcherTap: () {
                    setState(() {
                      _showTabSwitcher = true;
                    });
                  },
                ),

                // 加载进度条
                if (currentTab.isLoading)
                  LinearProgressIndicator(
                    value: currentTab.loadingProgress / 100,
                    minHeight: 2,
                  ),

                // WebView
                Expanded(
                  child: _buildWebView(currentTab),
                ),

                // 底部工具栏
                BrowserBottomBar(tab: currentTab),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWebView(tab) {
    // 如果是新标签页且没有加载任何内容，显示主页
    if (tab.url == 'about:blank' || tab.url.isEmpty) {
      return HomePage(
        onSearch: (url) {
          // 更新 URL，ListenableBuilder 会自动监听变化并重建
          tab.updateUrl(url);
        },
      );
    }

    // 检查是否有加载错误
    final errorMessage = _errorMessages[tab.url];
    if (errorMessage != null) {
      return ErrorPage(
        errorMessage: errorMessage,
        url: tab.url,
        onRetry: () => _retryLoad(tab),
        onGoHome: () {
          tab.updateUrl('about:blank');
        },
      );
    }

    return FutureBuilder<WebViewController>(
      future: _createWebViewController(tab),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: const LoadingIndicator(),
          );
        }

        if (snapshot.hasError) {
          return ErrorPage(
            errorMessage: 'WebView 创建失败: ${snapshot.error}',
            url: tab.url,
            onRetry: () => _retryLoad(tab),
            onGoHome: () {
              tab.updateUrl('about:blank');
            },
          );
        }

        final controller = snapshot.data!;

        // 使用 Stack 同时显示 WebView 和加载动画
        return Stack(
          children: [
            WebViewWidget(
              key: ValueKey(tab.id),
              controller: controller,
            ),
            // 加载时显示动画
            if (tab.isLoading && tab.loadingProgress < 100)
              Container(
                color: Colors.white,
                child: const LoadingIndicator(),
              ),
          ],
        );
      },
    );
  }

  Future<WebViewController> _createWebViewController(tab) async {
    if (tab.controller != null) {
      return tab.controller!;
    }

    // 获取保存的 User Agent
    final userAgent = await AISettingsService.getUserAgent();

    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(
        tab.javaScriptEnabled
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 避免重复触发加载动画
            if (progress > 0 && progress < 100) {
              tab.updateLoadingProgress(progress);
            }
          },
          onPageStarted: (String url) {
            // 页面开始加载，清除之前的错误状态
            _errorMessages.remove(url);
            _retryCount.remove(url);
            _isRetrying.remove(url);

            // 只有在URL真正改变时才更新URL和进度
            if (tab.url != url) {
              tab.updateUrl(url);
            }
            tab.updateLoadingProgress(0);
            tab.setLoading(true);
          },
          onPageFinished: (String url) async {
            // 确保加载完成状态正确设置
            tab.updateLoadingProgress(100);
            tab.setLoading(false);

            // 页面加载成功，清除所有错误状态
            _retryCount.remove(url);
            _errorMessages.remove(url);
            _isRetrying.remove(url);

            // 获取页面标题
            final title = await controller.getTitle();
            tab.updateTitle(title ?? '无标题');

            // 更新导航状态
            final canGoBack = await controller.canGoBack();
            final canGoForward = await controller.canGoForward();
            tab.updateNavigationState(canGoBack, canGoForward);

            // 添加到历史记录
            if (mounted) {
              Provider.of<BrowserProvider>(context, listen: false)
                  .addHistory(title ?? '无标题', url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            // 只处理主资源的严重错误（忽略页面内的资源错误和次要错误）
            // 不再自动重试，避免死循环
            if (error.isForMainFrame == true) {
              // 只处理真正严重的错误
              if (error.errorType == WebResourceErrorType.hostLookup ||
                  error.errorType == WebResourceErrorType.connect ||
                  error.errorType == WebResourceErrorType.timeout) {
                _handleLoadError(tab, error);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(tab.url));

    tab.setController(controller);
    return controller;
  }

  /// 处理网页加载错误（仅显示错误，不自动重试）
  void _handleLoadError(tab, WebResourceError error) {
    final url = tab.url;
    debugPrint('网页加载错误 [$url]: ${error.description} (类型: ${error.errorType})');

    // 停止加载状态
    tab.setLoading(false);
    tab.updateLoadingProgress(0);

    // 保存错误信息，显示错误页面
    _errorMessages[url] = error.description;

    // 清除重试相关状态
    _retryCount.remove(url);
    _isRetrying.remove(url);

    // 触发重建以显示错误页面
    if (mounted) {
      setState(() {});
    }
  }

  /// 重试加载（手动重试）
  void _retryLoad(tab) async {
    final url = tab.url;

    // 清除所有错误状态
    _retryCount.remove(url);
    _errorMessages.remove(url);
    _isRetrying.remove(url);

    // 设置加载状态
    tab.setLoading(true);
    tab.updateLoadingProgress(0);

    // 重新加载
    if (tab.controller != null) {
      tab.controller!.reload();
    } else {
      // 如果没有 controller，重新创建
      final controller = await _createWebViewController(tab);
      tab.setController(controller);
    }

    setState(() {});
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMenuSheet(context),
    );
  }

  /// 查看网页源代码
  Future<void> _viewPageSource(BuildContext context, currentTab) async {
    Navigator.pop(context); // 关闭菜单

    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 获取源代码
      final sourceCode = await currentTab.getPageSource();

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载提示

        // 显示源代码页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSourceScreen(
              sourceCode: sourceCode,
              url: currentTab.url,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭加载提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 获取源代码失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 切换 JavaScript 开关
  void _toggleJavaScript(BuildContext context, currentTab, bool enabled) async {
    Navigator.pop(context); // 关闭菜单

    // 更新状态
    currentTab.setJavaScriptEnabled(enabled);

    // 清除旧的 controller，强制重新创建
    final currentUrl = currentTab.url;
    currentTab.setController(null);

    // 显示提示并自动刷新
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? '✅ JavaScript 已启用，正在刷新...' : '⚠️ JavaScript 已禁用，正在刷新...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // 触发重新加载（通过更新 URL 来触发 FutureBuilder 重建）
    currentTab.updateUrl(currentUrl);
    setState(() {});
  }

  Widget _buildMenuSheet(BuildContext context) {
    final provider = Provider.of<BrowserProvider>(context, listen: false);
    final currentTab = provider.currentTab;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('书签'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarksScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('历史记录'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          if (currentTab != null)
            FutureBuilder<bool>(
              future: provider.isBookmarked(currentTab.url),
              builder: (context, snapshot) {
                final isBookmarked = snapshot.data ?? false;
                return ListTile(
                  leading: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  title: Text(isBookmarked ? '取消收藏' : '添加书签'),
                  onTap: () async {
                    if (isBookmarked) {
                      final bookmark = provider.bookmarks.firstWhere(
                        (b) => b.url == currentTab.url,
                      );
                      await provider.removeBookmark(bookmark.id);
                    } else {
                      await provider.addBookmark(
                        currentTab.title,
                        currentTab.url,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBookmarked ? '已取消收藏' : '已添加到书签'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          const Divider(),
          // 查看网页源代码
          if (currentTab != null && currentTab.url != 'about:blank')
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('查看网页源代码'),
              onTap: () => _viewPageSource(context, currentTab),
            ),
          // JavaScript 开关
          if (currentTab != null)
            ListTile(
              leading: Icon(
                currentTab.javaScriptEnabled
                    ? Icons.javascript
                    : Icons.javascript_outlined,
              ),
              title: const Text('JavaScript'),
              trailing: Switch(
                value: currentTab.javaScriptEnabled,
                onChanged: (value) =>
                    _toggleJavaScript(context, currentTab, value),
              ),
              onTap: () => _toggleJavaScript(
                context,
                currentTab,
                !currentTab.javaScriptEnabled,
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
