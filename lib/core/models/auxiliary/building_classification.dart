class BuildingClassification {
  final int id;
  final String name;

  BuildingClassification({required this.id, required this.name});

  factory BuildingClassification.fromJson(Map<String, dynamic> json) {
    return BuildingClassification(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
