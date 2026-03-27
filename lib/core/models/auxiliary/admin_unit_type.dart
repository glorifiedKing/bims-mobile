class AdminUnitType {
  final int id;
  final String name;

  AdminUnitType({required this.id, required this.name});

  factory AdminUnitType.fromJson(Map<String, dynamic> json) {
    return AdminUnitType(
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
