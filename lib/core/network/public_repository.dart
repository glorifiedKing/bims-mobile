import 'package:dio/dio.dart';
import '../../features/client/models/permit_detail_model.dart';

import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class PublicRepository {
  final Dio _dio;

  // Use a fresh generic Dio instance that doesn't share global auth interceptors
  PublicRepository() : _dio = Dio() {
    // Optionally setup timeout or base URLs if desired, however we can just use
    // the ApiConstants directly since this is simple.
  }

  Future<PermitDetailModel> verifyPermit(
    String serialNo,
    String baseUrl,
  ) async {
    try {
      final response = await _dio.get(
        '$baseUrl/client/permits/verify/$serialNo',
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map && responseData['data'] != null) {
          return PermitDetailModel.fromJson(responseData['data']);
        } else {
          final message = responseData is Map ? responseData['message'] : null;
          throw Exception(message?.toString() ?? 'Permit not found.');
        }
      } else {
        throw Exception('Permit not found or server error');
      }
    } on DioException catch (e) {
      String? parsedMsg;
      if (e.response?.data is Map) {
        parsedMsg = (e.response?.data as Map)['message']?.toString();
      } else if (e.response?.data is String) {
        try {
          final decoded = jsonDecode(e.response?.data as String);
          if (decoded is Map) {
            parsedMsg = decoded['message']?.toString();
          }
        } catch (_) {}
      }

      if (e.response?.statusCode == 404) {
        throw Exception(parsedMsg ?? 'Permit not found.');
      }

      throw Exception(
        'Verification failed: ${parsedMsg ?? e.message ?? 'Unknown Error'}',
      );
    } catch (e) {
      // If it's an Exception we threw manually, bubble it up cleanly
      final errorString = e.toString();
      if (errorString.startsWith('Exception: ')) {
        throw Exception(errorString.replaceFirst('Exception: ', ''));
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> validateNin(
    String baseUrl,
    String nin,
    String surname,
    String givenName,
    String otherNames,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl${ApiConstants.validateNin}',
        data: {
          'nin': nin,
          'surname': surname,
          'given_name': givenName,
          'other_names': otherNames,
        },
      );
      if (response.statusCode == 200 && response.data['valid'] == true) {
        return true;
      }
      throw Exception('Invalid NIN');
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'Error validating NIN';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> validateBrn(String baseUrl, String brn) async {
    try {
      final response = await _dio.post(
        '$baseUrl${ApiConstants.validateBrn}',
        data: {'brn': brn},
      );
      if (response.statusCode == 200 && response.data['valid'] == true) {
        return response.data['company'] ?? <String, dynamic>{};
      }
      throw Exception('Invalid BRN');
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'Error validating BRN';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> validateTin(String baseUrl, String tin) async {
    try {
      final response = await _dio.get(
        '$baseUrl${ApiConstants.validateTin}/$tin',
      );
      if (response.statusCode == 200 && response.data['valid'] == true) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Invalid TIN');
    } on DioException catch (e) {
      final msg =
          e.response?.data['message'] ?? e.message ?? 'Error validating TIN';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> submitFeedback(String baseUrl, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$baseUrl${ApiConstants.feedback}',
        data: data,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit report');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Error submitting report';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
