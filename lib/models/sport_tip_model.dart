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

  // Returns appropriate image based on category if imageUrl is empty
  String getImage() {
    if (imageUrl.isNotEmpty) {
      return imageUrl;
    }

    // Default images based on category
    switch (category.toLowerCase()) {
      case 'futsal':
        return 'https://img.freepik.com/free-photo/soccer-players-action-professional-stadium_654080-1232.jpg';
      case 'badminton':
        return 'https://img.freepik.com/free-photo/badminton-concept-with-shuttlecock-racket_23-2149940874.jpg';
      case 'basket':
        return 'https://img.freepik.com/free-photo/basketball-game-action_654080-1542.jpg';
      case 'voli':
        return 'https://img.freepik.com/free-photo/volleyball-ball-net-beach_23-2148163841.jpg';
      case 'padel':
        return 'https://img.freepik.com/free-photo/tennis-padel-court-field-during-sunny-day_23-2149014156.jpg';
      case 'tenis':
        return 'https://img.freepik.com/free-photo/tennis-court-player_1150-14264.jpg';
      case 'pemanasan':
        return 'https://img.freepik.com/free-photo/woman-doing-warm-up-exercises-outdoor_23-2148770342.jpg';
      case 'nutrisi':
        return 'https://img.freepik.com/free-photo/top-view-vegetables-fruits-arrangement_23-2148991030.jpg';
      default:
        return 'https://img.freepik.com/free-photo/sports-tools_53876-138077.jpg';
    }
  }
}
