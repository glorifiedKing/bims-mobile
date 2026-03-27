import 'package:dio/dio.dart';
import '../../../core/network/bco_api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../client/models/application_model.dart';
import '../../client/models/application_detail_model.dart';
import '../../client/models/invoice_model.dart';
import '../../client/models/invoice_detail_model.dart';
import '../../client/models/inspection_invoice_model.dart';
import '../models/audit_trail_model.dart';
import '../models/bco_profile_model.dart';
import '../models/bco_counters_model.dart';

class BcoRepository {
  final BcoApiClient bcoApiClient;

  BcoRepository({required this.bcoApiClient});

  Future<Map<String, dynamic>> getApplications({
    int page = 1,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }

      final response = await bcoApiClient.dio.get(
        ApiConstants.getApplications,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] is List
            ? response.data['data']
            : [];
        final List<ApplicationModel> apps = dataList
            .map((json) => ApplicationModel.fromJson(json))
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

        return {'applications': apps, 'hasReachedMax': hasReachedMax};
      } else {
        throw Exception('Failed to fetch BCO applications');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ApplicationDetailModel> getApplicationDetails(
    String applicationKey,
  ) async {
    try {
      final response = await bcoApiClient.dio.get(
        '${ApiConstants.getApplications}/$applicationKey',
      );
      if (response.statusCode == 200) {
        return ApplicationDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch BCO application details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getAuditTrail(
    String applicationKey, {
    int page = 1,
  }) async {
    try {
      final response = await bcoApiClient.dio.get(
        '${ApiConstants.getApplications}/$applicationKey/audit-trail',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final Map<String, dynamic> auditData =
            response.data['audit_trail'] ?? {};
        final List<dynamic> dataList = auditData['data'] ?? [];
        final List<AuditTrailModel> trails = dataList
            .map((json) => AuditTrailModel.fromJson(json))
            .toList();

        bool hasReachedMax = false;
        try {
          final int currentPage = auditData['current_page'] ?? 1;
          final int lastPage = auditData['last_page'] ?? 1;
          hasReachedMax = currentPage >= lastPage;
        } catch (_) {}

        return {'trails': trails, 'hasReachedMax': hasReachedMax};
      }
      throw Exception('Failed to load audit trail');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Error fetching audit trail: $e');
    }
  }

  Future<void> reviewApplication(
    String applicationKey,
    String status,
    String comment,
  ) async {
    try {
      final response = await bcoApiClient.dio.post(
        '${ApiConstants.getApplications}/$applicationKey/review',
        data: {'status': status, 'comment': comment},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data['message'] ?? 'Failed to review application',
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Error reviewing application: $e');
    }
  }

  List<dynamic> _extractListFromResponse(dynamic responseData) {
    if (responseData == null) return [];
    dynamic data = responseData;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'];
    }
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      if (data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    } else if (data is List<dynamic>) {
      return data;
    }
    return [];
  }

  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    String? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};
      if (filter != null && filter != 'ALL') {
        if (filter == 'PAID') queryParams['status'] = 'PAID';
        if (filter == 'PENDING') queryParams['status'] = 'PENDING';
      }

      final response = await bcoApiClient.dio.get(
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
        throw Exception('Failed to fetch BCO invoices');
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

      final response = await bcoApiClient.dio.get(
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
        throw Exception('Failed to fetch BCO inspection invoices');
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
      final response = await bcoApiClient.dio.get('${ApiConstants.invoices}/$prn');
      if (response.statusCode == 200) {
        final data = response.data['prn'] ?? response.data['data'] ?? response.data;
        return InvoiceDetailModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch BCO invoice details');
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
      final response = await bcoApiClient.dio.get('${ApiConstants.inspectionInvoices}/$prn');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return InspectionInvoiceModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch BCO inspection invoice details');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<String> getGeneralInvoicesTotal() async {
    try {
      final response = await bcoApiClient.dio.get(
        '${ApiConstants.invoices}/total',
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['total'].toString();
      }
      throw Exception('Failed to load general invoices total');
    } catch (e) {
      throw Exception('Error fetching general invoices total: $e');
    }
  }

  Future<String> getInspectionInvoicesTotal() async {
    try {
      final response = await bcoApiClient.dio.get(
        '${ApiConstants.inspectionInvoices}/total',
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['total'].toString();
      }
      throw Exception('Failed to load inspection invoices total');
    } catch (e) {
      throw Exception('Error fetching inspection invoices total: $e');
    }
  }

  Future<BcoProfileModel> getProfileDetails() async {
    try {
      final response = await bcoApiClient.dio.get('/account');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        if (data.isNotEmpty) {
          return BcoProfileModel.fromJson(data.first);
        }
        throw Exception('Profile data is empty');
      } else {
        throw Exception('Failed to fetch BCO profile');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<BcoCountersModel> getCounters() async {
    try {
      final response = await bcoApiClient.dio.get('/counters');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return BcoCountersModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch BCO counters');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Unknown Error';
      throw Exception('API Error: $msg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
