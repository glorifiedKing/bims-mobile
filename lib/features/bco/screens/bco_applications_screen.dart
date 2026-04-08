import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_state.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../bloc/applications/bco_applications_bloc.dart';
import '../bloc/applications/bco_applications_event.dart';
import '../bloc/applications/bco_applications_state.dart';

class BcoApplicationsScreen extends StatefulWidget {
  const BcoApplicationsScreen({super.key});

  @override
  State<BcoApplicationsScreen> createState() => _BcoApplicationsScreenState();
}

class _BcoApplicationsScreenState extends State<BcoApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoApplicationsBloc>().add(
      FetchBcoApplications(status: 'ALL'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Inspector Header
          BlocBuilder<BcoAuthBloc, BcoAuthState>(
            builder: (context, state) {
              String name = 'Officer';
              String roleName = 'BUILDING CONTROL OFFICER';
              String adminUnitName = 'NBRB';

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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.folder,
                                size: 14,
                                color: AppTheme.accentGold,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'APPLICATIONS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: BlocBuilder<BcoApplicationsBloc, BcoApplicationsState>(
                builder: (context, state) {
                  String activeFilter = 'ALL';
                  if (state is BcoApplicationsLoaded) {
                    activeFilter = state.currentFilter ?? 'ALL';
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
            child: BlocBuilder<BcoApplicationsBloc, BcoApplicationsState>(
              builder: (context, state) {
                if (state is BcoApplicationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BcoApplicationsError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is BcoApplicationsLoaded) {
                  if (state.applications.isEmpty) {
                    return const Center(child: Text('No applications found.'));
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!scrollInfo.metrics.outOfRange &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                        context.read<BcoApplicationsBloc>().add(
                          LoadMoreBcoApplications(),
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
                        } else if (app.status.toUpperCase() == 'APPROVED') {
                          statusColor = AppTheme.primaryGreen;
                          statusBg = const Color(0xFFE8F5E9);
                          borderColor = AppTheme.primaryGreen;
                        }

                        return GestureDetector(
                          onTap: () {
                            context.push('/bco/applications/${app.id}');
                          },
                          child: _buildAppCard(
                            refNo: app.id,
                            statusText: app.status.toUpperCase(),
                            statusColor: statusColor,
                            statusBg: statusBg,
                            type: app.type,
                            location: app.location,
                            subDate: formattedDate,
                            borderColor: borderColor,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/bco/dashboard');
          if (index == 1) return;
          if (index == 2) context.go('/bco/invoices');
          if (index == 3) context.go('/bco/profile');
        },
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool active) {
    return GestureDetector(
      onTap: () {
        context.read<BcoApplicationsBloc>().add(
          FetchBcoApplications(status: label, isRefresh: true),
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
    required String refNo,
    required String statusText,
    required Color statusColor,
    required Color statusBg,
    required String type,
    required String location,
    required String subDate,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE)),
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
            Container(width: 4, color: borderColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          refNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
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
                    Text(
                      'Sub: $subDate',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
