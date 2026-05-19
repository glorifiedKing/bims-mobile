class BuildingPurpose {
  final int id;
  final String name;

  BuildingPurpose({required this.id, required this.name});

  factory BuildingPurpose.fromJson(Map<String, dynamic> json) {
    return BuildingPurpose(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
