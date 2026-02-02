class Channel {
  final String id;
  final String name;
  final String nameAr;
  final String logoUrl;
  final String streamUrl;
  final String category;

  const Channel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logoUrl,
    required this.streamUrl,
    required this.category,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      logoUrl: json['logoUrl'] as String,
      streamUrl: json['streamUrl'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'logoUrl': logoUrl,
      'streamUrl': streamUrl,
      'category': category,
    };
  }
}
