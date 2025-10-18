/// 搜索引擎模型
class SearchEngine {
  final String name;
  final String searchUrl;
  final String iconPath;
  final String homeUrl;

  const SearchEngine({
    required this.name,
    required this.searchUrl,
    required this.iconPath,
    required this.homeUrl,
  });

  /// 生成搜索URL
  String getSearchUrl(String query) {
    return searchUrl.replaceAll('{query}', Uri.encodeComponent(query));
  }
}

/// 预定义的搜索引擎
class SearchEngines {
  static const baidu = SearchEngine(
    name: '百度',
    searchUrl: 'https://www.baidu.com/s?wd={query}',
    iconPath: '🔍',
    homeUrl: 'https://www.baidu.com',
  );

  static const bing = SearchEngine(
    name: '必应',
    searchUrl: 'https://www.bing.com/search?q={query}',
    iconPath: 'Ⓑ',
    homeUrl: 'https://www.bing.com',
  );

  static const sogou = SearchEngine(
    name: '搜狗',
    searchUrl: 'https://www.sogou.com/web?query={query}',
    iconPath: '🐶',
    homeUrl: 'https://www.sogou.com',
  );

  static const google = SearchEngine(
    name: '谷歌',
    searchUrl: 'https://www.google.com/search?q={query}',
    iconPath: 'Ⓖ',
    homeUrl: 'https://www.google.com',
  );

  static const List<SearchEngine> all = [
    baidu,
    bing,
    sogou,
    google,
  ];

  static SearchEngine getByName(String name) {
    return all.firstWhere(
      (engine) => engine.name == name,
      orElse: () => baidu,
    );
  }
}
