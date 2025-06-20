class PromoModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final DateTime validUntil;
  final String code;

  PromoModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.validUntil,
    required this.code,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      validUntil:
          json['validUntil'] is DateTime
              ? json['validUntil']
              : DateTime.parse(json['validUntil']),
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'validUntil': validUntil.toIso8601String(),
      'code': code,
    };
  }

  bool get isValid => validUntil.isAfter(DateTime.now());

  String get validityText {
    final difference = validUntil.difference(DateTime.now());
    final days = difference.inDays;

    if (days == 0) {
      return 'Berakhir hari ini';
    } else if (days == 1) {
      return 'Berakhir besok';
    } else {
      return 'Berlaku ${days} hari lagi';
    }
  }
}
