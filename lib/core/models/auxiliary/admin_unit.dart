class AdminUnit {
  final int id;
  final String name;
  final int typeId;

  AdminUnit({
    required this.id,
    required this.name,
    required this.typeId,
  });

  factory AdminUnit.fromJson(Map<String, dynamic> json, int typeId) {
    return AdminUnit(
      id: json['id'],
      name: json['name'],
      typeId: typeId,
    );
  }

  factory AdminUnit.fromJsonFull(Map<String, dynamic> json) {
    return AdminUnit(
      id: json['id'],
      name: json['name'],
      typeId: json['typeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
    };
  }
}
