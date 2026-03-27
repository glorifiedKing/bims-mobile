import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/applications/client_applications_bloc.dart';
import '../bloc/applications/client_applications_event.dart';
import '../bloc/applications/client_applications_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ClientApplicationsScreen extends StatelessWidget {
  const ClientApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
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
                            activeFilter == 'IN-REVIEW',
                          ),
                          _buildChip(
                            context,
                            'AWAITING ACTION',
                            activeFilter == 'AWAITING ACTION',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/client/new-application');
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
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
