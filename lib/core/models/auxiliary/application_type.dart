class ApplicationType {
  final int id;
  final String name;
  final String slug;

  ApplicationType({required this.id, required this.name, required this.slug});

  factory ApplicationType.fromJson(Map<String, dynamic> json) {
    return ApplicationType(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}

