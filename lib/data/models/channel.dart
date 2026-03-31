class Channel {
  final String id;
  final String name;
  final String nameAr;
  final String logoUrl;
  final String streamUrl;
  final String category;
  final String? slogan;
  final String? satellite;
  final String? frequency;
  final String? polarization;
  final String? symbolRate;
  final String? fec;

  const Channel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logoUrl,
    required this.streamUrl,
    required this.category,
    this.slogan,
    this.satellite,
    this.frequency,
    this.polarization,
    this.symbolRate,
    this.fec,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    // Generate mock satellite data based on channel ID or random for now
    // In a real app, this would come from the JSON
    
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      logoUrl: json['logoUrl'] as String,
      streamUrl: json['streamUrl'] as String,
      category: json['category'] as String,
      slogan: json['slogan'] as String?,
      // Mock data logic
      satellite: json['satellite'] as String? ?? 'Arabsat Badr 4',
      frequency: json['frequency'] as String? ?? '12563',
      polarization: json['polarization'] as String? ?? 'V',
      symbolRate: json['symbolRate'] as String? ?? '27500',
      fec: json['fec'] as String? ?? '5/6',
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
      'slogan': slogan,
      'satellite': satellite,
      'frequency': frequency,
      'polarization': polarization,
      'symbolRate': symbolRate,
      'fec': fec,
    };
  }
}
