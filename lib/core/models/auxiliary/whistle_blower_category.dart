class WhistleBlowerCategory {
  final int id;
  final String name;

  WhistleBlowerCategory({required this.id, required this.name});

  factory WhistleBlowerCategory.fromJson(Map<String, dynamic> json) {
    return WhistleBlowerCategory(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

