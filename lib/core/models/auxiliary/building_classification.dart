class BuildingClassification {
  final int id;
  final String name;

  BuildingClassification({required this.id, required this.name});

  factory BuildingClassification.fromJson(Map<String, dynamic> json) {
    return BuildingClassification(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

