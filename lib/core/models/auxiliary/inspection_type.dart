class InspectionType {
  final int id;
  final String name;

  InspectionType({required this.id, required this.name});

  factory InspectionType.fromJson(Map<String, dynamic> json) {
    return InspectionType(
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

