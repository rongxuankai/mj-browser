import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';

/// 书签页面
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书签'),
      ),
      body: Consumer<BrowserProvider>(
        builder: (context, provider, child) {
          if (provider.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有收藏任何书签',
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
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = provider.bookmarks[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  bookmark.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  bookmark.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await provider.removeBookmark(bookmark.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已删除书签'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
                onTap: () {
                  provider.addNewTab(url: bookmark.url);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
