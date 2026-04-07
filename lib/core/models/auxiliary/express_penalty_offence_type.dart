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
      id: json['id'],
      enactment: json['enactment'],
      offenceName: json['offence_name'],
      currencyPoints: json['currency_points'],
      chargePerSqm: json['charge_per_sqm'],
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
