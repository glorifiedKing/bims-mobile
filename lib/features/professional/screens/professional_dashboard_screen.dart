import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile/professional_profile_bloc.dart';
import '../bloc/profile/professional_profile_state.dart';
import '../bloc/counters/professional_counters_bloc.dart';
import '../bloc/counters/professional_counters_state.dart';
import '../../auth/bloc/professional_auth_bloc.dart';
import '../../auth/bloc/professional_auth_event.dart';
import '../../auth/bloc/professional_auth_state.dart';

class ProfessionalDashboardScreen extends StatelessWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalAuthBloc, ProfessionalAuthState>(
      listener: (context, state) {
        if (state is ProfessionalAuthUnauthenticated) {
          context.go('/professional/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // bg from wireframe
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<
                    ProfessionalProfileBloc,
                    ProfessionalProfileState
                  >(
                    builder: (context, state) {
                      String name = 'Loading...';
                      if (state is ProfessionalProfileLoaded) {
                        name = state.profile.name;
                      } else if (state is ProfessionalProfileError) {
                        name = 'Professional';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              state is ProfessionalProfileLoaded
                                  ? '${state.profile.profession.toUpperCase()}'
                                  : 'PROFESSIONAL',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<ProfessionalAuthBloc>().add(
                        ProfessionalAuthLogoutRequested(),
                      );
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
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Scroll Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'APPLICATION STATISTICS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),

                  BlocBuilder<
                    ProfessionalCountersBloc,
                    ProfessionalCountersState
                  >(
                    builder: (context, state) {
                      if (state is ProfessionalCountersLoading ||
                          state is ProfessionalCountersInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                        );
                      }
                      if (state is ProfessionalCountersError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      if (state is ProfessionalCountersLoaded) {
                        final counters = state.counters;
                        return Row(
                          children: [
                            Expanded(
                              child: _buildCounterCard(
                                title: 'TOTAL',
                                value: counters.total.toString(),
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCounterCard(
                                title: 'CONFIRMED',
                                value: counters.confirmed.toString(),
                                color: AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCounterCard(
                                title: 'PENDING',
                                value: counters.unconfirmed.toString(),
                                color: AppTheme.danger,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    'PROFESSIONAL TOOLKIT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Toolkit Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildToolBox(
                        icon: '🔗',
                        label: 'LINK PROJECT',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Scan Client QR Code to Link Project',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildToolBox(
                        icon: '📐',
                        label: 'DRAWINGS',
                        onTap: () {},
                      ),
                      _buildToolBox(
                        icon: '📝',
                        label: 'SITE LOGS',
                        onTap: () {},
                      ),
                      _buildToolBox(
                        icon: '💬',
                        label: 'BCO QUERIES',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              context.push('/professional/applications');
            } else if (index == 2) {
              context.push('/professional/profile');
            }
          },
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: const Color(0xFF999999),
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment, size: 28),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(bottom: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF999999),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildToolBox({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
