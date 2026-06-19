class ApplicationType {
  final int id;
  final String name;
  final String slug;

  ApplicationType({required this.id, required this.name, required this.slug});

  factory ApplicationType.fromJson(Map<String, dynamic> json) {
    return ApplicationType(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
