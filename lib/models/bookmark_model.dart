/// 书签模型
class BookmarkModel {
  final String id;
  final String title;
  final String url;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
