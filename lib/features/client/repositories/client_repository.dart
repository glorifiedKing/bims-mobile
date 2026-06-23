import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/api_constants.dart';
import '../models/application_model.dart';
import '../models/application_detail_model.dart';
import '../models/invoice_model.dart';
import '../models/invoice_detail_model.dart';
import '../models/permit_model.dart';
import '../models/permit_detail_model.dart';
import '../models/client_profile_model.dart';
import '../models/inspection_invoice_model.dart';
import '../models/assessment_model.dart' as import_assessment;

class ClientRepository {
  final Dio _dio;

  ClientRepository({required Dio dio}) : _dio = dio;

  Future<bool> verifyAttachment(String code) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.clientBaseUrl}/applications/verify-attachment',
        data: {'code': code},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('Verification Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> verifyDevelopmentPermit(String permitNumber) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.clientBaseUrl}/applications/verify-development-permit',
        queryParameters: {'permitNumber': permitNumber},
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('Verification Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<import_assessment.AssessmentModel> getAssessment(String applicationKey) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.clientBaseUrl}/applications/$applicationKey/assessment',
      );
      if (response.statusCode == 200) {
        return import_assessment.AssessmentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch assessment');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> generatePrn(String applicationKey, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.clientBaseUrl}/applications/$applicationKey/generate-prn',
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['prn']?.toString() ?? response.data['data']?['prn']?.toString() ?? '';
      } else {
        throw Exception('Failed to generate PRN');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }


  Future<Map<String, dynamic>> getApplications({
    int page = 1,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        ApiConstants.getApplications,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = _extractListFromResponse(response.data);
        final List<ApplicationModel> apps = dataList
            .map((json) => ApplicationModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          if (response.data['data'] is Map<String, dynamic>) {
            final pageData = response.data['data'];
            final int currentPage = pageData['current_page'] ?? 1;
            final int lastPage = pageData['last_page'] ?? 1;
            hasReachedMax = currentPage >= lastPage;
          }
        } catch (_) {}

        return {'applications': apps, 'hasReachedMax': hasReachedMax};
      } else {
        throw Exception('Failed to fetch applications');
      }
    } on DioException catch (e) {
      final msg =
          e.error?.toString() ?? e.response?.data['message'] ?? 'API Error';
      if (!ApiConstants.isProduction) {
        throw Exception('API Error: $msg');
      }
      return {'applications': <ApplicationModel>[], 'hasReachedMax': false};
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ApplicationDetailModel> getApplicationDetails(
    String applicationKey,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getApplications}/$applicationKey',
      );
      if (response.statusCode == 200) {
        return ApplicationDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch application details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> downloadApplicationPdf(String applicationKey) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getApplications}/$applicationKey/download',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/application_$applicationKey.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data);
        return filePath;
      } else {
        throw Exception('Failed to download application PDF');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> submitApplication(dynamic data) async {
    try {
      final response = await _dio.post(
        ApiConstants.createApplication,
        data: data,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit application');
      }
    } on DioException catch (e) {
      final msg =
          e.error?.toString().replaceFirst('Exception: ', '') ??
          e.response?.data['message'] ??
          'API Error';

      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> submitAppealApplication(dynamic data) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.createApplication}/appeal',
        data: data,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit appeal application');
      }
    } on DioException catch (e) {
      final msg =
          e.error?.toString().replaceFirst('Exception: ', '') ??
          e.response?.data['message'] ??
          'API Error';

      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateApplication(String id, dynamic data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.getApplications}/$id',
        data: data,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update application');
      }
    } on DioException catch (e) {
      final msg =
          e.error?.toString() ?? e.response?.data['message'] ?? 'API Error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    String? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (filter != null && filter != 'ALL') {
        // Just an example mapping, adjust filter logic for invoices if backend expects specific keys
        if (filter == 'PAID') queryParams['status'] = 'PAID';
        if (filter == 'PENDING') queryParams['status'] = 'PENDING';
      }

      final response = await _dio.get(
        ApiConstants.invoices,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] is List
            ? response.data['data']
            : [];
        final List<InvoiceModel> invoices = dataList
            .map((json) => InvoiceModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final meta = response.data['meta'];
          if (meta is Map<String, dynamic>) {
            final int currentPage = meta['current_page'] ?? 1;
            final int lastPage = meta['last_page'] ?? 1;
            hasReachedMax = currentPage >= lastPage;
          }
        } catch (_) {}

        return {'invoices': invoices, 'hasReachedMax': hasReachedMax};
      } else {
        throw Exception('Failed to fetch invoices');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getInspectionInvoices({
    int page = 1,
    String? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (filter != null && filter != 'ALL') {
        if (filter == 'PAID') queryParams['status'] = 'PAID';
        if (filter == 'PENDING') queryParams['status'] = 'PENDING';
      }

      final response = await _dio.get(
        ApiConstants.inspectionInvoices,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] is List
            ? response.data['data']
            : [];
        final List<InspectionInvoiceModel> invoices = dataList
            .map((json) => InspectionInvoiceModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final meta = response.data['meta'];
          if (meta is Map<String, dynamic>) {
            final int currentPage = meta['current_page'] ?? 1;
            final int lastPage = meta['last_page'] ?? 1;
            hasReachedMax = currentPage >= lastPage;
          }
        } catch (_) {}

        return {'invoices': invoices, 'hasReachedMax': hasReachedMax};
      } else {
        throw Exception('Failed to fetch inspection invoices');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<InvoiceDetailModel> getInvoiceDetails(String prn) async {
    try {
      final response = await _dio.get('${ApiConstants.invoices}/$prn');
      if (response.statusCode == 200) {
        // The payload usually wraps it in a 'prn' or 'data' key based on the JSON doc
        // "prn": { ... }
        final data =
            response.data['prn'] ?? response.data['data'] ?? response.data;
        return InvoiceDetailModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch invoice details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<InspectionInvoiceModel> getInspectionInvoiceDetails(String prn) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.inspectionInvoices}/$prn',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return InspectionInvoiceModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch inspection invoice details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> getInvoicesTotal() async {
    try {
      final response = await _dio.get('${ApiConstants.invoices}/total');
      if (response.statusCode == 200) {
        return response.data['total']?.toString() ?? '0.00';
      }
      return '0.00';
    } catch (e) {
      return '0.00';
    }
  }

  Future<String> getInspectionInvoicesTotal() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.inspectionInvoices}/total',
      );
      if (response.statusCode == 200) {
        return response.data['total']?.toString() ?? '0.00';
      }
      return '0.00';
    } catch (e) {
      return '0.00';
    }
  }

  Future<Map<String, dynamic>> getPermits({int page = 1}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      final response = await _dio.get(
        ApiConstants.permits,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] is List
            ? response.data['data']
            : [];
        final List<PermitModel> permits = dataList
            .map((json) => PermitModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final meta = response.data['meta'];
          if (meta is Map<String, dynamic>) {
            final int currentPage = meta['current_page'] ?? 1;
            final int lastPage = meta['last_page'] ?? 1;
            hasReachedMax = currentPage >= lastPage;
          }
        } catch (_) {}

        return {'permits': permits, 'hasReachedMax': hasReachedMax};
      } else {
        throw Exception('Failed to fetch permits');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<PermitDetailModel> getPermitDetails(String serialNo) async {
    try {
      final response = await _dio.get('${ApiConstants.permits}/$serialNo');
      if (response.statusCode == 200) {
        return PermitDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch permit details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ClientProfileModel> getClientProfile() async {
    try {
      final response = await _dio.get(ApiConstants.account);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          return ClientProfileModel.fromJson(data[0]);
        } else if (data is Map<String, dynamic>) {
          return ClientProfileModel.fromJson(data);
        } else {
          throw Exception('Profile data is incomplete');
        }
      } else {
        throw Exception('Failed to fetch client profile');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updateClientProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.account, data: data);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> forgotPassword({
    required String type,
    String? email,
    String? phone,
  }) async {
    try {
      final Map<String, dynamic> data = {'type': type};
      if (type == 'email') {
        data['email'] = email;
      } else {
        data['phone'] = phone;
      }
      final response = await _dio.post('/account/forgot-password', data: data);
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
      final response = await _dio.put(
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

  Future<List<Map<String, dynamic>>> getSubcounties(String districtId) async {
    try {
      final response = await _dio.get(
        '/location/sub-counties?districtId=$districtId',
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getParishes(String subcountyId) async {
    try {
      final response = await _dio.get(
        '/location/parishes?subcountyId=$subcountyId',
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVillages(String parishId) async {
    try {
      final response = await _dio.get('/location/villages?parishId=$parishId');
      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRoads(String villageId) async {
    try {
      final response = await _dio.get('/location/roads?villageId=$villageId');
      if (response.statusCode == 200) {
        final data = response.data['data']['data'] as List;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<dynamic> _extractListFromResponse(dynamic responseData) {
    if (responseData == null) return [];

    // Safely extract 'data' key which could be a map or a list
    dynamic data = responseData;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'];
    }

    // Check if the extracted data is a Map with another nested 'data' (pagination scenario)
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      if (data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    } else if (data is List<dynamic>) {
      return data;
    }

    return [];
  }
}
