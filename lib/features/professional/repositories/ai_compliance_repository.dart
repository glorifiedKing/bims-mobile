import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/ai_api_client.dart';
import '../models/ai_project_model.dart';
import '../models/copilot_model.dart';
import '../models/quick_audit_model.dart';

class AiComplianceRepository {
  final AiApiClient _client;

  AiComplianceRepository({AiApiClient? client})
    : _client = client ?? AiApiClient();

  // ==========================================
  // QUICK AUDIT
  // ==========================================

  Future<QuickAuditModel> submitQuickAudit({
    required String filePath,
    required String discipline,
    String? occupancyClass,
  }) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'drawing_file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      'discipline': discipline.toLowerCase(),
      if (occupancyClass != null) 'occupancy_class': occupancyClass,
    });

    final response = await _client.dio.post(
      ApiConstants.quickAudit,
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return QuickAuditModel.fromJson(data);
  }

  Future<QuickAuditModel> getQuickAudit(String id) async {
    final response = await _client.dio.get('${ApiConstants.quickAudit}/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return QuickAuditModel.fromJson(data);
  }

  Future<List<QuickAuditModel>> getQuickAudits() async {
    final response = await _client.dio.get(ApiConstants.quickAudits);
    final list = response.data['data']['data'] as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => QuickAuditModel.fromJson(item))
        .toList();
  }

  // ==========================================
  // PROJECTS
  // ==========================================

  Future<List<AiProjectModel>> getProjects() async {
    final response = await _client.dio.get(ApiConstants.projects);
    final list = response.data['data'] as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => AiProjectModel.fromJson(item))
        .toList();
  }

  Future<AiProjectModel> getProject(String id) async {
    final response = await _client.dio.get('${ApiConstants.projects}/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return AiProjectModel.fromJson(data);
  }

  Future<AiProjectModel> createProject({
    required String name,
    String? referenceNumber,
    String? occupancyClass,
    bool isPublic = false,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.projects,
      data: {
        'name': name,
        if (referenceNumber != null && referenceNumber.isNotEmpty)
          'reference_number': referenceNumber,
        if (occupancyClass != null) 'occupancy_class': occupancyClass,
        'is_public': isPublic,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AiProjectModel.fromJson(data);
  }

  Future<AiProjectModel> joinProject(String shareToken) async {
    final response = await _client.dio.post(
      ApiConstants.joinProject,
      data: {'share_token': shareToken},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AiProjectModel.fromJson(data);
  }

  // ==========================================
  // BLOCKS & FLOORS
  // ==========================================

  Future<AiBlockModel> createBlock({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final response = await _client.dio.post(
      '//blocks',
      data: {'name': name, if (description != null) 'description': description},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AiBlockModel.fromJson(data);
  }

  Future<AiFloorModel> createFloor({
    required String blockId,
    required int floorNumber,
    String? name,
  }) async {
    final response = await _client.dio.post(
      '//floors',
      data: {'floor_number': floorNumber, if (name != null) 'name': name},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AiFloorModel.fromJson(data);
  }

  Future<List<AiFloorModel>> batchCreateFloors({
    required String blockId,
    required int startFloor,
    required int endFloor,
  }) async {
    final response = await _client.dio.post(
      '//floors/batch',
      data: {'start_floor': startFloor, 'end_floor': endFloor},
    );
    final list = response.data['data'] as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((f) => AiFloorModel.fromJson(f))
        .toList();
  }

  Future<void> deleteFloor(String floorId) async {
    await _client.dio.delete('/');
  }

  // ==========================================
  // DRAWINGS & COMPLIANCE
  // ==========================================

  Future<AiDrawingVersionModel> uploadDrawing({
    required String floorId,
    required String discipline,
    required String filePath,
  }) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'floor_id': floorId,
      'discipline': discipline.toLowerCase(),
      'drawing_file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _client.dio.post(
      ApiConstants.drawingsUpload,
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AiDrawingVersionModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getProjectReport(String projectId) async {
    final response = await _client.dio.get('${ApiConstants.projects}/$projectId/report');
    return response.data['data'] as Map<String, dynamic>;
  }

  // ==========================================
  // FLOATING AI COPILOT
  // ==========================================

  Future<Map<String, dynamic>> askCopilot({
    required String query,
    String? persona,
    String? drawingVersionId,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.copilot,
      data: {
        'query': query,
        if (persona != null) 'persona': persona,
        if (drawingVersionId != null) 'drawing_version_id': drawingVersionId,
      },
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      } else if (raw['data'] is String) {
        return {'response': raw['data']};
      }
      return raw;
    } else if (raw is String) {
      return {'response': raw};
    }
    return {'response': raw?.toString() ?? ''};
  }
}
