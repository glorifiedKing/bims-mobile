import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/ai_api_client.dart';
import '../models/quick_audit_model.dart';
import '../models/ai_project_model.dart';
//import '../models/copilot_message_model.dart';

class AiComplianceRepository {
  final AiApiClient _client;

  AiComplianceRepository({AiApiClient? client})
    : _client = client ?? AiApiClient();

  // ===========================================================================
  // 1. QUICK SINGLE DRAWING AUDITS
  // ===========================================================================

  Future<List<QuickAuditModel>> getQuickAudits() async {
    try {
      final response = await _client.dio.get(ApiConstants.quickAudits);
      final data = response.data['data']['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => QuickAuditModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to fetch quick audits'));
    }
  }

  Future<QuickAuditModel> getQuickAudit(String id) async {
    try {
      final response = await _client.dio.get('${ApiConstants.quickAudit}/$id');
      return QuickAuditModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to fetch audit result'));
    }
  }

  Future<QuickAuditModel> submitQuickAudit({
    File? file,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    required String discipline,
    String? occupancyClass,
  }) async {
    try {
      MultipartFile drawingMultipart;
      if (fileBytes != null) {
        drawingMultipart = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName ?? 'drawing.pdf',
        );
      } else {
        final resolvedPath = file?.path ?? filePath ?? '';
        final resolvedName =
            fileName ?? resolvedPath.split(RegExp(r'[/\\]')).last;
        drawingMultipart = await MultipartFile.fromFile(
          resolvedPath,
          filename: resolvedName,
        );
      }

      final formData = FormData.fromMap({
        'drawing_file': drawingMultipart,
        'discipline': discipline.toLowerCase(),
        if (occupancyClass != null && occupancyClass.isNotEmpty)
          'occupancy_class': occupancyClass,
      });

      final response = await _client.dio.post(
        ApiConstants.quickAudit,
        data: formData,
      );

      return QuickAuditModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to upload drawing for audit'));
    }
  }

  // ===========================================================================
  // 2. COLLABORATIVE PROJECTS & BLOCKS
  // ===========================================================================

  Future<List<AiProjectModel>> getProjects() async {
    try {
      final response = await _client.dio.get(ApiConstants.projects);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => AiProjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to load projects'));
    }
  }

  Future<AiProjectModel> createProject({
    required String name,
    String? referenceNumber,
    String? occupancyClass,
    bool isPublic = false,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.projects,
        data: {
          'name': name,
          if (referenceNumber != null && referenceNumber.isNotEmpty)
            'reference_number': referenceNumber,
          if (occupancyClass != null && occupancyClass.isNotEmpty)
            'occupancy_class': occupancyClass,
          'is_public': isPublic,
        },
      );
      return AiProjectModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to create project'));
    }
  }

  Future<AiProjectModel> updateProject({
    required String projectId,
    String? name,
    String? occupancyClass,
    bool? isPublic,
    String? status,
  }) async {
    try {
      final response = await _client.dio.put(
        '${ApiConstants.projects}/$projectId',
        data: {
          if (name != null) 'name': name,
          if (occupancyClass != null) 'occupancy_class': occupancyClass,
          if (isPublic != null) 'is_public': isPublic,
          if (status != null) 'status': status,
        },
      );
      return AiProjectModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to update project'));
    }
  }

  Future<AiProjectModel> getProjectDetails(String projectId) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.projects}/$projectId',
      );
      return AiProjectModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to load project details'));
    }
  }

  Future<AiProjectModel> joinProjectByToken(
    String shareToken, {
    String role = 'viewer',
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.joinProject,
        data: {'share_token': shareToken.trim(), 'role': role},
      );
      return AiProjectModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Invalid or expired share token'));
    }
  }

  Future<AiBlockModel> createBlock({
    required String projectId,
    required String name,
    String? description,
    List<Map<String, dynamic>>? floors,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConstants.projects}/$projectId/blocks',
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (floors != null) 'floors': floors,
        },
      );
      return AiBlockModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to add block'));
    }
  }

  Future<AiBlockModel> updateBlock({
    required String blockId,
    required String name,
    String? description,
    List<Map<String, dynamic>>? floors,
  }) async {
    try {
      final response = await _client.dio.put(
        '${ApiConstants.blocks}/$blockId',
        data: {
          'name': name,
          'description': description,
          if (floors != null) 'floors': floors,
        },
      );
      return AiBlockModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to update block'));
    }
  }

  Future<void> deleteBlock(String blockId) async {
    try {
      await _client.dio.delete('${ApiConstants.blocks}/$blockId');
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to delete block'));
    }
  }

  Future<AiFloorModel> createFloor({
    required String blockId,
    required int floorNumber,
    String? floorName,
    double? grossFloorAreaSqm,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConstants.blocks}/$blockId/floors',
        data: {
          'floor_number': floorNumber,
          if (floorName != null && floorName.isNotEmpty)
            'floor_name': floorName,
          if (grossFloorAreaSqm != null)
            'gross_floor_area_sqm': grossFloorAreaSqm,
        },
      );
      return AiFloorModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to add floor to block'));
    }
  }

  Future<List<AiFloorModel>> batchCreateFloors({
    required String blockId,
    required int startFloor,
    required int endFloor,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConstants.blocks}/$blockId/floors/batch',
        data: {'start_floor': startFloor, 'end_floor': endFloor},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => AiFloorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to generate floors'));
    }
  }

  Future<void> deleteFloor({
    required String blockId,
    required int floorNumber,
  }) async {
    try {
      await _client.dio.delete(
        '${ApiConstants.blocks}/$blockId/floors/$floorNumber',
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to delete floor'));
    }
  }

  Future<Map<String, dynamic>> uploadDrawing({
    required String blockId,
    required String discipline,
    File? file,
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      MultipartFile drawingMultipart;
      if (fileBytes != null) {
        drawingMultipart = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName ?? 'drawing.pdf',
        );
      } else {
        final resolvedPath = file?.path ?? filePath;
        if (resolvedPath == null || resolvedPath.isEmpty) {
          throw Exception('No drawing file or bytes provided for upload');
        }
        final resolvedName =
            fileName ?? resolvedPath.split(RegExp(r'[/\\]')).last;
        drawingMultipart = await MultipartFile.fromFile(
          resolvedPath,
          filename: resolvedName,
        );
      }

      final formData = FormData.fromMap({
        'block_id': blockId,
        'discipline': discipline.toLowerCase(),
        'drawing_file': drawingMultipart,
      });

      final response = await _client.dio.post(
        ApiConstants.drawingsUpload,
        data: formData,
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to upload drawing version'));
    }
  }

  Future<Map<String, dynamic>> getProjectReport(String projectId) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.projects}/$projectId/report',
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Failed to load project report'));
    }
  }

  // ===========================================================================
  // 3. FLOATING AI COPILOT
  // ===========================================================================

  Future<Map<String, dynamic>> askCopilot({
    required String query,
    String persona = 'inspector_okello',
    String? contextType,
    String? contextId,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.copilot,
        data: {
          'query': query,
          'persona': persona,
          if (contextType != null) 'context_type': contextType,
          if (contextId != null) 'context_id': contextId,
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
      // return CopilotResponseModel.fromJson(
      //   response.data['data'] as Map<String, dynamic>,
      // );
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Copilot is temporarily unavailable'));
    }
  }

  String _extractError(DioException e, String fallback) {
    if (e.response?.data is Map<String, dynamic>) {
      final map = e.response!.data as Map<String, dynamic>;
      if (map['message'] != null) {
        return map['message'].toString();
      }
      if (map['errors'] is Map) {
        final errors = map['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    return e.message ?? fallback;
  }
}
