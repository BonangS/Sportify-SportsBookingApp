class SportTipModel {
  final String id;
  final String category;
  final String title;
  final String imageUrl;
  final String content;

  SportTipModel({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  factory SportTipModel.fromJson(Map<String, dynamic> json) {
    return SportTipModel(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
    };
  }
}
