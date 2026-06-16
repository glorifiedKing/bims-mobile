class InspectionStatus {
  final int id;
  final String name;

  InspectionStatus({required this.id, required this.name});

  factory InspectionStatus.fromJson(Map<String, dynamic> json) {
    return InspectionStatus(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
