class BuildingPurpose {
  final int id;
  final String name;

  BuildingPurpose({required this.id, required this.name});

  factory BuildingPurpose.fromJson(Map<String, dynamic> json) {
    return BuildingPurpose(
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

