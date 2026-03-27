import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
      return;
    }

    final isEmail = identifier.contains('@');
    final isPhone = RegExp(r'^0\d{9}$').hasMatch(identifier);

    if (!isEmail && !isPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email or a 10-digit phone number starting with 0'),
        ),
      );
      return;
    }

    final type = isEmail ? 'email' : 'phone';

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        identifier: identifier,
        password: password,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to dashboard
            context.go('/client/dashboard');
          } else if (state is AuthError) {
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
                          'assets/images/BIMS_logo_white.png',
                          height: 120, // Adjust size as needed
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Client Portal: Permits & More',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 18,
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
                            'Email or Phone Number',
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
                              hintText: 'Enter your email or phone',
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
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
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
                          const SizedBox(height: 24),

                          if (state is AuthLoading)
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
                            onPressed: () {
                              // context.go('/client/dashboard'); // Mock biometric login
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

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push('/client/register');
                                },
                                child: const Text(
                                  'Register New Account',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.bold,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
