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
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      applicationTypeSlug: applicationTypeSlug,
    );
  }

  factory FormType.fromJsonFull(Map<String, dynamic> json) {
    return FormType(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      applicationTypeSlug:
          (json['application_type_slug'] ?? json['applicationTypeSlug'])
              ?.toString() ??
          '',
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

