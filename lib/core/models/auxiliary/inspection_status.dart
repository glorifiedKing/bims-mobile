class InspectionStatus {
  final int id;
  final String name;

  InspectionStatus({required this.id, required this.name});

  factory InspectionStatus.fromJson(Map<String, dynamic> json) {
    return InspectionStatus(
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

