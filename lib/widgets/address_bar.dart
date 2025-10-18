import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tab_model.dart';
import '../providers/browser_provider.dart';

/// 地址栏组件
class AddressBar extends StatefulWidget {
  final TabModel tab;
  final VoidCallback onMenuTap;
  final VoidCallback onTabSwitcherTap;

  const AddressBar({
    super.key,
    required this.tab,
    required this.onMenuTap,
    required this.onTabSwitcherTap,
  });

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tab.url);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() {
          _isEditing = false;
          _controller.text = widget.tab.url;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.tab.url != _controller.text) {
      _controller.text = widget.tab.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 刷新按钮
          IconButton(
            icon: Icon(
              widget.tab.isLoading ? Icons.close : Icons.refresh,
              color: colorScheme.primary,
            ),
            onPressed: () {
              // WebViewController 不支持stop，直接使用reload
              widget.tab.controller?.reload();
            },
          ),

          // 地址输入框
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEditing = true;
                  _focusNode.requestFocus();
                  _controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controller.text.length,
                  );
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSecurityIcon(),
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: '搜索或输入网址',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        onSubmitted: _loadUrl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 标签页切换按钮
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.tab, color: colorScheme.primary),
                Positioned(
                  bottom: 4,
                  child: Text(
                    '${Provider.of<BrowserProvider>(context).tabs.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: widget.onTabSwitcherTap,
          ),

          // 菜单按钮
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.primary),
            onPressed: widget.onMenuTap,
          ),
        ],
      ),
    );
  }

  IconData _getSecurityIcon() {
    if (widget.tab.url.startsWith('https://')) {
      return Icons.lock;
    } else if (widget.tab.url.startsWith('http://')) {
      return Icons.info_outline;
    }
    return Icons.search;
  }

  void _loadUrl(String input) {
    String url = input.trim();

    if (url.isEmpty) {
      return;
    }

    // 判断是搜索还是URL
    if (!url.contains('.') || url.contains(' ')) {
      // 使用百度搜索
      url = 'https://www.baidu.com/s?wd=${Uri.encodeComponent(url)}';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    widget.tab.controller?.loadRequest(Uri.parse(url));
    _focusNode.unfocus();
    setState(() {
      _isEditing = false;
    });
  }
}
