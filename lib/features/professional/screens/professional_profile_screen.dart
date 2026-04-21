import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../auth/bloc/professional_auth_bloc.dart';
import '../../auth/bloc/professional_auth_event.dart';
import '../bloc/profile/professional_profile_bloc.dart';
import '../bloc/profile/professional_profile_state.dart';
import '../bloc/documents/professional_documents_bloc.dart';
import '../bloc/documents/professional_documents_state.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<ProfessionalProfileBloc, ProfessionalProfileState>(
        builder: (context, state) {
          if (state is ProfessionalProfileLoading || state is ProfessionalProfileInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          if (state is ProfessionalProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          
          if (state is ProfessionalProfileLoaded) {
            final profile = state.profile;
            final initials = profile.name.trim().isNotEmpty 
              ? profile.name.trim().split(RegExp(r'\s+')).map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : '??';

            return Column(
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
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  profile.name,
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
                  child: Text(
                    '${profile.profession.toUpperCase()} PORTAL',
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
                  label: 'Registration Details',
                  children: [
                    Text(
                      'Reg. No: ${profile.registrationNo}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const Divider(color: Color(0xFFF0F0F0), height: 16),
                    Text(
                      'Discipline: ${profile.discipline}',
                      style: const TextStyle(
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
                    Text(
                      profile.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const Divider(color: Color(0xFFF0F0F0), height: 16),
                    Text(
                      profile.email,
                      style: const TextStyle(
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
                    Text(
                      'License No: ${profile.registrationNo}',
                      style: const TextStyle(
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
                _buildInfoCard(
                  label: 'Professional Documents',
                  children: [
                    BlocBuilder<ProfessionalDocumentsBloc, ProfessionalDocumentsState>(
                      builder: (context, docState) {
                        if (docState is ProfessionalDocumentsLoading || docState is ProfessionalDocumentsInitial) {
                           return const Padding(
                             padding: EdgeInsets.all(20.0),
                             child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                           );
                        }
                        if (docState is ProfessionalDocumentsError) {
                           return Text('Error loading documents: ${docState.message}', style: const TextStyle(color: AppTheme.danger));
                        }
                        if (docState is ProfessionalDocumentsLoaded) {
                           final docs = docState.documents.documents;
                           if (docs.isEmpty) {
                              return const Text('No documents found.', style: TextStyle(color: Colors.grey));
                           }
                           return Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: docs.entries.map((entry) {
                               final keyName = entry.key.replaceAll('_', ' ').toUpperCase();
                               final url = entry.value;
                               final isImage = url.toLowerCase().endsWith('.png') || 
                                               url.toLowerCase().endsWith('.jpg') || 
                                               url.toLowerCase().endsWith('.jpeg');
                               
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 15),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       keyName,
                                       style: const TextStyle(
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                         color: AppTheme.primaryGreen,
                                       ),
                                     ),
                                     const SizedBox(height: 8),
                                     if (isImage)
                                       Container(
                                         width: double.infinity,
                                         padding: const EdgeInsets.all(8),
                                         decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFEEEEEE)),
                                            borderRadius: BorderRadius.circular(8),
                                         ),
                                         child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              url,
                                              height: 120,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            ),
                                         ),
                                       )
                                     else
                                       Container(
                                         padding: const EdgeInsets.all(12),
                                         decoration: BoxDecoration(
                                           color: const Color(0xFFF9F9F9),
                                           borderRadius: BorderRadius.circular(8),
                                           border: Border.all(color: const Color(0xFFEEEEEE)),
                                         ),
                                         child: Row(
                                           children: [
                                              const Icon(Icons.description, color: AppTheme.accentGold),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  url.split('/').last,
                                                  style: const TextStyle(
                                                    color: AppTheme.primaryGreen,
                                                    fontSize: 12,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                           ],
                                         ),
                                       ),
                                   ],
                                 ),
                               );
                             }).toList(),
                           );
                        }
                        return const SizedBox.shrink();
                      }
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
      );
    }
    return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/professional/dashboard');
          if (index == 1) context.push('/professional/applications');
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
