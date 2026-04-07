import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/client/bloc/permit_details/client_permit_details_bloc.dart';
import 'core/theme.dart';
import 'core/routing/app_router.dart';
import 'core/network/api_client.dart';
import 'core/network/bco_api_client.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/repositories/auxiliary_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/bco_auth_bloc.dart';
import 'features/auth/bloc/bco_auth_event.dart';
import 'features/auth/bloc/professional_auth_bloc.dart';
import 'features/auth/bloc/professional_auth_event.dart';
import 'features/bco/repositories/bco_repository.dart';
import 'features/bco/bloc/invoices/bco_invoices_bloc.dart';
import 'features/bco/bloc/applications/bco_applications_bloc.dart';
import 'features/bco/bloc/application_details/bco_application_details_bloc.dart';
import 'features/bco/bloc/general_invoices/bco_general_invoices_bloc.dart';
import 'features/bco/bloc/general_invoices/bco_general_invoices_event.dart';
import 'features/bco/bloc/inspection_invoices_list/bco_inspection_invoices_list_bloc.dart';
import 'features/bco/bloc/inspection_invoices_list/bco_inspection_invoices_list_event.dart';
import 'features/bco/bloc/invoice_details/bco_invoice_details_bloc.dart';
import 'features/bco/bloc/inspection_invoice_details/bco_inspection_invoice_details_bloc.dart';
import 'features/bco/bloc/profile/bco_profile_bloc.dart';
import 'features/bco/bloc/counters/bco_counters_bloc.dart';
import 'features/bco/bloc/penalties/bco_penalties_bloc.dart';
import 'features/bco/bloc/penalty_details/bco_penalty_details_bloc.dart';
import 'features/bco/bloc/create_penalty/bco_create_penalty_bloc.dart';
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
import 'features/client/bloc/invoice_details/client_invoice_details_bloc.dart';
import 'features/client/bloc/inspection_invoice_details/client_inspection_invoice_details_bloc.dart';
import 'features/client/bloc/profile/client_profile_bloc.dart';
import 'features/client/bloc/profile/client_profile_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency injection setup
  await Hive.initFlutter();
  await Hive.openBox('auxiliaryBox');
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  final bcoApiClient = BcoApiClient();
  final auxiliaryRepository = AuxiliaryRepository(bcoApiClient: bcoApiClient);
  final bcoRepository = BcoRepository(bcoApiClient: bcoApiClient);
  final clientRepository = ClientRepository(dio: apiClient.dio);
  
  // Trigger background sync without awaiting
  auxiliaryRepository.syncAuxiliaryData();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: bcoApiClient),
        RepositoryProvider.value(value: prefs),
        RepositoryProvider.value(value: clientRepository),
        RepositoryProvider.value(value: auxiliaryRepository),
        RepositoryProvider.value(value: bcoRepository),
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
                ProfessionalAuthBloc(apiClient: context.read<ApiClient>())
                  ..add(ProfessionalAuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ClientApplicationsBloc(
              repository: context.read<ClientRepository>(),
            )..add(FetchClientApplications()),
          ),
          BlocProvider(
            create: (context) => BcoInvoicesBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoApplicationsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoApplicationDetailsBloc(
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
            create: (context) => BcoProfileBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoCountersBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoPenaltiesBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoPenaltyDetailsBloc(
              repository: context.read<BcoRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BcoCreatePenaltyBloc(
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
                repository: context.read<ClientRepository>())
              ..add(FetchClientInspectionInvoices()),
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
