import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';

/// 标签页切换器
class TabSwitcher extends StatelessWidget {
  final VoidCallback onClose;

  const TabSwitcher({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('标签页'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Provider.of<BrowserProvider>(context, listen: false).addNewTab();
              onClose();
            },
          ),
        ],
      ),
      body: Consumer<BrowserProvider>(
        builder: (context, provider, child) {
          if (provider.tabs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tab,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有打开的标签页',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      provider.addNewTab();
                      onClose();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新建标签页'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: provider.tabs.length,
            itemBuilder: (context, index) {
              final tab = provider.tabs[index];
              final isCurrent = index == provider.currentTabIndex;

              return GestureDetector(
                onTap: () {
                  provider.switchTab(index);
                  onClose();
                },
                child: Card(
                  elevation: isCurrent ? 4 : 1,
                  color: isCurrent
                      ? colorScheme.primaryContainer
                      : colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 关闭按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              provider.closeTab(index);
                              if (provider.tabs.isEmpty) {
                                onClose();
                              }
                            },
                          ),
                        ],
                      ),

                      // 标题和URL
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tab.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isCurrent
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tab.url,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCurrent
                                      ? colorScheme.onPrimaryContainer
                                          .withOpacity(0.7)
                                      : colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
