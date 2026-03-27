import 'package:dio/dio.dart';
import '../../features/client/models/permit_detail_model.dart';

import 'dart:convert';

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
}
