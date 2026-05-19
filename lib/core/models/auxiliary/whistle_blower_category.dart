class WhistleBlowerCategory {
  final int id;
  final String name;

  WhistleBlowerCategory({required this.id, required this.name});

  factory WhistleBlowerCategory.fromJson(Map<String, dynamic> json) {
    return WhistleBlowerCategory(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
