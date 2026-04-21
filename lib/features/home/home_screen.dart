import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../auth/bloc/bco_auth_bloc.dart';
import '../auth/bloc/bco_auth_state.dart';
import '../auth/bloc/professional_auth_bloc.dart';
import '../auth/bloc/professional_auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingAuth(context);
    });
  }

  void _checkExistingAuth(BuildContext context) {
    if (!mounted) return;

    final clientState = context.read<AuthBloc>().state;
    if (clientState is AuthAuthenticated) {
      context.go('/client/dashboard');
      return;
    }

    final bcoState = context.read<BcoAuthBloc>().state;
    if (bcoState is BcoAuthAuthenticated) {
      context.go('/bco/dashboard');
      return;
    }

    final profState = context.read<ProfessionalAuthBloc>().state;
    if (profState is ProfessionalAuthAuthenticated) {
      context.go('/professional/dashboard');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/client/dashboard');
            }
          },
        ),
        BlocListener<BcoAuthBloc, BcoAuthState>(
          listener: (context, state) {
            if (state is BcoAuthAuthenticated) {
              context.go('/bco/dashboard');
            }
          },
        ),
        BlocListener<ProfessionalAuthBloc, ProfessionalAuthState>(
          listener: (context, state) {
            if (state is ProfessionalAuthAuthenticated) {
              context.go('/professional/dashboard');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryGreen, Color(0xFF00331A)],
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/BIMS_logo_white_m.png',
                      height: 120, // Adjust size as needed
                    ),
                    const SizedBox(height: 8),
                    // const Text(
                    //   'NBRB Portal',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    const Text(
                      'Building Industry Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    children: [
                      _buildPortalCard(
                        context: context,
                        title: 'CLIENT PORTAL',
                        subtitle: 'For Citizens and Property Developers',
                        icon: Icons.home,
                        onTap: () {
                          context.push('/client/login');
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildPortalCard(
                        context: context,
                        title: 'BCO PORTAL',
                        subtitle:
                            'For Building Control Officers & Local Authorities',
                        icon: Icons.security,
                        onTap: () {
                          context.push('/bco/login');
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildPortalCard(
                        context: context,
                        title: 'PROFESSIONALS PORTAL',
                        subtitle: 'For Architects, Engineers & Surveyors',
                        icon: Icons.architecture,
                        onTap: () {
                          context.push('/professional/login');
                        },
                      ),
                      const SizedBox(height: 30),
                      // add horizonal line here
                      const Divider(color: AppTheme.primaryGreen, thickness: 1),
                      const SizedBox(height: 30),
                      _buildPortalCard(
                        context: context,
                        title: 'VERIFY PERMIT',
                        subtitle: 'Verify Building Permit',
                        icon: Icons.qr_code_scanner,
                        onTap: () {
                          context.push('/verify-permit');
                        },
                      ),

                      const SizedBox(height: 15),
                      _buildPortalCard(
                        context: context,
                        title: 'WHISTLE BLOW',
                        subtitle: 'Report Illegal Construction (Anonymous)',
                        icon: Icons.report,
                        onTap: () {
                          context.push('/whistle-blow');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppTheme.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.accentGold),
          ],
        ),
      ),
    );
  }
}
