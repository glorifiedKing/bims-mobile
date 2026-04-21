import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/pro_api_client.dart';
import '../models/professional_profile.dart';
import '../models/professional_counters.dart';
import '../models/professional_documents.dart';
import '../models/pro_application_model.dart';
import '../models/pro_application_details_model.dart';

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
}
