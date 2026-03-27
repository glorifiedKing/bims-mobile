import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/applications/client_applications_bloc.dart';
import '../bloc/applications/client_applications_state.dart';
import '../bloc/profile/client_profile_bloc.dart';
import '../bloc/profile/client_profile_state.dart';
import '../bloc/invoices/client_invoices_bloc.dart';
import '../bloc/invoices/client_invoices_state.dart';
import '../bloc/inspection_invoices/client_inspection_invoices_bloc.dart';
import '../bloc/inspection_invoices/client_inspection_invoices_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/application_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) return; // Already on Home/Dashboard
    if (index == 1) context.go('/client/applications');
    if (index == 2) context.go('/client/invoices');
    if (index == 3) context.go('/client/profile');
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 17) {
      return 'Good Afternoon,';
    }
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 25,
              right: 25,
              bottom: 20,
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
                BlocBuilder<ClientProfileBloc, ClientProfileState>(
                  builder: (context, profileState) {
                    String firstName = 'Client';
                    if (profileState is ClientProfileLoaded) {
                      final parts = profileState.profile.names.trim().split(
                        ' ',
                      );
                      if (parts.isNotEmpty) {
                        firstName = parts.first;
                      }
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Stack(
                  children: [
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
                        child: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Unpaid Invoices Section
                const Text(
                  'UNPAID INVOICES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<ClientInvoicesBloc, ClientInvoicesState>(
                        builder: (context, state) {
                          String amount = 'UGX 0';
                          if (state is ClientInvoicesLoaded && state.totalUnpaid != null && state.totalUnpaid != '0.00' && state.totalUnpaid != '0') {
                            try {
                              amount = CurrencyFormatter.formatUgx(double.parse(state.totalUnpaid!));
                            } catch (_) {}
                          }
                          return _buildInvoiceDashboardCard(
                            title: 'General Invoices',
                            amount: amount,
                            icon: '📄',
                            color: const Color(0xFFE8F5E9),
                            onTap: () => context.push('/client/invoices'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: BlocBuilder<ClientInspectionInvoicesBloc, ClientInspectionInvoicesState>(
                        builder: (context, state) {
                          String amount = 'UGX 0';
                          if (state is ClientInspectionInvoicesLoaded && state.totalUnpaid != null && state.totalUnpaid != '0.00' && state.totalUnpaid != '0') {
                            try {
                              amount = CurrencyFormatter.formatUgx(double.parse(state.totalUnpaid!));
                            } catch (_) {}
                          }
                          return _buildInvoiceDashboardCard(
                            title: 'Inspection Fees',
                            amount: amount,
                            icon: '🏗️',
                            color: const Color(0xFFFFF8E1),
                            onTap: () => context.push(
                              '/client/invoices',
                              extra: {'tabIndex': 1},
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Quick Actions Section
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionItem(
                      icon: '🏗️',
                      label: 'New Application',
                      onTap: () {
                        context.push('/client/new-application');
                      },
                    ),
                    _buildActionItem(
                      icon: '💳',
                      label: 'Payments / PRN',
                      onTap: () {
                        context.push('/client/invoices');
                      },
                    ),
                    _buildActionItem(
                      icon: '📜',
                      label: 'My Permits',
                      onTap: () {
                        context.push('/client/permits');
                      },
                    ),
                    _buildActionItem(
                      icon: '📢',
                      label: 'Whistle Blow',
                      onTap: () {
                        context.push('/whistle-blow');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Recent Activity
                const Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActivityRow(
                        color: AppTheme.accentGold,
                        text: 'Reviewer added comments to KLA-2026-045',
                      ),
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      _buildActivityRow(
                        color: Colors.green,
                        text: 'Payment of 85,000 UGX verified',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Active Applications Section (Moved from top)
                const Text(
                  'ACTIVE APPLICATIONS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                BlocBuilder<ClientApplicationsBloc, ClientApplicationsState>(
                  builder: (context, state) {
                    if (state is ClientApplicationsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientApplicationsError) {
                      return Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      );
                    } else if (state is ClientApplicationsLoaded) {
                      if (state.applications.isEmpty) {
                        return const Center(
                          child: Text('No active applications.'),
                        );
                      }
                      final app = state.applications.first;
                      return _buildStatusCard(app);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
    );
  }

  Widget _buildInvoiceDashboardCard({
    required String title,
    required String amount,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ApplicationModel app) {
    // Format dates
    String subDateFormatted = app.submittedDate;
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
      subDateFormatted = '$monthStr ${dt.day}';
    } catch (_) {}

    String estDateFormatted = app.estCompletion;
    try {
      if (app.estCompletion.isNotEmpty) {
        DateTime dt = DateTime.parse(app.estCompletion);
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
        estDateFormatted = '$monthStr ${dt.day}';
      }
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          left: BorderSide(color: AppTheme.accentGold, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${app.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  app.status.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${app.type} - ${app.location}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 15),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: app.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submitted: $subDateFormatted',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                'Est. Completion: $estDateFormatted',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFEEF2EF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow({required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
            ),
          ),
        ],
      ),
    );
  }
}
