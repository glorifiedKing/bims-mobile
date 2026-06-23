import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/client/bloc/permit_details/client_permit_details_bloc.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/network/api_client.dart';
import 'core/network/bco_api_client.dart';
import 'core/network/pro_api_client.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/repositories/auxiliary_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/forgot_reset_password/forgot_reset_password_bloc.dart';
import 'features/auth/bloc/pro_forgot_reset_password/pro_forgot_reset_password_bloc.dart';
import 'features/auth/bloc/bco_forgot_reset_password/bco_forgot_reset_password_bloc.dart';
import 'features/auth/bloc/bco_auth_bloc.dart';
import 'features/auth/bloc/bco_auth_event.dart';
import 'features/auth/bloc/professional_auth_bloc.dart';
import 'features/auth/bloc/professional_auth_event.dart';
import 'features/bco/repositories/bco_repository.dart';
import 'features/bco/bloc/invoices/bco_invoices_bloc.dart';
import 'features/bco/bloc/applications/bco_applications_bloc.dart';
import 'features/bco/bloc/application_details/bco_application_details_bloc.dart';
import 'features/bco/bloc/application_attachments/bco_application_attachments_bloc.dart';
import 'features/bco/bloc/general_invoices/bco_general_invoices_bloc.dart';
import 'features/bco/bloc/general_invoices/bco_general_invoices_event.dart';
import 'features/bco/bloc/inspection_invoices_list/bco_inspection_invoices_list_bloc.dart';
import 'features/bco/bloc/inspection_invoices_list/bco_inspection_invoices_list_event.dart';
import 'features/bco/bloc/invoice_details/bco_invoice_details_bloc.dart';
import 'features/bco/bloc/inspection_invoice_details/bco_inspection_invoice_details_bloc.dart';
import 'features/bco/bloc/express_penalty_invoices/bco_express_penalty_invoices_bloc.dart';
import 'features/bco/bloc/express_penalty_invoices/bco_express_penalty_invoices_event.dart';
import 'features/bco/bloc/profile/bco_profile_bloc.dart';
import 'features/bco/bloc/counters/bco_counters_bloc.dart';
import 'features/bco/bloc/penalties/bco_penalties_bloc.dart';
import 'features/bco/bloc/penalty_details/bco_penalty_details_bloc.dart';
import 'features/bco/bloc/create_penalty/bco_create_penalty_bloc.dart';
import 'features/bco/bloc/camera/bco_camera_bloc.dart';
import 'features/bco/bloc/whistleblows/bco_whistleblows_bloc.dart';
import 'features/bco/bloc/whistleblow_details/bco_whistleblow_details_bloc.dart';
import 'features/bco/bloc/inspections/bco_inspections_bloc.dart';
import 'features/bco/bloc/inspection_details/bco_inspection_details_bloc.dart';
import 'features/bco/bloc/create_inspection/bco_create_inspection_bloc.dart';
import 'features/client/repositories/client_repository.dart';
import 'features/client/bloc/applications/client_applications_bloc.dart';
import 'features/client/bloc/applications/client_applications_event.dart';
import 'features/client/bloc/invoices/client_invoices_bloc.dart';
import 'features/client/bloc/invoices/client_invoices_event.dart';
import 'features/client/bloc/inspection_invoices/client_inspection_invoices_bloc.dart';
import 'features/client/bloc/inspection_invoices/client_inspection_invoices_event.dart';
import 'features/client/bloc/permits/client_permits_bloc.dart';
import 'features/client/bloc/permits/client_permits_event.dart';
import 'features/client/bloc/application_details/client_application_details_bloc.dart';
import 'features/client/bloc/new_application/client_new_application_bloc.dart';
import 'features/client/bloc/assessment/client_assessment_bloc.dart';
import 'features/client/bloc/invoice_details/client_invoice_details_bloc.dart';
import 'features/client/bloc/inspection_invoice_details/client_inspection_invoice_details_bloc.dart';
import 'features/client/bloc/profile/client_profile_bloc.dart';
import 'features/client/bloc/profile/client_profile_event.dart';
import 'features/professional/repositories/professional_repository.dart';
import 'features/professional/bloc/profile/professional_profile_bloc.dart';
import 'features/professional/bloc/profile/professional_profile_event.dart';
import 'features/professional/bloc/counters/professional_counters_bloc.dart';
import 'features/professional/bloc/counters/professional_counters_event.dart';
import 'features/professional/bloc/documents/professional_documents_bloc.dart';
import 'features/professional/bloc/documents/professional_documents_event.dart';
import 'features/professional/bloc/applications/professional_applications_bloc.dart';
import 'features/professional/bloc/applications/professional_applications_event.dart';
import 'features/professional/bloc/application_details/professional_application_details_bloc.dart';
import 'features/professional/bloc/attachments/professional_attachments_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register FCM background handler before Firebase is initialized.
  // This must be a top-level function.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Dependency injection setup
  await Hive.initFlutter();
  await Hive.openBox('auxiliaryBox');
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  final bcoApiClient = BcoApiClient();
  final proApiClient = ProApiClient();
  final auxiliaryRepository = AuxiliaryRepository(
    bcoApiClient: bcoApiClient,
    proApiClient: proApiClient,
    clientApiClient: apiClient,
  );
  final bcoRepository = BcoRepository(bcoApiClient: bcoApiClient);
  final clientRepository = ClientRepository(dio: apiClient.dio);
  final professionalRepository = ProfessionalRepository(
    proApiClient: proApiClient,
  );

  // Trigger background sync without awaiting
  auxiliaryRepository.syncAuxiliaryData();

  // Initialize Firebase Messaging (subscribe to topic, set up handlers).
  await NotificationService.instance.initialize(
    auxiliaryRepository: auxiliaryRepository,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: bcoApiClient),
        RepositoryProvider.value(value: proApiClient),
        RepositoryProvider.value(value: prefs),
        RepositoryProvider.value(value: clientRepository),
        RepositoryProvider.value(value: auxiliaryRepository),
        RepositoryProvider.value(value: bcoRepository),
        RepositoryProvider.value(value: professionalRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              dio: context.read<ApiClient>().dio,
              prefs: context.read<SharedPreferences>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => BcoAuthBloc(
              baseDio: context.read<ApiClient>().dio,
              prefs: context.read<SharedPreferences>(),
              bcoApiClient: context.read<BcoApiClient>(),
            )..add(BcoAuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) =>
                ProfessionalAuthBloc(proApiClient: context.read<ProApiClient>())
                  ..add(ProfessionalAuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ClientApplicationsBloc(
              repository: context.read<ClientRepository>(),
            )..add(FetchClientApplications()),
          ),
          BlocProvider(
            create: (context) =>
                BcoInvoicesBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                BcoApplicationsBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) => BcoApplicationDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoApplicationAttachmentsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoGeneralInvoicesBloc(
              repository: context.read<BcoRepository>(),
            )..add(FetchBcoGeneralInvoices()),
          ),
          BlocProvider(
            create: (context) => BcoInspectionInvoicesListBloc(
              repository: context.read<BcoRepository>(),
            )..add(FetchBcoInspectionInvoicesList()),
          ),
          BlocProvider(
            create: (context) => BcoExpressPenaltyInvoicesBloc(
              repository: context.read<BcoRepository>(),
            )..add(FetchBcoExpressPenaltyInvoices()),
          ),
          BlocProvider(
            create: (context) => BcoInvoiceDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoInspectionInvoiceDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                BcoProfileBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                BcoCountersBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                BcoPenaltiesBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) => BcoPenaltyDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                BcoCreatePenaltyBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(create: (context) => BcoCameraBloc()),
          BlocProvider(
            create: (context) =>
                BcoWhistleblowsBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) => BcoWhistleblowDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                BcoInspectionsBloc(repository: context.read<BcoRepository>()),
          ),
          BlocProvider(
            create: (context) => BcoInspectionDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoCreateInspectionBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                ClientInvoicesBloc(repository: context.read<ClientRepository>())
                  ..add(FetchClientInvoices()),
          ),
          BlocProvider(
            create: (context) => ClientInspectionInvoicesBloc(
              repository: context.read<ClientRepository>(),
            )..add(FetchClientInspectionInvoices()),
          ),
          BlocProvider(
            create: (context) =>
                ClientPermitsBloc(repository: context.read<ClientRepository>())
                  ..add(FetchClientPermits()),
          ),
          BlocProvider(
            create: (context) => ClientApplicationDetailsBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClientNewApplicationBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClientAssessmentBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClientInvoiceDetailsBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClientInspectionInvoiceDetailsBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClientPermitDetailsBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                ClientProfileBloc(repository: context.read<ClientRepository>())
                  ..add(FetchClientProfile()),
          ),
          BlocProvider(
            create: (context) => ForgotResetPasswordBloc(
              repository: context.read<ClientRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProForgotResetPasswordBloc(
              repository: context.read<ProfessionalRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoForgotResetPasswordBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfessionalProfileBloc(
              repository: context.read<ProfessionalRepository>(),
            )..add(FetchProfessionalProfile()),
          ),
          BlocProvider(
            create: (context) => ProfessionalCountersBloc(
              repository: context.read<ProfessionalRepository>(),
            )..add(FetchProfessionalCounters()),
          ),
          BlocProvider(
            create: (context) => ProfessionalDocumentsBloc(
              repository: context.read<ProfessionalRepository>(),
            )..add(FetchProfessionalDocuments()),
          ),
          BlocProvider(
            create: (context) => ProfessionalApplicationsBloc(
              repository: context.read<ProfessionalRepository>(),
            )..add(FetchProfessionalApplications()),
          ),
          BlocProvider(
            create: (context) => ProfessionalApplicationDetailsBloc(
              repository: context.read<ProfessionalRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfessionalAttachmentsBloc(
              repository: context.read<ProfessionalRepository>(),
            ),
          ),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BIMS Mobile',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
