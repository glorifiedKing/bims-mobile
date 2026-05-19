class LandTenure {
  final int id;
  final String name;

  LandTenure({required this.id, required this.name});

  factory LandTenure.fromJson(Map<String, dynamic> json) {
    return LandTenure(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
