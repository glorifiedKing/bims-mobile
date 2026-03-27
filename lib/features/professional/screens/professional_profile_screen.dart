import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/professional_auth_bloc.dart';
import '../../auth/bloc/professional_auth_event.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            width: double.infinity,
            decoration: const BoxDecoration(color: AppTheme.primaryGreen),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEEEEEE),
                    border: Border.all(color: AppTheme.accentGold, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      'RB',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Raymond Byaruhanga',
                  style: TextStyle(
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
                    'PROFESSIONAL PORTAL',
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
                  label: 'National ID (NIN)',
                  children: [
                    const Text(
                      'CM870****WGE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                _buildInfoCard(
                  label: 'Contact Details',
                  children: [
                    const Text(
                      '+256 704 555 432',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const Divider(color: Color(0xFFF0F0F0), height: 16),
                    const Text(
                      'raymond@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                _buildInfoCard(
                  label: 'Board Registration (ARB)',
                  labelColor: AppTheme.accentGold,
                  isRoleSection: true,
                  children: [
                    const Text(
                      'License No: A-442',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PRACTICING STAMP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        border: Border.all(
                          color: const Color(0xFFCCCCCC),
                          width: 1,
                        ), // Using solid border instead of dashed out of box
                      ),
                      child: const Center(
                        child: Text(
                          'STAMP',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    backgroundColor: const Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    context.read<ProfessionalAuthBloc>().add(
                      ProfessionalAuthLogoutRequested(),
                    );
                    context.go('/professional/login');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppTheme.danger, width: 1.5),
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/professional/dashboard');
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

  Widget _buildInfoCard({
    required String label,
    required List<Widget> children,
    Color labelColor = const Color(0xFF999999),
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
          left: BorderSide(
            color: isRoleSection
                ? AppTheme.accentGold
                : const Color(0xFFEEEEEE),
            width: isRoleSection ? 4 : 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
