class Pokemon {
  final String? name;
  final String? image;
  final List<String>? types;
  final int? height;
  final int? weight;
  final List<Map<String, dynamic>>? stats;

  Pokemon({
    this.name,
    this.image,
    this.types,
    this.height,
    this.weight,
    this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'] as String?,
      image: json['sprites']['front_default'] as String?,
      types: json['types'] != null
          ? List<String>.from(json['types'].map((t) => t['type']['name'] as String? ?? 'Unknown'))
          : null,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      stats: json['stats'] != null
          ? List<Map<String, dynamic>>.from(
              json['stats'].map(
                (s) => {
                  'name': s['stat']['name'] as String?,
                  'value': s['base_stat'] as int?,
                },
              ),
            )
          : null,
    );
  }
}