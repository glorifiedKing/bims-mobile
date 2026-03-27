import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/profile/client_profile_bloc.dart';
import '../bloc/profile/client_profile_state.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocBuilder<ClientProfileBloc, ClientProfileState>(
        builder: (context, state) {
          if (state is ClientProfileLoading || state is ClientProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          } else if (state is ClientProfileError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is ClientProfileLoaded) {
            final profile = state.profile;
            final names = profile.names.trim();
            final initials = names.isNotEmpty
                ? names
                      .split(' ')
                      .take(2)
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .join()
                      .toUpperCase()
                : 'U';

            return Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentGold,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        names,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'CLIENT PORTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Container
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildInfoCard(
                        label: 'NATIONAL ID (NIN)',
                        value: profile.ninNumber.isNotEmpty
                            ? profile.ninNumber
                            : '-',
                      ),
                      if (profile.tinNumber.isNotEmpty)
                        _buildInfoCard(
                          label: 'TIN NUMBER',
                          value: profile.tinNumber,
                        ),
                      _buildInfoCard(
                        label: 'CONTACT DETAILS',
                        valueWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.phone,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const Divider(height: 16, color: Color(0xFFF0F0F0)),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildInfoCard(
                        label: 'CLIENT TYPE',
                        value: profile.accountType.isNotEmpty
                            ? profile.accountType
                            : 'Unknown',
                        isRoleSection: false,
                      ),

                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          context.push(
                            '/client/profile/edit',
                            extra: {
                              'email': profile.email,
                              'phone': profile.phone,
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.grey.shade200,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/client/login');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          side: const BorderSide(
                            color: AppTheme.danger,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: AppTheme.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile index
        onTap: (index) {
          if (index == 0) context.go('/client/dashboard');
          if (index == 1) context.go('/client/applications');
          if (index == 2) context.go('/client/invoices');
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

  Widget _buildInfoCard({
    required String label,
    String? value,
    Widget? valueWidget,
    bool isRoleSection = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(
          top: const BorderSide(color: Color(0xFFEEEEEE)),
          right: const BorderSide(color: Color(0xFFEEEEEE)),
          bottom: const BorderSide(color: Color(0xFFEEEEEE)),
          left: isRoleSection
              ? const BorderSide(color: AppTheme.accentGold, width: 4)
              : const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isRoleSection ? AppTheme.accentGold : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              (value != null && value.isNotEmpty) ? value : 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
        ],
      ),
    );
  }
}
