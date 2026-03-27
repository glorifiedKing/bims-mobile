import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_state.dart';
import '../../auth/bloc/bco_auth_event.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/invoices/bco_invoices_bloc.dart';
import '../bloc/invoices/bco_invoices_event.dart';
import '../bloc/invoices/bco_invoices_state.dart';
import '../bloc/counters/bco_counters_bloc.dart';
import '../bloc/counters/bco_counters_event.dart';
import '../bloc/counters/bco_counters_state.dart';

class BcoDashboardScreen extends StatefulWidget {
  const BcoDashboardScreen({super.key});

  @override
  State<BcoDashboardScreen> createState() => _BcoDashboardScreenState();
}

class _BcoDashboardScreenState extends State<BcoDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoInvoicesBloc>().add(FetchBcoInvoicesTotal());
    context.read<BcoCountersBloc>().add(FetchBcoCounters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F0), // bg-field from wireframe
      body: Column(
        children: [
          // Inspector Header
          BlocBuilder<BcoAuthBloc, BcoAuthState>(
            builder: (context, state) {
              String name = 'Officer';
              String roleName = 'BUILDING CONTROL OFFICER';
              String adminUnitName = 'Unknown Region';

              if (state is BcoAuthAuthenticated) {
                final user = state.user;
                name = '${user.fname} ${user.lname}';

                final auxRepo = context.read<AuxiliaryRepository>();

                // Get Role Name
                final roles = auxRepo.getUserRoles();
                final roleObj = roles.cast().firstWhere(
                  (r) => r.id == user.roleId,
                  orElse: () => null,
                );
                if (roleObj != null) roleName = roleObj.name;

                // Get Admin Unit Name
                if (user.administrativeUnitId != null) {
                  final units = auxRepo.getAllAdminUnits();
                  final unitObj = units.cast().firstWhere(
                    (u) => u.id == user.administrativeUnitId,
                    orElse: () => null,
                  );
                  if (unitObj != null) adminUnitName = unitObj.name;
                }
              }

              return Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 20,
                  left: 25,
                  right: 25,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00331a), AppTheme.primaryGreen],
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roleName.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<BcoAuthBloc>().add(BcoAuthLogoutRequested());
                            context.go('/bco/login');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.logout, color: Colors.white, size: 18),
                                SizedBox(height: 4),
                                Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: "Region: "),
                          TextSpan(
                            text: adminUnitName,
                            style: const TextStyle(color: AppTheme.accentGold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                BlocBuilder<BcoInvoicesBloc, BcoInvoicesState>(
                  builder: (context, state) {
                    String generalAmount = 'UGX 0';
                    String inspectionAmount = 'UGX 0';
                    
                    if (state is BcoInvoicesLoaded) {
                      if (state.generalTotal.isNotEmpty && state.generalTotal != '0.00' && state.generalTotal != '0') {
                        try {
                          generalAmount = CurrencyFormatter.formatUgx(double.parse(state.generalTotal));
                        } catch (_) {}
                      }
                      if (state.inspectionTotal.isNotEmpty && state.inspectionTotal != '0.00' && state.inspectionTotal != '0') {
                        try {
                          inspectionAmount = CurrencyFormatter.formatUgx(double.parse(state.inspectionTotal));
                        } catch (_) {}
                      }
                    } else if (state is BcoInvoicesLoading) {
                      generalAmount = 'Loading...';
                      inspectionAmount = 'Loading...';
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildInvoiceDashboardCard(
                            title: 'General Invoices',
                            amount: generalAmount,
                            icon: '📄',
                            color: const Color(0xFFE8F5E9),
                            onTap: () {
                              context.push('/bco/invoices', extra: {'tabIndex': 0});
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildInvoiceDashboardCard(
                            title: 'Inspection Fees',
                            amount: inspectionAmount,
                            icon: '🏗️',
                            color: const Color(0xFFFFF8E1),
                            onTap: () {
                              context.push('/bco/invoices', extra: {'tabIndex': 1});
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),

                const Text(
                  'APPLICATIONS OVERVIEW',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),
                BlocBuilder<BcoCountersBloc, BcoCountersState>(
                  builder: (context, state) {
                    if (state is BcoCountersLoading || state is BcoCountersInitial) {
                      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                    } else if (state is BcoCountersError) {
                      return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
                    } else if (state is BcoCountersLoaded) {
                      final counters = state.counters;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.0,
                        children: [
                          _buildCounterWidget(
                            'New Applications',
                            counters.totalNewApplications.toString(),
                            Icons.fiber_new_rounded,
                            const Color(0xFFE8F4FD),
                            Colors.blue,
                            () => context.push('/bco/applications'),
                          ),
                          _buildCounterWidget(
                            'Pending',
                            counters.totalPendingSubmissions.toString(),
                            Icons.pending_actions,
                            const Color(0xFFFFF9E6),
                            const Color(0xFFB8860B),
                            () => context.push('/bco/applications'),
                          ),
                          _buildCounterWidget(
                            'Approved',
                            counters.totalApprovedApplications.toString(),
                            Icons.check_circle_outline,
                            const Color(0xFFE8F5E9),
                            AppTheme.primaryGreen,
                            () => context.push('/bco/applications'),
                          ),
                          _buildCounterWidget(
                            'Deferred',
                            counters.totalDeferred.toString(),
                            Icons.pause_circle_outline,
                            const Color(0xFFFFEBEE),
                            AppTheme.danger,
                            () => context.push('/bco/applications'),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 25),

                const Text(
                  'INSPECTOR TOOLKIT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 15),

                // Toolkit Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildToolkitItem(
                      icon: '📸',
                      label: 'AI Camera',
                      onTap: () {
                        context.push('/bco/camera');
                      },
                    ),
                    _buildToolkitItem(
                      icon: '🚫',
                      label: 'Stop Order',
                      isDanger: true,
                      onTap: () {
                        context.push('/bco/stop-order');
                      },
                    ),
                    _buildToolkitItem(
                      icon: '🏛️',
                      label: 'Committees',
                      onTap: () {},
                    ),
                    _buildToolkitItem(
                      icon: '📅',
                      label: 'Calendar',
                      onTap: () {
                        context.push('/bco/calendar');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),

                // Inspection Planner (Moved from top to bottom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NEXT INSPECTION',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TODAY, MARCH 5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Inspection Card
                Container(
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: const Border(
                      left: BorderSide(color: AppTheme.primaryGreen, width: 5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '#BIMS-OPS-992',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F4EA),
                              border: Border.all(
                                color: const Color(0xFFC3E6CB),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AI ENHANCED',
                              style: TextStyle(
                                color: Color(0xFF1E7E34),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Commercial Plaza - Plot 19 Lumumba Ave',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.location_on, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '0.8 KM Away',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '10:30 AM',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/bco/checklist');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'START INSPECTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) context.go('/bco/applications');
          if (index == 2) context.go('/bco/invoices');
          if (index == 3) context.go('/bco/profile');
        },
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoices'),
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

  Widget _buildToolkitItem({
    required String icon,
    required String label,
    bool isDanger = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDanger ? const Color(0xFFFFD6D6) : const Color(0xFFE0E6E0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDanger ? AppTheme.danger : AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterWidget(String title, String count, IconData icon, Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: textColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: textColor, size: 24),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
