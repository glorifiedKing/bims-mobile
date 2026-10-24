import 'dart:io' show Platform;

class ApiConstants {
  static const bool isProduction = false;
  static const String baseUrl = isProduction
      ? 'https://mobile.bims.go.ug/v1'
      : 'https://api.test.bims.go.ug/v1';

  // AI Compliance Backend Base URL (supports Android emulator 10.0.2.2 or localhost)
  static String aiBaseUrl = "https://ai-backend.bims.go.ug/api/v1";

  static const String clientBaseUrl = '$baseUrl/client';
  static const String bcoBaseUrl = '$baseUrl/internal';
  static const String professionalBaseUrl = '$baseUrl/pro';

  // Auth
  static const String createAccount = '/account';
  static const String account = '/account';
  static const String login = '/token'; // Client Token
  static const String bcoLogin = '/token'; // BCO Token
  static const String professionalLogin = '/token';
  static const String refreshToken = '/token/refresh';

  // Applications
  static const String getApplications = '/applications';
  static const String createApplication = '/applications';

  // Invoices
  static const String invoices = '/invoices';

  // Permits
  static const String permits = '/permits';
  static const String verifyPermit = '/verify';
  static const String inspectionInvoices = '/inspection-invoices';

  // Auxiliary
  static const String adminUnitTypes = '/auxiliary/admin-unit-types';
  static const String adminUnitsList = '/auxiliary/admin-units-list';
  static const String validateNin = '/auxiliary/validate-nin';
  static const String validateBrn = '/auxiliary/validate-brn';
  static const String validateTin = '/auxiliary/validate-tin';
  static const String wbCategories = '/auxiliary/feedback-types';
  static const String userRoles = '/auxiliary/user-roles';
  static const String paymentModes = '/auxiliary/payment-modes';
  static const String buildingClassifications =
      '/auxiliary/building-classifications';
  static const String epsTypes = '/auxiliary/eps-types';
  static const String expressPenalties = '/eps/penalties';
  static const String feedback = '/feedback';
  static const String buildingPurposes = '/auxiliary/building-purposes';
  static const String landTenures = '/auxiliary/land-tenures';
  static const String applicationTypes = '/auxiliary/application-types';
  static const String formTypes = '/auxiliary/form-types';
  static const String buildingOperations = '/auxiliary/building-operations';
  static const String inspections = '/inspections';
  static const String inspectionTypes = '/inspections/types';
  static const String inspectionStatuses = '/inspections/statuses';

  // Firebase Cloud Messaging
  static const String fcmToken = '/fcm-token';

  // AI Compliance Service Endpoints
  static const String quickAudit = '/quick-audit';
  static const String quickAudits = '/quick-audits';
  static const String projects = '/projects';
  static const String joinProject = '/projects/join';
  static const String blocks = '/blocks';
  static const String floors = '/floors';
  static const String copilot = '/copilot/ask';
  static const String drawingsUpload = '/drawings/upload';
}
