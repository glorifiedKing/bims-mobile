class ApiConstants {
  static const String baseUrl = 'https://api.test.bims.go.ug/v1';
  static const String clientBaseUrl = '$baseUrl/client';
  static const String bcoBaseUrl = '$baseUrl/internal';

  // Auth
  static const String createAccount = '/account';
  static const String account = '/account';
  static const String login = '/token'; // Client Token
  static const String bcoLogin = '/token'; // BCO Token
  static const String refreshToken = '/token/refresh';

  // Applications
  static const String getApplications = '/applications';

  // Invoices
  static const String invoices = '/invoices';

  // Permits
  static const String permits = '/permits';
  static const String verifyPermit = '/verify';
  static const String inspectionInvoices = '/inspection-invoices';

  // Auxiliary
  static const String adminUnitTypes = '/auxiliary/admin-unit-types';
  static const String adminUnitsList = '/auxiliary/admin-units-list';
  static const String userRoles = '/auxiliary/user-roles';
}
