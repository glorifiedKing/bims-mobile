import 'quick_audit_model.dart';

class AiProjectModel {
  final String id;
  final String name;
  final String referenceNumber;
  final String? occupancyClass;
  final String status;
  final String shareToken;
  final bool isPublic;
  final double totalFloorAreaSqm;
  final double estimatedStatutoryFeeUgx;
  final int blocksCount;
  final List<AiBlockModel> blocks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AiProjectModel({
    required this.id,
    required this.name,
    required this.referenceNumber,
    this.occupancyClass,
    required this.status,
    required this.shareToken,
    required this.isPublic,
    required this.totalFloorAreaSqm,
    required this.estimatedStatutoryFeeUgx,
    required this.blocksCount,
    this.blocks = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory AiProjectModel.fromJson(Map<String, dynamic> json) {
    final blocksList = (json['blocks'] as List<dynamic>?)
            ?.map((e) => AiBlockModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AiProjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Project',
      referenceNumber: json['reference_number']?.toString() ?? '',
      occupancyClass: json['occupancy_class']?.toString(),
      status: json['status']?.toString() ?? 'draft',
      shareToken: json['share_token']?.toString() ?? '',
      isPublic: json['is_public'] == true || json['is_public'] == 1,
      totalFloorAreaSqm:
          double.tryParse(json['total_floor_area_sqm']?.toString() ?? '0') ??
              0.0,
      estimatedStatutoryFeeUgx: double.tryParse(
              json['estimated_statutory_fee_ugx']?.toString() ?? '0') ??
          0.0,
      blocksCount: json['blocks_count'] is int
          ? json['blocks_count'] as int
          : blocksList.length,
      blocks: blocksList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class AiBlockModel {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final double totalFloorAreaSqm;
  final List<AiFloorModel> floors;
  final List<AiDrawingModel> drawings;

  AiBlockModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.totalFloorAreaSqm = 0.0,
    this.floors = const [],
    this.drawings = const [],
  });

  factory AiBlockModel.fromJson(Map<String, dynamic> json) {
    final rawFloors = json['floors'];
    final List<AiFloorModel> parsedFloors = [];
    if (rawFloors is List) {
      for (int i = 0; i < rawFloors.length; i++) {
        final item = rawFloors[i];
        if (item is Map<String, dynamic>) {
          parsedFloors.add(AiFloorModel.fromJson(item, fallbackIndex: i));
        } else if (item is Map) {
          parsedFloors.add(AiFloorModel.fromJson(
            Map<String, dynamic>.from(item),
            fallbackIndex: i,
          ));
        }
      }
    }

    final rawDrawings = json['drawings'];
    final List<AiDrawingModel> parsedDrawings = [];
    if (rawDrawings is List) {
      for (final d in rawDrawings) {
        if (d is Map<String, dynamic>) {
          parsedDrawings.add(AiDrawingModel.fromJson(d));
        } else if (d is Map) {
          parsedDrawings
              .add(AiDrawingModel.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }

    return AiBlockModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Block',
      description: json['description']?.toString(),
      totalFloorAreaSqm:
          double.tryParse(json['total_floor_area_sqm']?.toString() ?? '0') ??
              0.0,
      floors: parsedFloors,
      drawings: parsedDrawings,
    );
  }

  /// Helper to find a drawing for a given discipline ('architectural', 'structural', 'mechanical', 'electrical')
  AiDrawingModel? getDrawingForDiscipline(String discipline) {
    try {
      return drawings.firstWhere(
        (d) => d.discipline.toLowerCase() == discipline.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

class AiFloorModel {
  final int floorNumber;
  final String floorName;
  final double grossFloorAreaSqm;
  final double? netInternalAreaSqm;
  final int? page;
  final List<Map<String, dynamic>> roomBreakdown;

  AiFloorModel({
    required this.floorNumber,
    required this.floorName,
    this.grossFloorAreaSqm = 0.0,
    this.netInternalAreaSqm,
    this.page,
    this.roomBreakdown = const [],
  });

  String get name => floorName;

  factory AiFloorModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackIndex = 0,
  }) {
    final floorNum = int.tryParse(json['floor_number']?.toString() ?? '') ??
        fallbackIndex;
    final rawName =
        (json['floor_name'] ?? json['name'])?.toString().trim() ?? '';
    final resolvedName = rawName.isNotEmpty
        ? rawName
        : (floorNum == 0 ? 'Ground Floor' : 'Floor $floorNum');

    final gfa = double.tryParse(
          (json['gross_floor_area_sqm'] ?? json['floor_area_sqm'])
                  ?.toString() ??
              '0',
        ) ??
        0.0;
    final nia = json['net_internal_area_sqm'] != null
        ? double.tryParse(json['net_internal_area_sqm'].toString())
        : null;
    final pageNum = json['page'] != null
        ? int.tryParse(json['page'].toString())
        : null;

    final List<Map<String, dynamic>> rooms = [];
    if (json['room_breakdown'] is List) {
      for (final r in json['room_breakdown'] as List) {
        if (r is Map<String, dynamic>) {
          rooms.add(r);
        } else if (r is Map) {
          rooms.add(Map<String, dynamic>.from(r));
        }
      }
    }

    return AiFloorModel(
      floorNumber: floorNum,
      floorName: resolvedName,
      grossFloorAreaSqm: gfa,
      netInternalAreaSqm: nia,
      page: pageNum,
      roomBreakdown: rooms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'floor_number': floorNumber,
      'floor_name': floorName,
      'name': floorName,
      'gross_floor_area_sqm': grossFloorAreaSqm,
      if (netInternalAreaSqm != null)
        'net_internal_area_sqm': netInternalAreaSqm,
      if (page != null) 'page': page,
      if (roomBreakdown.isNotEmpty) 'room_breakdown': roomBreakdown,
    };
  }
}

class AiDrawingModel {
  final String id;
  final String blockId;
  final String discipline;
  final AiDrawingVersionModel? currentVersion;
  final List<AiDrawingVersionModel> versions;

  AiDrawingModel({
    required this.id,
    required this.blockId,
    required this.discipline,
    this.currentVersion,
    this.versions = const [],
  });

  factory AiDrawingModel.fromJson(Map<String, dynamic> json) {
    return AiDrawingModel(
      id: json['id']?.toString() ?? '',
      blockId: json['block_id']?.toString() ?? '',
      discipline: json['discipline']?.toString() ?? 'architectural',
      currentVersion: json['current_version'] != null
          ? AiDrawingVersionModel.fromJson(
              json['current_version'] as Map<String, dynamic>)
          : null,
      versions: (json['versions'] as List<dynamic>?)
              ?.map((e) =>
                  AiDrawingVersionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AiDrawingVersionModel {
  final String id;
  final String drawingId;
  final int versionNumber;
  final String originalName;
  final String status;
  final String? errorMessage;
  final AiComplianceResultModel? complianceResult;
  final DateTime? createdAt;

  AiDrawingVersionModel({
    required this.id,
    required this.drawingId,
    required this.versionNumber,
    required this.originalName,
    required this.status,
    this.errorMessage,
    this.complianceResult,
    this.createdAt,
  });

  bool get isProcessing => status == 'pending' || status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  factory AiDrawingVersionModel.fromJson(Map<String, dynamic> json) {
    return AiDrawingVersionModel(
      id: json['id']?.toString() ?? '',
      drawingId: json['drawing_id']?.toString() ?? '',
      versionNumber:
          int.tryParse(json['version_number']?.toString() ?? '1') ?? 1,
      originalName: json['original_name']?.toString() ?? 'drawing.pdf',
      status: json['status']?.toString() ?? 'pending',
      errorMessage: json['error_message']?.toString(),
      complianceResult: json['compliance_result'] != null
          ? AiComplianceResultModel.fromJson(
              json['compliance_result'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class AiComplianceResultModel {
  final String id;
  final String overallStatus;
  final double grossFloorAreaSqm;
  final List<DiscrepancyModel> discrepancies;
  final Map<String, dynamic>? rawReport;

  AiComplianceResultModel({
    required this.id,
    required this.overallStatus,
    required this.grossFloorAreaSqm,
    required this.discrepancies,
    this.rawReport,
  });

  factory AiComplianceResultModel.fromJson(Map<String, dynamic> json) {
    List<DiscrepancyModel> parsedDiscrepancies = [];
    if (json['discrepancies'] is List) {
      parsedDiscrepancies = (json['discrepancies'] as List)
          .whereType<Map>()
          .map((e) => DiscrepancyModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AiComplianceResultModel(
      id: json['id']?.toString() ?? '',
      overallStatus: json['overall_status']?.toString() ?? 'PENDING',
      grossFloorAreaSqm:
          double.tryParse(json['gross_floor_area_sqm']?.toString() ?? '0') ??
              0.0,
      discrepancies: parsedDiscrepancies,
      rawReport: json['raw_report'] is Map<String, dynamic>
          ? json['raw_report'] as Map<String, dynamic>
          : null,
    );
  }
}
