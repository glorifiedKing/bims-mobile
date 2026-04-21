import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/pro_api_client.dart';
import '../../../core/theme.dart';

class ProfessionalRegistrationScreen extends StatefulWidget {
  const ProfessionalRegistrationScreen({super.key});

  @override
  State<ProfessionalRegistrationScreen> createState() =>
      _ProfessionalRegistrationScreenState();
}

class _ProfessionalRegistrationScreenState
    extends State<ProfessionalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _firmController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isVerified = false;
  bool _isLoading = false;
  bool _isRegistering = false;
  int _selectedProfession = 1;

  Future<void> _validateProfessional() async {
    if (_licenseController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final proApiClient = context.read<ProApiClient>();
      final response = await proApiClient.dio.get(
        '/auxiliary/validate-pro',
        queryParameters: {
          'profession': _selectedProfession,
          'registration_no': _licenseController.text,
        },
      );

      if (response.data['status'] == 'success') {
        setState(() {
          _isVerified = true;
          _firmController.text = response.data['data']['name'] ?? '';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Validation successful'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Validation failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerProfessional() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);
    try {
      final proApiClient = context.read<ProApiClient>();
      final response = await proApiClient.dio.post(
        '/account',
        data: {
          'professional_type': _selectedProfession,
          'name': _firmController.text,
          'email': _emailController.text,
          'registration_no': _licenseController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful. Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _licenseController.dispose();
    _firmController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Professional Registration',
          style: TextStyle(fontSize: 16),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header extension inside body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 15),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryGreen, Color(0xFF00331A)],
              ),
              border: Border(
                bottom: BorderSide(color: AppTheme.accentGold, width: 4),
              ),
            ),
            child: const Column(
              children: [
                Text(
                  'Professional Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Practicing Professional Registration',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),

          // Form Area
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(25),
                children: [
                  const _Label(text: 'Professional Body'),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.accentGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    value: _selectedProfession,
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          'Architects Registration Board (ARB)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          'Engineers Registration Board (ERB)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text(
                          'Surveyors Registration Board (SRB)',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedProfession = val;
                          _isVerified = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  const _Label(text: 'Registration Number'),
                  TextFormField(
                    controller: _licenseController,
                    decoration: InputDecoration(
                      hintText: 'Enter License No.',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.accentGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: _isVerified
                          ? const Padding(
                              padding: EdgeInsets.only(top: 15, right: 12),
                              child: Text(
                                '✓ VERIFIED',
                                style: TextStyle(
                                  color: Color(0xFF28a745),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              child: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : _validateProfessional,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  minimumSize: const Size(60, 30),
                                  backgroundColor: AppTheme.primaryGreen
                                      .withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'VALIDATE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                              ),
                            ),
                    ),
                    onChanged: (val) {
                      if (_isVerified) {
                        setState(() => _isVerified = false);
                      }
                    },
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),

                  const _Label(text: 'Professional Name'),
                  TextFormField(
                    controller: _firmController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'e.g., Skyline Architects Ltd',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.accentGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 28),

                  //const _Label(text: 'Digital Practicing Stamp'),
                  // GestureDetector(
                  //   onTap: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         content: Text(
                  //           'Opening Gallery for Stamp Selection...',
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.all(25),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFFFFFDF5),
                  //       border: Border.all(
                  //         color: AppTheme.accentGold,
                  //         width: 2,
                  //         style: BorderStyle.none,
                  //       ), // dashed emulation normally requires a package, using sold for now
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Column(
                  //       children: const [
                  //         Text('🖋️', style: TextStyle(fontSize: 24)),
                  //         SizedBox(height: 5),
                  //         Text(
                  //           'Upload High-Res Stamp (PNG/JPG)',
                  //           style: TextStyle(
                  //             fontSize: 11,
                  //             fontWeight: FontWeight.w600,
                  //             color: AppTheme.primaryGreen,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // const SizedBox(height: 15),
                  // RichText(
                  //   text: const TextSpan(
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       color: Color(0xFF666666),
                  //       height: 1.4,
                  //     ),
                  //     children: [
                  //       TextSpan(
                  //         text: 'Note: ',
                  //         style: TextStyle(fontWeight: FontWeight.bold),
                  //       ),
                  //       TextSpan(
                  //         text:
                  //             'Your registration details will be validated in real-time with the respective Board. Misrepresentation leads to immediate account suspension.',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 18),

                  const _Label(text: 'Email'),
                  TextFormField(
                    controller: _emailController,
                    enabled: _isVerified,
                    decoration: InputDecoration(
                      hintText: 'info@architects.ug',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.accentGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 18),

                  const _Label(text: 'Password'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: _isVerified,
                    decoration: InputDecoration(
                      hintText: '*****',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFEEF2EF),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.accentGold,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 80), // Padding for fixed footer
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isVerified && !_isRegistering)
                ? _registerProfessional
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isRegistering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'REGISTER',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}
