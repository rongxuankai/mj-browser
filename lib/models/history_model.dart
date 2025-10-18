/// 历史记录模型
class HistoryModel {
  final String id;
  final String title;
  final String url;
  final DateTime visitedAt;

  HistoryModel({
    required this.id,
    required this.title,
    required this.url,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'visitedAt': visitedAt.toIso8601String(),
    };
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      visitedAt: DateTime.parse(json['visitedAt']),
    );
  }
}
