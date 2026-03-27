import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() =>
      _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  int _currentStep = 1;
  String _legalStatus = '1'; // 1: Individual, 2: Company, 3: Government

  // Individual fields
  final _surnameController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  String _citizenship = '1'; // 1: Ugandan, 2: Non-Ugandan
  String _sex = 'Male';
  final _nationalIdController = TextEditingController();

  // Company / Govt fields
  final _brnController = TextEditingController();
  final _tinController = TextEditingController();
  final _departmentController =
      TextEditingController(); // Maps to company_name or dept

  // Shared fields
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  void _nextStep() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 2;
      });
    } else {
      _submitForm();
    }
  }

  void _submitForm() {
    // Shared validation
    if (_emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      _showError('Please fill in all shared fields (Email, Phone, Passwords).');
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      _showError('Passwords do not match.');
      return;
    }

    final payload = <String, dynamic>{
      'legal_status': int.tryParse(_legalStatus) ?? 1,
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _passwordConfirmController.text,
    };

    if (_legalStatus == '1') {
      if (_surnameController.text.trim().isEmpty ||
          _givenNameController.text.trim().isEmpty ||
          _nationalIdController.text.trim().isEmpty) {
        _showError(
          'Please fill in required fields (Surname, Given Name, NIN).',
        );
        return;
      }
      payload['surname'] = _surnameController.text.trim();
      payload['given_name'] = _givenNameController.text.trim();
      payload['Other_names'] = _otherNamesController.text.trim();
      payload['citizenship'] = int.tryParse(_citizenship) ?? 1;
      payload['sex'] = _sex;
      payload['national_id'] = _nationalIdController.text.trim();
    } else if (_legalStatus == '2') {
      if (_brnController.text.trim().isEmpty ||
          _tinController.text.trim().isEmpty) {
        _showError('Please fill in the BRN and TIN numbers.');
        return;
      }
      payload['brn'] = _brnController.text.trim();
      payload['tin'] = _tinController.text.trim();
    } else if (_legalStatus == '3') {
      if (_tinController.text.trim().isEmpty) {
        _showError('Please fill in the TIN number.');
        return;
      }
      payload['tin'] = _tinController.text.trim();
    }

    context.read<AuthBloc>().add(AuthRegisterRequested(payload));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _previousStep() {
    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _givenNameController.dispose();
    _otherNamesController.dispose();
    _nationalIdController.dispose();
    _brnController.dispose();
    _tinController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
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
              child: Column(
                children: const [
                  Text(
                    'CLIENT PORTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Register in the Building Industry Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Stepper Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepDot(active: true),
                  Container(
                    width: 40,
                    height: 2,
                    color: _currentStep > 1
                        ? AppTheme.accentGold
                        : Colors.grey.shade300,
                  ),
                  _buildStepDot(active: _currentStep > 1),
                  Container(width: 40, height: 2, color: Colors.grey.shade300),
                  _buildStepDot(active: false),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _currentStep == 1
                        ? _buildStepOne()
                        : _buildStepTwo(),
                  ),
                ),
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Column(
                children: [
                  if (_currentStep == 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E6E0),
                          foregroundColor: AppTheme.primaryGreen,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('BACK'),
                      ),
                    ),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthUnauthenticated && _currentStep == 2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account created! Please login.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.pop();
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(_currentStep == 1 ? 'CONTINUE' : 'SUBMIT'),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot({required bool active}) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.accentGold : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: active
            ? [const BoxShadow(color: Color(0x80D4AF37), blurRadius: 10)]
            : null,
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Legal Status'),
        DropdownButtonFormField<String>(
          initialValue: _legalStatus,
          decoration: _inputDecoration(),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Individual')),
            DropdownMenuItem(value: '2', child: Text('Company / Business')),
            DropdownMenuItem(value: '3', child: Text('Government Entity')),
          ],
          onChanged: (val) {
            setState(() {
              _legalStatus = val!;
            });
          },
        ),
        const SizedBox(height: 20),
        if (_legalStatus == '1') ...[
          _buildTextField('Surname', 'Enter your surname', _surnameController),
          const SizedBox(height: 20),
          _buildTextField(
            'Given Names',
            'Enter given names',
            _givenNameController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Other Names',
            'Enter other names',
            _otherNamesController,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Citizenship'),
                    DropdownButtonFormField<String>(
                      value: _citizenship,
                      decoration: _inputDecoration(),
                      items: const [
                        DropdownMenuItem(
                          value: '1',
                          child: Text(
                            'Ugandan',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: '2',
                          child: Text(
                            'Non-Ugandan',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _citizenship = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Sex'),
                    DropdownButtonFormField<String>(
                      value: _sex,
                      decoration: _inputDecoration(),
                      items: const [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Text('Male', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _sex = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'National ID (NIN)',
            'CM000000000000',
            _nationalIdController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Real-time NIN verification will be conducted with NIRA.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ] else if (_legalStatus == '2') ...[
          _buildTextField(
            'BRN (Business Reg No.)',
            '800200...',
            _brnController,
          ),
          const SizedBox(height: 20),
          _buildTextField('TIN Number', '1003456...', _tinController),
          const SizedBox(height: 20),
          _buildTextField(
            'Company Name',
            'Cresent Holdings',
            _departmentController,
          ),
        ] else if (_legalStatus == '3') ...[
          _buildTextField('TIN Number', '1003456...', _tinController),
          const SizedBox(height: 20),
          _buildTextField(
            'Name of Department',
            'Ministry of Works...',
            _departmentController,
          ),
        ],
        const SizedBox(height: 20),
        _buildTextField('Phone Number', '+256 700 000000', _phoneController),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField('Email', 'johndoe@example.com', _emailController),
        const SizedBox(height: 20),
        _buildTextField(
          'Password',
          '*******',
          _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Retype Password',
          '*******',
          _passwordConfirmController,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: _inputDecoration().copyWith(hintText: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E6E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E6E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentGold),
      ),
    );
  }
}
