import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/professional_auth_bloc.dart';
import '../../auth/bloc/professional_auth_state.dart';
import '../bloc/profile/professional_profile_bloc.dart';
import '../bloc/profile/professional_profile_state.dart';
import '../bloc/applications/professional_applications_bloc.dart';
import '../bloc/applications/professional_applications_event.dart';
import '../bloc/applications/professional_applications_state.dart';

class ProfessionalApplicationsScreen extends StatefulWidget {
  const ProfessionalApplicationsScreen({super.key});

  @override
  State<ProfessionalApplicationsScreen> createState() => _ProfessionalApplicationsScreenState();
}

class _ProfessionalApplicationsScreenState extends State<ProfessionalApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfessionalApplicationsBloc>().add(
      FetchProfessionalApplications(status: 'ALL'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Professional Header
          BlocBuilder<ProfessionalProfileBloc, ProfessionalProfileState>(
            builder: (context, state) {
              String name = 'Loading...';
              String profession = 'PROFESSIONAL';

              if (state is ProfessionalProfileLoaded) {
                name = state.profile.name;
                profession = state.profile.profession.toUpperCase();
              } else if (state is ProfessionalProfileError) {
                name = 'Professional';
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
                              profession,
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
                            color: Colors.white.withValues(alpha: 0.15),
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
              child: BlocBuilder<ProfessionalApplicationsBloc, ProfessionalApplicationsState>(
                builder: (context, state) {
                  String activeFilter = 'ALL';
                  if (state is ProfessionalApplicationsLoaded) {
                    activeFilter = state.currentFilter;
                  }
                  return Row(
                    children: [
                      _buildChip(context, 'ALL', activeFilter == 'ALL'),
                      _buildChip(context, 'PENDING', activeFilter == 'PENDING'),
                      _buildChip(context, 'CONFIRMED', activeFilter == 'CONFIRMED'),
                      _buildChip(context, 'NOT CONFIRMED', activeFilter == 'NOT CONFIRMED'),
                    ],
                  );
                },
              ),
            ),
          ),

          // List Area
          Expanded(
            child: BlocBuilder<ProfessionalApplicationsBloc, ProfessionalApplicationsState>(
              builder: (context, state) {
                if (state is ProfessionalApplicationsLoading || state is ProfessionalApplicationsInitial) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                } else if (state is ProfessionalApplicationsError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: AppTheme.danger),
                    ),
                  );
                } else if (state is ProfessionalApplicationsLoaded) {
                  if (state.applications.isEmpty) {
                    return const Center(child: Text('No applications found.'));
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!scrollInfo.metrics.outOfRange &&
                          scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                        context.read<ProfessionalApplicationsBloc>().add(
                          LoadMoreProfessionalApplications(),
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
                            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                          );
                        }
                        final app = state.applications[index];
                        String formattedDate = app.createdOn ?? 'Unknown Date';
                        try {
                          if (app.createdOn != null) {
                            DateTime dt = DateTime.parse(app.createdOn!);
                            List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                            String monthStr = dt.month >= 1 && dt.month <= 12 ? months[dt.month - 1] : dt.month.toString();
                            formattedDate = '$monthStr ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
                          }
                        } catch (_) {}

                        Color statusColor = Colors.grey;
                        Color statusBg = Colors.grey.shade200;
                        Color borderColor = Colors.grey;

                        if (app.status.toUpperCase() == 'PENDING') {
                          statusColor = const Color(0xFFB8860B);
                          statusBg = const Color(0xFFFFF9E6);
                          borderColor = AppTheme.accentGold;
                        } else if (app.status.toUpperCase() == 'NOT CONFIRMED' || app.status.toUpperCase() == 'NOT  CONFIRMED') {
                          statusColor = AppTheme.danger;
                          statusBg = const Color(0xFFFFEBEB);
                          borderColor = AppTheme.danger;
                        } else if (app.status.toUpperCase() == 'CONFIRMED') {
                          statusColor = AppTheme.primaryGreen;
                          statusBg = const Color(0xFFE8F5E9);
                          borderColor = AppTheme.primaryGreen;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (app.applicantKey != null && app.applicantKey!.isNotEmpty) {
                              context.push('/professional/applications/${app.applicantKey}');
                            }
                          },
                          child: _buildAppCard(
                            code: app.code,
                            statusText: app.status.toUpperCase(),
                            statusColor: statusColor,
                            statusBg: statusBg,
                            developerName: app.developerName ?? 'Unknown Developer',
                            createdDate: formattedDate,
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
          if (index == 0) context.go('/professional/dashboard');
          if (index == 1) return;
          if (index == 2) context.go('/professional/profile');
        },
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool active) {
    return GestureDetector(
      onTap: () {
        context.read<ProfessionalApplicationsBloc>().add(
          FetchProfessionalApplications(status: label),
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
    required String code,
    required String statusText,
    required Color statusColor,
    required Color statusBg,
    required String developerName,
    required String createdDate,
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
            color: Colors.black.withValues(alpha: 0.03),
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
                          code,
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
                    _buildDetailItem('Developer Name', developerName),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 12),
                    Text(
                      'Created: $createdDate',
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
