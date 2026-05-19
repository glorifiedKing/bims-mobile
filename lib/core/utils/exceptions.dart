import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiException(this.message, {this.errors, this.statusCode});

  @override
  String toString() => message;
}

class ApiErrorHandler {
  static String parseError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode;

      // Handle Laravel Validation Errors (422)
      if (statusCode == 422) {
        if (data is Map<String, dynamic>) {
          // 1. Determine the source of the errors:
          // Is it inside an 'errors' key, or is the root map the error list?
          final Map<String, dynamic> errorMap =
              (data.containsKey('errors') && data['errors'] is Map)
              ? data['errors']
              : data;

          // 2. Extract and flatten only the values that are actually Lists (Laravel validation style)
          final List<String> allErrors = [];

          errorMap.forEach((key, value) {
            if (value is List) {
              allErrors.addAll(value.map((e) => e.toString()));
            } else if (key == 'message' &&
                value is String &&
                allErrors.isEmpty) {
              // If it's just a top-level message and no list errors found yet
              allErrors.add(value);
            }
          });

          if (allErrors.isNotEmpty) {
            final String cleanMessage = allErrors.join('\n');

            // Pass the cleaned string into the error property
            return cleanMessage;
          }
        }
      }

      // Handle standard Laravel error messages
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }

    // Fallback for network timeouts or other Dio errors
    return e.message ?? 'A connection error occurred';
  }
}
