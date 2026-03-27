import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class ProfessionalDashboardScreen extends StatelessWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eng. Raymond B.',
                      style: TextStyle(
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
                      child: const Text(
                        'ERB ACTIVE (2026)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🖋️', style: TextStyle(fontSize: 20)),
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
                  'PROJECT SUPERVISION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 15),

                // Project Card
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: const Border(
                      left: BorderSide(color: AppTheme.accentGold, width: 5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.danger,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SIGNATURE REQ.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Plot 14, Mutungo Complex',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Client: Byaruhanga Raymond',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 10,
                            ),
                          ),
                          Divider(
                            color: Color(0xFFF0F0F0),
                            height: 20,
                            thickness: 1,
                          ),
                          Text(
                            'Status: Pending Structural Sign-off',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                    _buildToolBox(icon: '📐', label: 'DRAWINGS', onTap: () {}),
                    _buildToolBox(icon: '📝', label: 'SITE LOGS', onTap: () {}),
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
          if (index == 2) {
            context.push('/professional/profile');
          }
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
