import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../bloc/professional_auth_bloc.dart';
import '../bloc/professional_auth_event.dart';
import '../bloc/professional_auth_state.dart';

class ProfessionalLoginScreen extends StatefulWidget {
  const ProfessionalLoginScreen({super.key});

  @override
  State<ProfessionalLoginScreen> createState() =>
      _ProfessionalLoginScreenState();
}

class _ProfessionalLoginScreenState extends State<ProfessionalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // From wireframe background
      body: BlocConsumer<ProfessionalAuthBloc, ProfessionalAuthState>(
        listener: (context, state) {
          if (state is ProfessionalAuthAuthenticated) {
            context.go('/professional/dashboard');
          } else if (state is ProfessionalAuthError) {
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
                        const Text(
                          'NBRB Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Image.asset(
                          'assets/images/BIMS_logo_white.png',
                          height: 120,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.architecture,
                                size: 80,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Professional Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Building Industry Management System',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'For Architects, Engineers & Surveyors',
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

                // Content Area
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
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email/Phone
                            const Text(
                              'Email or Phone Number',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _identifierController,
                              decoration: InputDecoration(
                                hintText: 'Enter your email or phone',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppTheme.accentGold,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Field required'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppTheme.accentGold,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Field required'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state is ProfessionalAuthLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<ProfessionalAuthBloc>()
                                              .add(
                                                ProfessionalAuthLoginRequested(
                                                  _identifierController.text,
                                                  _passwordController.text,
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is ProfessionalAuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Biometric Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Mock Biometric login -> just login
                                  context.read<ProfessionalAuthBloc>().add(
                                    ProfessionalAuthLoginRequested(
                                      'biometric',
                                      'biometric',
                                    ),
                                  );
                                },
                                icon: const Text(
                                  '🔐',
                                  style: TextStyle(fontSize: 16),
                                ),
                                label: const Text(
                                  'Login with Biometrics',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(
                                    color: AppTheme.accentGold,
                                    width: 2,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.push('/professional/register');
                                  },
                                  child: const Text(
                                    'Register New Account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () {
                                context.go('/');
                              },
                              icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
