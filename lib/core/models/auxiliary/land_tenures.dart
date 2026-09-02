class LandTenure {
  final int id;
  final String name;

  LandTenure({required this.id, required this.name});

  factory LandTenure.fromJson(Map<String, dynamic> json) {
    return LandTenure(
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

