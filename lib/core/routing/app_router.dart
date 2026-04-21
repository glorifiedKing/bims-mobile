import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/client/models/permit_detail_model.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/screens/verify_permit_screen.dart';
import '../../features/auth/screens/client_login_screen.dart';
import '../../features/auth/screens/client_registration_screen.dart';
import '../../features/client/screens/client_dashboard_screen.dart';
import '../../features/client/screens/client_profile_screen.dart';
import '../../features/client/screens/client_applications_screen.dart';
import '../../features/client/screens/client_application_details_screen.dart';
import '../../features/client/screens/client_invoice_details_screen.dart';
import '../../features/client/screens/client_inspection_invoice_details_screen.dart';
import '../../features/client/screens/client_invoices_screen.dart';
import '../../features/client/screens/client_new_application_screen.dart';
import '../../features/client/screens/client_permits_screen.dart';
import '../../features/client/screens/client_permit_details_screen.dart';
import '../../features/client/screens/client_edit_profile_screen.dart';
import '../../features/whistle_blow/screens/whistle_blow_screen.dart';
import '../../features/auth/screens/bco_login_screen.dart';
import '../../features/bco/screens/bco_dashboard_screen.dart';
import '../../features/bco/screens/bco_applications_screen.dart';
import '../../features/bco/screens/bco_application_details_screen.dart';
import '../../features/bco/screens/bco_application_attachments_screen.dart';
import '../../features/bco/screens/bco_checklist_screen.dart';
import '../../features/bco/screens/bco_invoices_screen.dart';
import '../../features/bco/screens/bco_invoice_details_screen.dart';
import '../../features/bco/screens/bco_inspection_invoice_details_screen.dart';
import '../../features/bco/screens/bco_stop_order_screen.dart';
import '../../features/bco/screens/bco_camera_screen.dart';
import '../../features/bco/screens/bco_profile_screen.dart';
import '../../features/bco/screens/bco_calendar_screen.dart';
import '../../features/bco/screens/bco_penalties_screen.dart';
import '../../features/bco/screens/bco_penalty_details_screen.dart';
import '../../features/bco/screens/bco_create_penalty_screen.dart';
import '../../features/auth/screens/professional_login_screen.dart';
import '../../features/auth/screens/professional_registration_screen.dart';
import '../../features/professional/screens/professional_dashboard_screen.dart';
import '../../features/professional/screens/professional_profile_screen.dart';
import '../../features/professional/screens/professional_applications_screen.dart';
import '../../features/professional/screens/professional_application_details_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/verify-permit',
        builder: (context, state) => const VerifyPermitScreen(),
      ),
      GoRoute(
        path: '/verify-permit/details',
        builder: (context, state) {
          final permit = state.extra as PermitDetailModel?;
          return ClientPermitDetailsScreen(preloadedPermit: permit);
        },
      ),
      GoRoute(
        path: '/client/login',
        builder: (context, state) => const ClientLoginScreen(),
      ),
      GoRoute(
        path: '/client/register',
        builder: (context, state) => const ClientRegistrationScreen(),
      ),
      GoRoute(
        path: '/client/dashboard',
        builder: (context, state) => const ClientDashboardScreen(),
      ),
      GoRoute(
        path: '/client/profile',
        builder: (context, state) => const ClientProfileScreen(),
      ),
      GoRoute(
        path: '/client/profile/edit',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return ClientEditProfileScreen(
            currentEmail: extras['email'] as String? ?? '',
            currentPhone: extras['phone'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/client/applications',
        builder: (context, state) => const ClientApplicationsScreen(),
      ),
      GoRoute(
        path: '/client/applications/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ClientApplicationDetailsScreen(applicationKey: id);
        },
      ),
      GoRoute(
        path: '/client/invoices',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return ClientInvoicesScreen(
            initialIndex: extras['tabIndex'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/client/invoices/:prn',
        builder: (context, state) {
          final prn = state.pathParameters['prn']!;
          return ClientInvoiceDetailsScreen(prn: prn);
        },
      ),
      GoRoute(
        path: '/client/inspection-invoices/:prn',
        builder: (context, state) {
          final prn = state.pathParameters['prn']!;
          return ClientInspectionInvoiceDetailsScreen(prn: prn);
        },
      ),
      GoRoute(
        path: '/client/new-application',
        builder: (context, state) => const ClientNewApplicationScreen(),
      ),
      GoRoute(
        path: '/client/permits',
        builder: (context, state) => const ClientPermitsScreen(),
      ),
      GoRoute(
        path: '/client/permits/:serial',
        builder: (context, state) {
          final serial = state.pathParameters['serial']!;
          return ClientPermitDetailsScreen(serialNo: serial);
        },
      ),
      GoRoute(
        path: '/whistle-blow',
        builder: (context, state) => const WhistleBlowScreen(),
      ),
      GoRoute(
        path: '/bco/login',
        builder: (context, state) => const BcoLoginScreen(),
      ),
      GoRoute(
        path: '/bco/dashboard',
        builder: (context, state) => const BcoDashboardScreen(),
      ),
      GoRoute(
        path: '/bco/checklist',
        builder: (context, state) => const BcoChecklistScreen(),
      ),
      GoRoute(
        path: '/bco/stop-order',
        builder: (context, state) => const BcoStopOrderScreen(),
      ),
      GoRoute(
        path: '/bco/applications',
        builder: (context, state) => const BcoApplicationsScreen(),
      ),
      GoRoute(
        path: '/bco/applications/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BcoApplicationDetailsScreen(applicationKey: id);
        },
      ),
      GoRoute(
        path: '/bco/applications/:id/attachments',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BcoApplicationAttachmentsScreen(applicationKey: id);
        },
      ),
      GoRoute(
        path: '/bco/invoices',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return BcoInvoicesScreen(
            initialIndex: extras['tabIndex'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/bco/invoices/:prn',
        builder: (context, state) {
          final prn = state.pathParameters['prn']!;
          return BcoInvoiceDetailsScreen(prn: prn);
        },
      ),
      GoRoute(
        path: '/bco/inspection-invoices/:prn',
        builder: (context, state) {
          final prn = state.pathParameters['prn']!;
          return BcoInspectionInvoiceDetailsScreen(prn: prn);
        },
      ),
      GoRoute(
        path: '/bco/camera',
        builder: (context, state) => const BcoCameraScreen(),
      ),
      GoRoute(
        path: '/bco/profile',
        builder: (context, state) => const BcoProfileScreen(),
      ),
      GoRoute(
        path: '/bco/calendar',
        builder: (context, state) => const BcoCalendarScreen(),
      ),
      GoRoute(
        path: '/bco/penalties',
        builder: (context, state) => const BcoPenaltiesScreen(),
      ),
      GoRoute(
        path: '/bco/penalties/:reference',
        builder: (context, state) {
          final reference = state.pathParameters['reference']!;
          return BcoPenaltyDetailsScreen(reference: reference);
        },
      ),
      GoRoute(
        path: '/bco/new-penalty',
        builder: (context, state) => const BcoCreatePenaltyScreen(),
      ),
      GoRoute(
        path: '/bco/camera',
        builder: (context, state) => const BcoCameraScreen(),
      ),
      GoRoute(
        path: '/professional/login',
        builder: (context, state) => const ProfessionalLoginScreen(),
      ),
      GoRoute(
        path: '/professional/register',
        builder: (context, state) => const ProfessionalRegistrationScreen(),
      ),
      GoRoute(
        path: '/professional/dashboard',
        builder: (context, state) => const ProfessionalDashboardScreen(),
      ),
      GoRoute(
        path: '/professional/profile',
        builder: (context, state) => const ProfessionalProfileScreen(),
      ),
      GoRoute(
        path: '/professional/applications',
        builder: (context, state) => const ProfessionalApplicationsScreen(),
      ),
      GoRoute(
        path: '/professional/applications/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProfessionalApplicationDetailsScreen(applicationKey: id);
        },
      ),
    ],
  );
}
