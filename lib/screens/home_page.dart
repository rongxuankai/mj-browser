import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/planet_animation.dart';

/// 浏览器主页 - 简约搜索界面
class HomePage extends StatefulWidget {
  final Function(String) onSearch;

  const HomePage({
    super.key,
    required this.onSearch,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedEngine = 'baidu'; // 默认百度

  // 搜索引擎配置
  final Map<String, Map<String, dynamic>> _searchEngines = {
    'baidu': {
      'name': '百度',
      'color': const Color(0xFF2932E1),
      'searchUrl': 'https://www.baidu.com/s?wd=',
      'homeUrl': 'https://www.baidu.com',
    },
    'bing': {
      'name': '必应',
      'color': const Color(0xFF008373),
      'searchUrl': 'https://www.bing.com/search?q=',
      'homeUrl': 'https://www.bing.com',
    },
    'sogou': {
      'name': '搜狗',
      'color': const Color(0xFFFF6A00),
      'searchUrl': 'https://www.sogou.com/web?query=',
      'homeUrl': 'https://www.sogou.com',
    },
    'google': {
      'name': '谷歌',
      'color': const Color(0xFF4285F4),
      'searchUrl': 'https://www.google.com/search?q=',
      'homeUrl': 'https://www.google.com',
    },
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    // 判断是URL还是搜索词
    String url;
    if (_isUrl(query)) {
      url = query.startsWith('http') ? query : 'https://$query';
    } else {
      // 使用选中的搜索引擎
      final searchUrl = _searchEngines[_selectedEngine]!['searchUrl'];
      url = '$searchUrl${Uri.encodeComponent(query)}';
    }

    widget.onSearch(url);
  }

  bool _isUrl(String text) {
    return text.contains('.') &&
        (text.startsWith('http') || !text.contains(' '));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentEngine = _searchEngines[_selectedEngine]!;

    return Scaffold(
      body: Container(
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
                    theme.colorScheme.primaryContainer.withOpacity(0.1),
                    theme.colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo 区域
                    _buildLogo(theme),

                    const SizedBox(height: 60),

                    // 搜索框
                    _buildSearchBox(theme, currentEngine),

                    const SizedBox(height: 24),

                    // 搜索引擎选择
                    _buildEngineSelector(theme),

                    const SizedBox(height: 40),

                    // 提示文字
                    Text(
                      '支持搜索或直接输入网址访问',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 80), // 为工具区域预留空间
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        // 星球动画图标
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7],
            ),
          ),
          child: const PlanetAnimation(size: 160),
        ),
        const SizedBox(height: 16),
        // 应用名称
        Text(
          '明鉴浏览器',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox(ThemeData theme, Map<String, dynamic> currentEngine) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _handleSearch(),
        decoration: InputDecoration(
          hintText: '搜索或输入网址',
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: currentEngine['color'],
              size: 28,
            ),
            onPressed: _handleSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
        style: theme.textTheme.bodyLarge,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildEngineSelector(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '搜索引擎',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _searchEngines.entries.map((entry) {
              final key = entry.key;
              final engine = entry.value;
              final isSelected = _selectedEngine == key;

              return _buildEngineChip(
                theme: theme,
                engine: engine,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedEngine = key;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineChip({
    required ThemeData theme,
    required Map<String, dynamic> engine,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (engine['color'] as Color).withOpacity(0.15)
                : theme.colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? engine['color']
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (engine['color'] as Color).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 彩色圆点指示器
              Container(
                width: isSelected ? 10 : 8,
                height: isSelected ? 10 : 8,
                decoration: BoxDecoration(
                  color: engine['color'],
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (engine['color'] as Color).withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                engine['name'],
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: isSelected ? 13 : 12,
                  color: isSelected
                      ? engine['color']
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
