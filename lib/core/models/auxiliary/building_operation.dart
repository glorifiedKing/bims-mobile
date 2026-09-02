class BuildingOperation {
  final int id;
  final String name;

  BuildingOperation({required this.id, required this.name});

  factory BuildingOperation.fromJson(Map<String, dynamic> json) {
    return BuildingOperation(
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

