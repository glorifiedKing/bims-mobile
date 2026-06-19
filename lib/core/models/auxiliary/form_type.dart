class FormType {
  final int id;
  final String name;
  final String applicationTypeSlug;

  FormType({
    required this.id,
    required this.name,
    required this.applicationTypeSlug,
  });

  factory FormType.fromJson(
    Map<String, dynamic> json,
    String applicationTypeSlug,
  ) {
    return FormType(
      id: json['id'] as int,
      name: json['name'] as String,
      applicationTypeSlug: applicationTypeSlug,
    );
  }

  factory FormType.fromJsonFull(Map<String, dynamic> json) {
    return FormType(
      id: json['id'],
      name: json['name'],
      applicationTypeSlug: json['application_type_slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'application_type_slug': applicationTypeSlug,
    };
  }
}
