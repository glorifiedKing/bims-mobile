class InspectionType {
  final int id;
  final String name;

  InspectionType({required this.id, required this.name});

  factory InspectionType.fromJson(Map<String, dynamic> json) {
    return InspectionType(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
