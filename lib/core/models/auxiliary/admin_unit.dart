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
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      typeId: typeId,
      districtId: (json['districtId'] ?? json['dID'])?.toString() ?? '',
    );
  }

  factory AdminUnit.fromJsonFull(Map<String, dynamic> json) {
    return AdminUnit(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      typeId: json['typeId'] is int
          ? json['typeId'] as int
          : int.tryParse(json['typeId']?.toString() ?? '') ?? 0,
      districtId: (json['districtId'] ?? json['dID'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'typeId': typeId, 'districtId': districtId};
  }
}

