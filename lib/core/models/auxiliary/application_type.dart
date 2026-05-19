class ApplicationType {
  final int id;
  final String name;

  ApplicationType({required this.id, required this.name});

  factory ApplicationType.fromJson(Map<String, dynamic> json) {
    return ApplicationType(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
