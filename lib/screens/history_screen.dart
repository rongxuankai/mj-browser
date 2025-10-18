import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/browser_provider.dart';

/// 历史记录页面
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearDialog(context),
          ),
        ],
      ),
      body: Consumer<BrowserProvider>(
        builder: (context, provider, child) {
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无浏览历史',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final history = provider.history[index];
              final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.public,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(
                  history.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFormat.format(history.visitedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await provider.removeHistory(history.id);
                  },
                ),
                onTap: () {
                  provider.addNewTab(url: history.url);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史记录'),
        content: const Text('确定要清空所有浏览历史吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await Provider.of<BrowserProvider>(context, listen: false)
                  .clearHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已清空历史记录'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
