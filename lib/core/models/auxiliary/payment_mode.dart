class PaymentMode {
  final int id;
  final String name;
  final String description;

  PaymentMode({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
