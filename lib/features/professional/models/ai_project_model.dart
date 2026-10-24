import 'quick_audit_model.dart';

class AiComplianceResultModel {
  final String? id;
  final String overallStatus; // PASS, FAIL, WARNING, COMPLIANT, NON_COMPLIANT
  final double grossFloorAreaSqm;
  final double estimatedStatutoryFeeUgx;
  final Map<String, dynamic>? preflightMetrics;
  final Map<String, dynamic>? summaryMetrics;
  final List<DiscrepancyModel> discrepancies;
  final DateTime? analyzedAt;

  AiComplianceResultModel({
    this.id,
    required this.overallStatus,
    this.grossFloorAreaSqm = 0.0,
    this.estimatedStatutoryFeeUgx = 0.0,
    this.preflightMetrics,
    this.summaryMetrics,
    this.discrepancies = const [],
    this.analyzedAt,
  });

  factory AiComplianceResultModel.fromJson(Map<String, dynamic> json) {
    List<DiscrepancyModel> discrepanciesList = [];
    if (json['discrepancies'] is List) {
      discrepanciesList = (json['discrepancies'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => DiscrepancyModel.fromJson(d))
          .toList();
    }

    return AiComplianceResultModel(
      id: json['id']?.toString(),
      overallStatus: (json['overall_status'] ?? 'PENDING').toString().toUpperCase(),
      grossFloorAreaSqm: (json['gross_floor_area_sqm'] as num?)?.toDouble() ?? 0.0,
      estimatedStatutoryFeeUgx: (json['estimated_statutory_fee_ugx'] as num?)?.toDouble() ?? 0.0,
      preflightMetrics: json['preflight_metrics'] is Map<String, dynamic> ? json['preflight_metrics'] : null,
      summaryMetrics: json['summary_metrics'] is Map<String, dynamic> ? json['summary_metrics'] : null,
      discrepancies: discrepanciesList,
      analyzedAt: json['analyzed_at'] != null ? DateTime.tryParse(json['analyzed_at']) : null,
    );
  }

  bool get isPass => overallStatus == 'PASS' || overallStatus == 'COMPLIANT';
  bool get isFail => overallStatus == 'FAIL' || overallStatus == 'NON_COMPLIANT';
  bool get isWarning => overallStatus == 'WARNING';
}

class AiDrawingVersionModel {
  final String id;
  final String drawingId;
  final int versionNumber;
  final String fileName;
  final String? originalName;
  final int? fileSizeBytes;
  final String status; // pending, processing, completed, failed
  final AiComplianceResultModel? complianceResult;
  final DateTime? createdAt;

  AiDrawingVersionModel({
    required this.id,
    required this.drawingId,
    required this.versionNumber,
    required this.fileName,
    this.originalName,
    this.fileSizeBytes,
    required this.status,
    this.complianceResult,
    this.createdAt,
  });

  factory AiDrawingVersionModel.fromJson(Map<String, dynamic> json) {
    return AiDrawingVersionModel(
      id: (json['id'] ?? '').toString(),
      drawingId: (json['drawing_id'] ?? '').toString(),
      versionNumber: (json['version_number'] as num?)?.toInt() ?? 1,
      fileName: json['file_name'] ?? '',
      originalName: json['original_name'],
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      complianceResult: json['compliance_result'] is Map<String, dynamic>
          ? AiComplianceResultModel.fromJson(json['compliance_result'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}

class AiDrawingModel {
  final String id;
  final String floorId;
  final String discipline; // architectural, structural, mechanical, electrical
  final AiDrawingVersionModel? currentVersion;
  final List<AiDrawingVersionModel> versions;

  AiDrawingModel({
    required this.id,
    required this.floorId,
    required this.discipline,
    this.currentVersion,
    this.versions = const [],
  });

  factory AiDrawingModel.fromJson(Map<String, dynamic> json) {
    List<AiDrawingVersionModel> vList = [];
    if (json['versions'] is List) {
      vList = (json['versions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((v) => AiDrawingVersionModel.fromJson(v))
          .toList();
    }

    return AiDrawingModel(
      id: (json['id'] ?? '').toString(),
      floorId: (json['floor_id'] ?? '').toString(),
      discipline: (json['discipline'] ?? '').toString().toLowerCase(),
      currentVersion: json['current_version'] is Map<String, dynamic>
          ? AiDrawingVersionModel.fromJson(json['current_version'])
          : null,
      versions: vList,
    );
  }
}

class AiFloorModel {
  final String id;
  final String blockId;
  final int floorNumber;
  final String name;
  final double floorAreaSqm;
  final List<AiDrawingModel> drawings;

  AiFloorModel({
    required this.id,
    required this.blockId,
    required this.floorNumber,
    required this.name,
    this.floorAreaSqm = 0.0,
    this.drawings = const [],
  });

  factory AiFloorModel.fromJson(Map<String, dynamic> json) {
    List<AiDrawingModel> dList = [];
    if (json['drawings'] is List) {
      dList = (json['drawings'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => AiDrawingModel.fromJson(d))
          .toList();
    }

    return AiFloorModel(
      id: (json['id'] ?? '').toString(),
      blockId: (json['block_id'] ?? '').toString(),
      floorNumber: (json['floor_number'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? 'Floor',
      floorAreaSqm: (json['floor_area_sqm'] as num?)?.toDouble() ?? 0.0,
      drawings: dList,
    );
  }

  AiDrawingModel? getDrawingForDiscipline(String discipline) {
    try {
      return drawings.firstWhere((d) => d.discipline.toLowerCase() == discipline.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}

class AiBlockModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final double totalFloorAreaSqm;
  final List<AiFloorModel> floors;

  AiBlockModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.totalFloorAreaSqm = 0.0,
    this.floors = const [],
  });

  factory AiBlockModel.fromJson(Map<String, dynamic> json) {
    List<AiFloorModel> fList = [];
    if (json['floors'] is List) {
      fList = (json['floors'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => AiFloorModel.fromJson(f))
          .toList();
    }

    return AiBlockModel(
      id: (json['id'] ?? '').toString(),
      projectId: (json['project_id'] ?? '').toString(),
      name: json['name'] ?? 'Main Block',
      description: json['description'],
      totalFloorAreaSqm: (json['total_floor_area_sqm'] as num?)?.toDouble() ?? 0.0,
      floors: fList,
    );
  }
}

class AiProjectModel {
  final String id;
  final String? ownerId;
  final String name;
  final String referenceNumber;
  final String occupancyClass;
  final String shareToken;
  final String status; // draft, in_progress, compliant, non_compliant
  final bool isPublic;
  final double totalFloorAreaSqm;
  final double estimatedStatutoryFeeUgx;
  final int blocksCount;
  final List<AiBlockModel> blocks;
  final Map<String, dynamic>? owner;
  final List<Map<String, dynamic>> collaborators;
  final DateTime? createdAt;

  AiProjectModel({
    required this.id,
    this.ownerId,
    required this.name,
    required this.referenceNumber,
    required this.occupancyClass,
    required this.shareToken,
    this.status = 'draft',
    this.isPublic = false,
    this.totalFloorAreaSqm = 0.0,
    this.estimatedStatutoryFeeUgx = 0.0,
    this.blocksCount = 0,
    this.blocks = const [],
    this.owner,
    this.collaborators = const [],
    this.createdAt,
  });

  factory AiProjectModel.fromJson(Map<String, dynamic> json) {
    List<AiBlockModel> bList = [];
    if (json['blocks'] is List) {
      bList = (json['blocks'] as List)
          .whereType<Map<String, dynamic>>()
          .map((b) => AiBlockModel.fromJson(b))
          .toList();
    }

    List<Map<String, dynamic>> cList = [];
    if (json['collaborators'] is List) {
      cList = (json['collaborators'] as List).whereType<Map<String, dynamic>>().toList();
    }

    return AiProjectModel(
      id: (json['id'] ?? '').toString(),
      ownerId: json['owner_id']?.toString(),
      name: json['name'] ?? 'Untitled Project',
      referenceNumber: json['reference_number'] ?? 'NBRB-PROJ',
      occupancyClass: json['occupancy_class'] ?? 'Class A (Residential)',
      shareToken: json['share_token'] ?? '',
      status: (json['status'] ?? 'draft').toString().toLowerCase(),
      isPublic: json['is_public'] == true,
      totalFloorAreaSqm: (json['total_floor_area_sqm'] as num?)?.toDouble() ?? 0.0,
      estimatedStatutoryFeeUgx: (json['estimated_statutory_fee_ugx'] as num?)?.toDouble() ?? 0.0,
      blocksCount: (json['blocks_count'] as num?)?.toInt() ?? bList.length,
      blocks: bList,
      owner: json['owner'] is Map<String, dynamic> ? json['owner'] : null,
      collaborators: cList,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
