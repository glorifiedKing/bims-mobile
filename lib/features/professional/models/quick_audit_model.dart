class DiscrepancyModel {
  final String ruleName;
  final String? clauseReference;
  final String? observedValue;
  final String? requiredValue;
  final String severity; // ERROR, WARNING, INFO
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

class RoomBreakdownModel {
  final String name;
  final double? areaSqm;

  RoomBreakdownModel({required this.name, this.areaSqm});

  factory RoomBreakdownModel.fromJson(Map<String, dynamic> json) {
    return RoomBreakdownModel(
      name: json['name']?.toString() ?? 'Room',
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'area_sqm': areaSqm};

  /// Helper to get a clean display name if the room name is prefixed like "[Basement Floor] Kitchen"
  String get cleanName {
    final bracketIndex = name.indexOf(']');
    if (bracketIndex != -1 && bracketIndex < name.length - 1) {
      return name.substring(bracketIndex + 1).trim();
    }
    return name.trim();
  }
}

class FloorMetricItemModel {
  final int? page;
  final String floorName;
  final double? grossFloorAreaSqm;
  final double? netInternalAreaSqm;
  final List<RoomBreakdownModel> roomBreakdown;

  FloorMetricItemModel({
    this.page,
    required this.floorName,
    this.grossFloorAreaSqm,
    this.netInternalAreaSqm,
    this.roomBreakdown = const [],
  });

  factory FloorMetricItemModel.fromJson(Map<String, dynamic> json) {
    List<RoomBreakdownModel> rooms = [];
    if (json['room_breakdown'] is List) {
      rooms = (json['room_breakdown'] as List)
          .whereType<Map<String, dynamic>>()
          .map((r) => RoomBreakdownModel.fromJson(r))
          .toList();
    }

    return FloorMetricItemModel(
      page: (json['page'] as num?)?.toInt(),
      floorName: json['floor_name']?.toString() ?? 'Floor',
      grossFloorAreaSqm: (json['gross_floor_area_sqm'] as num?)?.toDouble(),
      netInternalAreaSqm: (json['net_internal_area_sqm'] as num?)?.toDouble(),
      roomBreakdown: rooms,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'floor_name': floorName,
    'gross_floor_area_sqm': grossFloorAreaSqm,
    'net_internal_area_sqm': netInternalAreaSqm,
    'room_breakdown': roomBreakdown.map((r) => r.toJson()).toList(),
  };
}

class FloorAreaMetricsModel {
  final bool isFloorPlan;
  final double? grossFloorAreaSqm;
  final double? netInternalAreaSqm;
  final double? confidenceScore;
  final String? source;
  final int? cumulatedFloorsCount;
  final List<FloorMetricItemModel> floors;
  final List<RoomBreakdownModel> roomBreakdown;

  FloorAreaMetricsModel({
    this.isFloorPlan = false,
    this.grossFloorAreaSqm,
    this.netInternalAreaSqm,
    this.confidenceScore,
    this.source,
    this.cumulatedFloorsCount,
    this.floors = const [],
    this.roomBreakdown = const [],
  });

  factory FloorAreaMetricsModel.fromJson(Map<String, dynamic> json) {
    List<FloorMetricItemModel> floorsList = [];
    if (json['floors'] is List) {
      floorsList = (json['floors'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => FloorMetricItemModel.fromJson(f))
          .toList();
    }

    List<RoomBreakdownModel> roomsList = [];
    if (json['room_breakdown'] is List) {
      roomsList = (json['room_breakdown'] as List)
          .whereType<Map<String, dynamic>>()
          .map((r) => RoomBreakdownModel.fromJson(r))
          .toList();
    }

    return FloorAreaMetricsModel(
      isFloorPlan: json['is_floor_plan'] == true,
      grossFloorAreaSqm: (json['gross_floor_area_sqm'] as num?)?.toDouble(),
      netInternalAreaSqm: (json['net_internal_area_sqm'] as num?)?.toDouble(),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      source: json['source']?.toString(),
      cumulatedFloorsCount:
          (json['cumulated_floors_count'] as num?)?.toInt() ??
          (floorsList.isNotEmpty ? floorsList.length : null),
      floors: floorsList,
      roomBreakdown: roomsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_floor_plan': isFloorPlan,
    'gross_floor_area_sqm': grossFloorAreaSqm,
    'net_internal_area_sqm': netInternalAreaSqm,
    'confidence_score': confidenceScore,
    'source': source,
    'cumulated_floors_count': cumulatedFloorsCount,
    'floors': floors.map((f) => f.toJson()).toList(),
    'room_breakdown': roomBreakdown.map((r) => r.toJson()).toList(),
  };

  bool get hasFloors => floors.isNotEmpty;
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
  final FloorAreaMetricsModel? floorAreaMetrics;
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
    this.floorAreaMetrics,
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

    FloorAreaMetricsModel? floorMetrics;
    if (json['floor_area_metrics'] is Map<String, dynamic>) {
      floorMetrics = FloorAreaMetricsModel.fromJson(json['floor_area_metrics']);
    }

    return QuickAuditModel(
      id: (json['quick_audit_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      overallStatus: json['overall_status']?.toString(),
      originalName: json['original_name'] ?? 'Drawing Submission.pdf',
      discipline: (json['discipline'] ?? 'architectural').toString(),
      occupancyClass: json['occupancy_class'],
      grossFloorAreaSqm:
          (json['gross_floor_area_sqm'] as num?)?.toDouble() ??
          floorMetrics?.grossFloorAreaSqm ??
          0.0,
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
      floorAreaMetrics: floorMetrics,
      discrepancies: discrepanciesList,
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.tryParse(json['analyzed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'overall_status': overallStatus,
    'original_name': originalName,
    'discipline': discipline,
    'occupancy_class': occupancyClass,
    'gross_floor_area_sqm': grossFloorAreaSqm,
    'estimated_statutory_fee_ugx': estimatedStatutoryFeeUgx,
    'currency': currency,
    'error_message': errorMessage,
    'preflight_metrics': preflightMetrics,
    'extracted_geometry': extractedGeometry,
    'summary_metrics': summaryMetrics,
    'floor_area_metrics': floorAreaMetrics?.toJson(),
    'discrepancies': discrepancies.map((d) => d.toJson()).toList(),
    'analyzed_at': analyzedAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => !isCompleted && !isFailed;
  bool get isCompliant {
    final s = (overallStatus ?? '').toUpperCase();
    return s == 'PASS' || s == 'COMPLIANT';
  }

  bool get hasFloorAreaDetails =>
      (floorAreaMetrics != null &&
          (floorAreaMetrics!.hasFloors ||
              (floorAreaMetrics!.grossFloorAreaSqm != null &&
                  floorAreaMetrics!.grossFloorAreaSqm! > 0))) ||
      grossFloorAreaSqm > 0;
}
