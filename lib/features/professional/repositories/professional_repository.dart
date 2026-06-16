import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/pro_api_client.dart';
import '../models/professional_profile.dart';
import '../models/professional_counters.dart';
import '../models/professional_documents.dart';
import '../models/pro_application_model.dart';
import '../models/pro_application_details_model.dart';
import '../models/pro_attachment_model.dart';
import '../models/pro_attachment_type_model.dart';

class ProfessionalRepository {
  final ProApiClient proApiClient;

  ProfessionalRepository({required this.proApiClient});

  Future<ProfessionalProfile> getProfile() async {
    try {
      final response = await proApiClient.dio.get('/account');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        if (data.isNotEmpty) {
          return ProfessionalProfile.fromJson(data.first);
        }
      }
      throw Exception('Failed to load professional profile');
    } catch (e) {
      throw Exception('Error fetching professional profile: $e');
    }
  }

  Future<ProfessionalCounters> getCounters() async {
    try {
      final response = await proApiClient.dio.get('/account/counters');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> data = response.data['data'];
        return ProfessionalCounters.fromJson(data);
      }
      throw Exception('Failed to load professional counters');
    } catch (e) {
      throw Exception('Error fetching professional counters: $e');
    }
  }

  Future<ProfessionalDocuments> getDocuments() async {
    try {
      final response = await proApiClient.dio.get('/account/documents');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        if (data.isNotEmpty) {
          return ProfessionalDocuments.fromJson(data.first);
        }
        return ProfessionalDocuments(documents: {}); // empty if no data block
      }
      throw Exception('Failed to load professional documents');
    } catch (e) {
      throw Exception('Error fetching professional documents: $e');
    }
  }

  Future<Map<String, dynamic>> getApplications({int page = 1, String? status}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }
      
      final response = await proApiClient.dio.get('/applications', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> payload = response.data['data'];
        final List<dynamic> dataList = payload['data'] is List ? payload['data'] : [];
        
        final List<ProApplicationModel> apps = dataList
            .map((json) => ProApplicationModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final int currentPage = payload['current_page'] ?? 1;
          final int lastPage = payload['last_page'] ?? 1;
          hasReachedMax = currentPage >= lastPage;
        } catch (_) {}

        return {'applications': apps, 'hasReachedMax': hasReachedMax};
      }
      throw Exception('Failed to load professional applications');
    } catch (e) {
      throw Exception('Error fetching professional applications: $e');
    }
  }

  Future<ProApplicationDetailsModel> getApplicationDetails(String applicationKey) async {
    try {
      final response = await proApiClient.dio.get('/applications/$applicationKey');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return ProApplicationDetailsModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load application details');
    } catch (e) {
      throw Exception('Error fetching application details: $e');
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await proApiClient.dio.post(
        '/account/forgot-password',
        data: {'email': email},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send reset code');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await proApiClient.dio.put(
        '/account/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Password reset failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getAttachments({
    int page = 1,
    String? status,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }
      if (type != null && type != 'ALL') {
        queryParams['attachment_type'] = type;
      }

      final response = await proApiClient.dio.get(
        '/attachments',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> payload = response.data['data'];
        final List<dynamic> dataList = payload['data'] is List ? payload['data'] : [];

        final List<ProAttachmentModel> attachments = dataList
            .map((json) => ProAttachmentModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final int currentPage = payload['current_page'] ?? 1;
          final int lastPage = payload['last_page'] ?? 1;
          hasReachedMax = currentPage >= lastPage;
        } catch (_) {}

        return {'attachments': attachments, 'hasReachedMax': hasReachedMax};
      }
      throw Exception('Failed to load attachments');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ProAttachmentTypeModel>> getAttachmentTypes() async {
    try {
      final response = await proApiClient.dio.get('/attachments/types');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> payload = response.data['data'];
        final List<dynamic> dataList = payload['data'] is List ? payload['data'] : [];

        return dataList
            .map((json) => ProAttachmentTypeModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load attachment types');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> uploadAttachment({
    required int attachmentType,
    required String reference,
    required String particulars,
    required String clientDetails,
    String? documentPath,
    Uint8List? documentBytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'attachment_type': attachmentType,
        'reference': reference,
        'particulars': particulars,
        'client_details': clientDetails,
      };

      if (documentBytes != null && fileName != null) {
        dataMap['document'] = MultipartFile.fromBytes(
          documentBytes,
          filename: fileName,
        );
      } else if (documentPath != null) {
        final name = documentPath.split('/').last;
        dataMap['document'] = await MultipartFile.fromFile(
          documentPath,
          filename: name,
        );
      } else {
        throw Exception('No document file or bytes provided for upload');
      }

      final formData = FormData.fromMap(dataMap);

      final response = await proApiClient.dio.post(
        '/attachments/upload',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload attachment');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> editAttachment({
    required int id,
    required int attachmentType,
    required String reference,
    required String particulars,
    required String clientDetails,
    String? documentPath,
    Uint8List? documentBytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'attachment_type': attachmentType,
        'reference': reference,
        'particulars': particulars,
        'client_details': clientDetails,
      };

      if (documentBytes != null && fileName != null) {
        dataMap['document'] = MultipartFile.fromBytes(
          documentBytes,
          filename: fileName,
        );
      } else if (documentPath != null) {
        final name = documentPath.split('/').last;
        dataMap['document'] = await MultipartFile.fromFile(
          documentPath,
          filename: name,
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await proApiClient.dio.post(
        '/$id/edit',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update attachment');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
