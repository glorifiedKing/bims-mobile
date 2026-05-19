class BuildingOperation {
  final int id;
  final String name;

  BuildingOperation({required this.id, required this.name});

  factory BuildingOperation.fromJson(Map<String, dynamic> json) {
    return BuildingOperation(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
