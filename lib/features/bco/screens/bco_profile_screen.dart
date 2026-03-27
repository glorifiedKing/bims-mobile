import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_event.dart';
import '../bloc/profile/bco_profile_bloc.dart';
import '../bloc/profile/bco_profile_event.dart';
import '../bloc/profile/bco_profile_state.dart';

class BcoProfileScreen extends StatefulWidget {
  const BcoProfileScreen({super.key});

  @override
  State<BcoProfileScreen> createState() => _BcoProfileScreenState();
}

class _BcoProfileScreenState extends State<BcoProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoProfileBloc>().add(FetchBcoProfile());
  }

  void _logout() {
    context.read<BcoAuthBloc>().add(BcoAuthLogoutRequested());
    context.go('/bco/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<BcoProfileBloc, BcoProfileState>(
        builder: (context, state) {
          if (state is BcoProfileLoading || state is BcoProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BcoProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 15),
                    Text(
                      'Failed to load profile details\n${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is BcoProfileLoaded) {
            final profile = state.profile;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfileCard(profile),
                const SizedBox(height: 25),
                _buildSectionTitle('Administrative Information'),
                const SizedBox(height: 10),
                _buildInfoCard([
                  _buildDetailRow('Unit Type', profile.administrativeUnitType),
                  _buildDetailRow('Unit Name', profile.administrativeUnitName),
                ]),
                const SizedBox(height: 25),
                _buildSectionTitle('System Data'),
                const SizedBox(height: 10),
                _buildInfoCard([
                  _buildDetailRow('Created On', profile.createdOn),
                  _buildDetailRow('Last Updated', profile.updatedOn),
                ]),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('LOGOUT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    onPressed: _logout,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/bco/dashboard');
          if (index == 1) context.go('/bco/applications');
          if (index == 2) context.go('/bco/invoices');
          if (index == 3) return;
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

  Widget _buildProfileCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.names,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email, size: 12, color: Colors.grey),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        profile.email,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                if (profile.phone != null && profile.phone.toString().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        profile.phone!,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
