class ProfessionalCounters {
  final int total;
  final int confirmed;
  final int unconfirmed;

  ProfessionalCounters({
    required this.total,
    required this.confirmed,
    required this.unconfirmed,
  });

  factory ProfessionalCounters.fromJson(Map<String, dynamic> json) {
    return ProfessionalCounters(
      total: json['total'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      unconfirmed: json['unconfirmed'] ?? 0,
    );
  }
}
