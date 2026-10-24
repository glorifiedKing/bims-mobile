class DiscrepancyModel {
  final String ruleName;
  final String? clauseReference;
  final String? observedValue;
  final String? requiredValue;
  final String severity; // critical, high, medium, low, info
  final String description;
  final String? recommendation;
  final String? roomOrGrid;

  DiscrepancyModel({
    required this.ruleName,
    this.clauseReference,
    this.observedValue,
    this.requiredValue,
    required this.severity,
    required this.description,
    this.recommendation,
    this.roomOrGrid,
  });

  factory DiscrepancyModel.fromJson(Map<String, dynamic> json) {
    return DiscrepancyModel(
      ruleName:
          json['rule_name'] ??
          json['rule'] ??
          json['clause_title'] ??
          'Statutory Violation',
      clauseReference:
          json['clause_reference'] ?? json['clause'] ?? json['clause_number'],
      observedValue:
          json['observed_value']?.toString() ?? json['observed']?.toString(),
      requiredValue:
          json['required_value']?.toString() ?? json['required']?.toString(),
      severity: (json['severity'] ?? 'high').toString().toLowerCase(),
      description:
          json['description'] ??
          json['message'] ??
          'Non-compliance detected against Uganda Building Regulations',
      recommendation: json['recommendation'] ?? json['remedy'],
      roomOrGrid: json['room_or_grid'],
    );
  }

  Map<String, dynamic> toJson() => {
    'rule_name': ruleName,
    'clause_reference': clauseReference,
    'observed_value': observedValue,
    'required_value': requiredValue,
    'severity': severity,
    'description': description,
    'recommendation': recommendation,
    'room_or_grid': roomOrGrid,
  };
}

class QuickAuditModel {
  final String id;
  final String status; // pending, processing, completed, failed
  final String? overallStatus; // COMPLIANT, NON_COMPLIANT, PASS, FAIL, WARNING
  final String originalName;
  final String discipline;
  final String? occupancyClass;
  final double grossFloorAreaSqm;
  final double estimatedStatutoryFeeUgx;
  final String currency;
  final String? errorMessage;
  final Map<String, dynamic>? preflightMetrics;
  final Map<String, dynamic>? extractedGeometry;
  final Map<String, dynamic>? summaryMetrics;
  final List<DiscrepancyModel> discrepancies;
  final DateTime? analyzedAt;
  final DateTime? createdAt;

  QuickAuditModel({
    required this.id,
    required this.status,
    this.overallStatus,
    required this.originalName,
    required this.discipline,
    this.occupancyClass,
    this.grossFloorAreaSqm = 0.0,
    this.estimatedStatutoryFeeUgx = 0.0,
    this.currency = 'UGX',
    this.errorMessage,
    this.preflightMetrics,
    this.extractedGeometry,
    this.summaryMetrics,
    this.discrepancies = const [],
    this.analyzedAt,
    this.createdAt,
  });

  factory QuickAuditModel.fromJson(Map<String, dynamic> json) {
    List<DiscrepancyModel> discrepanciesList = [];
    if (json['discrepancies'] is List) {
      discrepanciesList = (json['discrepancies'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => DiscrepancyModel.fromJson(d))
          .toList();
    }

    return QuickAuditModel(
      id: (json['quick_audit_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      overallStatus: json['overall_status']?.toString(),
      originalName: json['original_name'] ?? 'Drawing Submission.pdf',
      discipline: (json['discipline'] ?? 'architectural').toString(),
      occupancyClass: json['occupancy_class'],
      grossFloorAreaSqm:
          (json['gross_floor_area_sqm'] as num?)?.toDouble() ?? 0.0,
      estimatedStatutoryFeeUgx:
          (json['estimated_statutory_fee_ugx'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'UGX',
      errorMessage: json['error_message'],
      preflightMetrics: json['preflight_metrics'] is Map<String, dynamic>
          ? json['preflight_metrics']
          : null,
      extractedGeometry: json['extracted_geometry'] is Map<String, dynamic>
          ? json['extracted_geometry']
          : null,
      summaryMetrics: json['summary_metrics'] is Map<String, dynamic>
          ? json['summary_metrics']
          : null,
      discrepancies: discrepanciesList,
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.tryParse(json['analyzed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  bool get isProcessing => status == 'pending' || status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCompliant {
    final s = (overallStatus ?? '').toUpperCase();
    return s == 'PASS' || s == 'COMPLIANT';
  }
}
