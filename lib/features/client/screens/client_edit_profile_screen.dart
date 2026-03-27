import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../bloc/profile/client_profile_bloc.dart';
import '../bloc/profile/client_profile_event.dart';
import '../bloc/profile/client_profile_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ClientEditProfileScreen extends StatefulWidget {
  final String currentEmail;
  final String currentPhone;

  const ClientEditProfileScreen({
    super.key,
    required this.currentEmail,
    required this.currentPhone,
  });

  @override
  State<ClientEditProfileScreen> createState() =>
      _ClientEditProfileScreenState();
}

class _ClientEditProfileScreenState extends State<ClientEditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _submitProfileUpdate() {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;

    if (email.isEmpty || phone.isEmpty) {
      _showError('Email and Phone cannot be left blank.');
      return;
    }

    if (password.isNotEmpty && password != passwordConfirm) {
      _showError('Passwords do not match.');
      return;
    }

    final payload = <String, dynamic>{'email': email, 'phone': phone};

    bool requiresLogout = email != widget.currentEmail;

    if (password.isNotEmpty) {
      payload['password'] = password;
      payload['password_confirmation'] = passwordConfirm;
      requiresLogout = true;
    }

    context.read<ClientProfileBloc>().add(
      UpdateClientProfile(payload, requiresLogout: requiresLogout),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ClientProfileBloc, ClientProfileState>(
        listener: (context, state) {
          if (state is ClientProfileUpdateSuccess) {
            if (state.requiresLogout) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated! Please log in again.'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/client/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<ClientProfileBloc>().add(FetchClientProfile());
              context.pop();
            }
          } else if (state is ClientProfileUpdateFailure) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ClientProfileUpdateLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField('Email', 'Update email', _emailController),
                const SizedBox(height: 20),
                _buildTextField(
                  'Phone Number',
                  'Update phone',
                  _phoneController,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Change Password (Optional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  'New Password',
                  '*******',
                  _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Confirm Password',
                  '*******',
                  _passwordConfirmController,
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitProfileUpdate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('SAVE CHANGES'),
                  ),
              ],
            ),
          );
        },
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
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
            hintText: hint,
          ),
        ),
      ],
    );
  }
}
