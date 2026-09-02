class ExpressPenaltyOffenceType {
  final int id;
  final String enactment;
  final String offenceName;
  final int currencyPoints;
  final bool chargePerSqm;

  ExpressPenaltyOffenceType({
    required this.id,
    required this.enactment,
    required this.offenceName,
    required this.currencyPoints,
    required this.chargePerSqm,
  });

  factory ExpressPenaltyOffenceType.fromJson(Map<String, dynamic> json) {
    return ExpressPenaltyOffenceType(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      enactment: json['enactment']?.toString() ?? '',
      offenceName: (json['offence_name'] ?? json['offenceName'])?.toString() ?? '',
      currencyPoints: json['currency_points'] is int
          ? json['currency_points'] as int
          : int.tryParse(json['currency_points']?.toString() ?? '') ?? 0,
      chargePerSqm: json['charge_per_sqm'] == true ||
          json['charge_per_sqm'] == 1 ||
          json['charge_per_sqm'] == '1' ||
          json['charge_per_sqm'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enactment': enactment,
      'offence_name': offenceName,
      'currency_points': currencyPoints,
      'charge_per_sqm': chargePerSqm,
    };
  }
}

