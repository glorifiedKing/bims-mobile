import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/applications/client_applications_bloc.dart';
import '../bloc/applications/client_applications_event.dart';
import '../bloc/applications/client_applications_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../../core/help/help_controller.dart';
import '../../../core/help/help_step.dart';
import '../../../core/help/help_tour_overlay.dart';
import '../../../core/help/help_preferences.dart';

class ClientApplicationsScreen extends StatefulWidget {
  const ClientApplicationsScreen({super.key});

  @override
  State<ClientApplicationsScreen> createState() =>
      _ClientApplicationsScreenState();
}

class _ClientApplicationsScreenState extends State<ClientApplicationsScreen> {
  // ── Help tour ───────────────────────────────────────────────────────────────
  final _helpController  = HelpController();
  final _keyHeader       = GlobalKey();
  final _keyFilters      = GlobalKey();
  final _keyList         = GlobalKey();
  final _keyFab          = GlobalKey();
  final _keyBottomNav    = GlobalKey();

  List<HelpStep> get _helpSteps => [
    HelpStep(
      emoji: '📋',
      title: 'My Submissions',
      description:
          'This screen lists all the building permit applications you have '
          'submitted. Each card shows the reference number, type, location, '
          'and current status of your application.',
      targetKey: _keyHeader,
      cardPosition: HelpCardPosition.bottom,
    ),
    HelpStep(
      emoji: '🔍',
      title: 'Filter Applications',
      description:
          'Use these filter chips to narrow down your list. Choose ALL to '
          'see every submission, IN-REVIEW for applications being processed, '
          'AWAITING ACTION for ones that need your attention, or REJECTED '
          'for declined submissions.',
      targetKey: _keyFilters,
      cardPosition: HelpCardPosition.bottom,
    ),
    HelpStep(
      emoji: '📁',
      title: 'Application Cards',
      description:
          'Tap any card to view the full details of that application — '
          'including reviewer comments, required documents, and status history. '
          'Use the ✏️ edit icon to update an application that is still in review.',
      targetKey: _keyList,
    ),
    HelpStep(
      emoji: '➕',
      title: 'New Application',
      description:
          'Ready to apply for a new building permit? Tap the green + button '
          'to start a fresh application and follow the step-by-step form.',
      targetKey: _keyFab,
      cardPosition: HelpCardPosition.top,
    ),
    HelpStep(
      emoji: '🧭',
      title: 'Bottom Navigation',
      description:
          'Use this bar to switch between Home, Applications, Invoices, '
          'and your Profile at any time.',
      targetKey: _keyBottomNav,
      cardPosition: HelpCardPosition.top,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await HelpPreferences.hasSeenTour('tour_client_applications');
      if (!seen && mounted) {
        await HelpPreferences.markTourSeen('tour_client_applications');
        _helpController.start(_helpSteps);
      }
    });
  }

  @override
  void dispose() {
    _helpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HelpTourOverlay(
      controller: _helpController,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            // Header
            Container(
              key: _keyHeader,
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 20,
                left: 25,
                right: 25,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryGreen, Color(0xFF00331A)],
                ),
                border: Border(
                  bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Submissions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HelpIconButton(
                        controller: _helpController,
                        steps: _helpSteps,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/client/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filters
            Container(
              key: _keyFilters,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:
                    BlocBuilder<ClientApplicationsBloc, ClientApplicationsState>(
                      builder: (context, state) {
                        String activeFilter = 'ALL';
                        if (state is ClientApplicationsLoaded) {
                          activeFilter = state.selectedFilter;
                        }
                        return Row(
                          children: [
                            _buildChip(context, 'ALL', activeFilter == 'ALL'),
                            _buildChip(
                              context,
                              'IN-REVIEW',
                              activeFilter == 'PENDING',
                            ),
                            _buildChip(
                              context,
                              'AWAITING ACTION',
                              activeFilter == 'APPROVED',
                            ),
                            _buildChip(
                              context,
                              'REJECTED',
                              activeFilter == 'REJECTED',
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ),

            // List Area
            Expanded(
              key: _keyList,
              child: BlocBuilder<ClientApplicationsBloc, ClientApplicationsState>(
                builder: (context, state) {
                  if (state is ClientApplicationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ClientApplicationsError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is ClientApplicationsLoaded) {
                    if (state.applications.isEmpty) {
                      return const Center(child: Text('No applications found.'));
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!scrollInfo.metrics.outOfRange &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                          context.read<ClientApplicationsBloc>().add(
                            LoadMoreClientApplications(),
                          );
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount:
                            state.applications.length +
                            (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.applications.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final app = state.applications[index];
                          // Format date if needed, or use as is based on API format
                          String formattedDate = app.submittedDate;
                          try {
                            DateTime dt = DateTime.parse(app.submittedDate);
                            List<String> months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            String monthStr = dt.month >= 1 && dt.month <= 12
                                ? months[dt.month - 1]
                                : dt.month.toString();
                            formattedDate =
                                '$monthStr ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
                          } catch (_) {}

                          // Determine colors based on status
                          Color statusColor = Colors.grey;
                          Color statusBg = Colors.grey.shade200;
                          Color borderColor = Colors.grey;

                          if (app.status.toUpperCase() == 'IN-REVIEW') {
                            statusColor = const Color(0xFFB8860B);
                            statusBg = const Color(0xFFFFF9E6);
                            borderColor = AppTheme.accentGold;
                          } else if (app.status.toUpperCase().contains(
                            'AWAITING',
                          )) {
                            statusColor = Colors.blue;
                            statusBg = const Color(0xFFE8F4FD);
                            borderColor = Colors.blue;
                          }

                          return GestureDetector(
                            onTap: () {
                              context.push('/client/applications/${app.id}');
                            },
                            child: _buildAppCard(
                              context: context,
                              refNo: app.id,
                              statusText: app.status.toUpperCase(),
                              statusColor: statusColor,
                              statusBg: statusBg,
                              type: app.type,
                              location: app.location,
                              subDate: formattedDate,
                              borderColor: borderColor,
                              showEdit: app.status.toUpperCase() != 'PAID',
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: Text('Initializing...'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          key: _keyFab,
          onPressed: () {
            context.push('/client/new-application');
          },
          backgroundColor: AppTheme.primaryGreen,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          key: _keyBottomNav,
          currentIndex: 1, // Applications index
          onTap: (index) {
            if (index == 0) context.go('/client/dashboard');
            if (index == 1) return;
            if (index == 2) context.go('/client/invoices');
            if (index == 3) context.go('/client/profile');
          },
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Applications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Invoices'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    ); // HelpTourOverlay
  }

  Widget _buildChip(BuildContext context, String label, bool active) {
    return GestureDetector(
      onTap: () {
        context.read<ClientApplicationsBloc>().add(
          ChangeClientApplicationsFilter(label),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryGreen : Colors.white,
          border: Border.all(
            color: active ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAppCard({
    required BuildContext context,
    required String refNo,
    required String statusText,
    required Color statusColor,
    required Color statusBg,
    required String type,
    required String location,
    required String subDate,
    required Color borderColor,
    bool showEdit = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE)), // Uniform border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: borderColor), // Left border accent
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            refNo,
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showEdit)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16, color: AppTheme.accentGold),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.push('/client/edit-application/$refNo');
                            },
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem('Application Type', type),
                    const SizedBox(height: 8),
                    _buildDetailItem('Building Location', location),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sub: $subDate',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.insert_drive_file, size: 14),
                          label: const Text('SUMMARY PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(
                              color: AppTheme.primaryGreen,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
