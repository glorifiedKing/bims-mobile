import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../bloc/bco_auth_bloc.dart';
import '../bloc/bco_auth_event.dart';
import '../bloc/bco_auth_state.dart';
import '../../bco/bloc/profile/bco_profile_bloc.dart';
import '../../bco/bloc/profile/bco_profile_event.dart';
import '../../bco/bloc/counters/bco_counters_bloc.dart';
import '../../bco/bloc/counters/bco_counters_event.dart';
import '../../bco/bloc/invoices/bco_invoices_bloc.dart';
import '../../bco/bloc/invoices/bco_invoices_event.dart';
import '../../../core/services/biometric_service.dart';

class BcoLoginScreen extends StatefulWidget {
  const BcoLoginScreen({super.key});

  @override
  State<BcoLoginScreen> createState() => _BcoLoginScreenState();
}

class _BcoLoginScreenState extends State<BcoLoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
      return;
    }

    context.read<BcoAuthBloc>().add(
      BcoAuthLoginRequested(email: identifier, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: BlocConsumer<BcoAuthBloc, BcoAuthState>(
        listener: (context, state) {
          if (state is BcoAuthAuthenticated) {
            context.read<BcoProfileBloc>().add(FetchBcoProfile());
            context.read<BcoCountersBloc>().add(FetchBcoCounters());
            context.read<BcoInvoicesBloc>().add(FetchBcoInvoicesTotal());
            context.go('/bco/dashboard');
          } else if (state is BcoAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.primaryGreen, Color(0xFF00331A)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/BIMS_logo_white_m.png',
                          height: 120,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'For BCOs, Accounting Officers, Local Authorities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Form Area
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _identifierController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Password',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push('/bco/forgot-password');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (state is BcoAuthLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final biometricService = BiometricService();
                              final isEnabled = await biometricService.isBcoBiometricEnabled();
                              
                              if (!isEnabled) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please log in first and enable biometric login in your profile.'),
                                    ),
                                  );
                                }
                                return;
                              }

                              final authSuccess = await biometricService.authenticate();
                              if (authSuccess) {
                                final oldToken = await biometricService.getBcoSecureToken();
                                if (oldToken != null && context.mounted) {
                                  context.read<BcoAuthBloc>().add(BcoAuthBiometricLoginRequested(oldToken));
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved session invalid. Please log in manually.')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.fingerprint,
                              color: AppTheme.primaryGreen,
                            ),
                            label: const Text(
                              'Login with Biometrics',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: AppTheme.accentGold,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              context.go('/');
                            },
                            icon: const Icon(
                              Icons.swap_horiz,
                              color: AppTheme.primaryGreen,
                            ),
                            label: const Text(
                              'Switch Login Portal',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
