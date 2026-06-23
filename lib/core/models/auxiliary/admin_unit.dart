class AdminUnit {
  final int id;
  final String name;
  final int typeId;
  final String districtId;

  AdminUnit({
    required this.id,
    required this.name,
    required this.typeId,
    required this.districtId,
  });

  factory AdminUnit.fromJson(Map<String, dynamic> json, int typeId) {
    return AdminUnit(
      id: json['id'],
      name: json['name'],
      typeId: typeId,
      districtId: json['districtId'],
    );
  }

  factory AdminUnit.fromJsonFull(Map<String, dynamic> json) {
    return AdminUnit(
      id: json['id'],
      name: json['name'],
      typeId: json['typeId'],
      districtId: json['districtId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'typeId': typeId, 'districtId': districtId};
  }
}
