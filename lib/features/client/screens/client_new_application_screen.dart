import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class ClientNewApplicationScreen extends StatefulWidget {
  const ClientNewApplicationScreen({super.key});

  @override
  State<ClientNewApplicationScreen> createState() =>
      _ClientNewApplicationScreenState();
}

class _ClientNewApplicationScreenState
    extends State<ClientNewApplicationScreen> {
  int _currentStep = 1;

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Submitted successfully!')),
      );
      context.go('/client/applications');
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          'NEW APPLICATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: AppTheme.accentGold, height: 4),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStep(),
            ),
          ),

          // Next/Back Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                if (_currentStep > 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E6E0),
                          foregroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('BACK'),
                      ),
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(_currentStep == 5 ? 'SUBMIT' : 'CONTINUE'),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Nav
          BottomNavigationBar(
            currentIndex: 1, // Focus Applications conceptually
            onTap: (index) {
              if (index == 0) context.go('/client/dashboard');
              if (index == 1) context.go('/client/applications');
              if (index == 2) context.go('/client/invoices');
              if (index == 3) context.go('/client/profile');
            },
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.description),
                label: 'Applications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment),
                label: 'Invoices',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
      case 5:
        return _buildStep4(); // Just mocking steps based on wireframe logic (wireframe showed step "5 of 5" under div id="step4")
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepHeader(String stepText, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stepText,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppTheme.accentGold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  InputDecoration _inputDec() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.accentGold),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 1 OF 5', 'Select Application Type'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select application...'),
          items: const [
            DropdownMenuItem(
              value: '1',
              child: Text('Building Permit Application'),
            ),
            DropdownMenuItem(value: '2', child: Text('Notice of Commencement')),
            DropdownMenuItem(
              value: '3',
              child: Text('Request Routine Inspection'),
            ),
          ],
          onChanged: (val) {},
        ),
        const Divider(height: 40, color: Color(0xFFDDDDDD)),
        _buildStepHeader('STEP 2 OF 5', 'Development Location'),
        _buildLabel('AUTHORITY TYPE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Type'),
          items: const [
            DropdownMenuItem(value: 'city', child: Text('City')),
            DropdownMenuItem(value: 'district', child: Text('District')),
          ],
          onChanged: (val) {},
        ),
        _buildLabel('SELECT AUTHORITY'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select location...'),
          items: const [
            DropdownMenuItem(
              value: '1',
              child: Text('Kampala Capital City Authority'),
            ),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 3 OF 5', 'Applicant Particulars'),
        _buildLabel('LEGAL STATUS OF APPLICANT *'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          value: 'individual',
          items: const [
            DropdownMenuItem(value: 'individual', child: Text('Individual')),
          ],
          onChanged: (val) {},
        ),
        _buildLabel('NATIONAL ID (NIN) *'),
        TextFormField(
          initialValue: 'CM8702710F1WGE',
          decoration: _inputDec().copyWith(
            fillColor: const Color(0xFFFDFAF0),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.accentGold),
            ),
          ),
        ),
        _buildLabel('NAME *'),
        TextFormField(
          initialValue: 'Byaruhanga Raymond',
          decoration: _inputDec(),
        ),
        _buildLabel('MOBILE PHONE *'),
        TextFormField(initialValue: '256704555432', decoration: _inputDec()),
        _buildLabel('PHYSICAL ADDRESS *'),
        TextFormField(maxLines: 3, decoration: _inputDec()),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 4 OF 5', 'Site Details'),
        _buildLabel('SITE AREA (SQM) *'),
        TextFormField(decoration: _inputDec().copyWith(hintText: '0.00')),
        _buildLabel('PLOT NUMBER *'),
        TextFormField(
          decoration: _inputDec().copyWith(hintText: 'Enter plot number'),
        ),
        _buildLabel('SITE COORDINATES (GPS)'),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '[ Google Map Placeholder ]',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
            ),
            child: const Text(
              '📍 CAPTURE SITE LOCATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildLabel('LAND TENURE *'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select tenure type'),
          items: const [DropdownMenuItem(value: '1', child: Text('Freehold'))],
          onChanged: (val) {},
        ),
        _buildLabel('USE CLASS *'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select use class'),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Residential')),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 5 OF 5', 'Review & Submit'),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            border: Border.all(color: AppTheme.accentGold),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Application Summary',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Review your details before submitting.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Checkbox(value: false, onChanged: (v) {}),
              const Expanded(
                child: Text(
                  'I confirm that the information provided is accurate',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
