import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../../core/models/auxiliary/admin_unit.dart';

class BcoStopOrderScreen extends StatefulWidget {
  const BcoStopOrderScreen({super.key});

  @override
  State<BcoStopOrderScreen> createState() => _BcoStopOrderScreenState();
}

class _BcoStopOrderScreenState extends State<BcoStopOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _siteLocationController = TextEditingController();
  final TextEditingController _remedialMeasuresController = TextEditingController();
  final TextEditingController _otherReasonController = TextEditingController();

  String? _selectedAdminUnitType;
  String? _selectedAdminUnit;
  
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];

  final Map<String, bool> _violations = {
    'No Building Permit': false,
    'Deviation from approved plans/conditions': false,
    'Failure to erect signboard, fence, hoarding or barricade': false,
    'Use of prohibited building materials': false,
    'Use of prohibited building methods': false,
    'Failure to engage professionals to supervise': false,
    'Use of unqualified professionals': false,
    'Unstable excavation works': false,
    'Inappropriate scaffolding': false,
    'Failure to construct temporary builder\'s shed': false,
    'Inadequate health and safety measures': false,
    'Failure to provide access for persons with disabilities': false,
    'Failure to invite BCO for inspection': false,
    'Failure to take corrective measures': false,
    'Demolition work without approval': false,
    'Replacement of professionals without notifying': false,
    'Failure to submit quarterly certificates of stability': false,
    'Obstructing an authorised officer': false,
    'Others (Specify)': false,
  };

  @override
  void initState() {
    super.initState();
    _loadAuxiliaryData();
  }

  void _loadAuxiliaryData() {
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _adminUnitTypes = auxRepo.getAdminUnitTypes();
    });
  }

  void _onAdminUnitTypeSelected(String? typeIdStr) {
    if (typeIdStr == null) return;
    
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _selectedAdminUnitType = typeIdStr;
      _selectedAdminUnit = null; // reset child dropdown
      _adminUnits = auxRepo.getAdminUnits(int.parse(typeIdStr));
    });
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _siteLocationController.dispose();
    _remedialMeasuresController.dispose();
    _otherReasonController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      bool hasViolation = _violations.values.any((checked) => checked);
      if (!hasViolation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one violation reason.')),
        );
        return;
      }
      
      if (_violations['Others (Specify)'] == true && _otherReasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please specify the other reason.')),
        );
        return;
      }

      // Successful validation flow
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ORDER ISSUED: Stakeholders notified via SMS & Email. Digital Seal Applied.'),
          backgroundColor: AppTheme.danger,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Stop Work Order', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // General Info Section
            const _SectionHeader(title: 'SITE AND OWNER DETAILS'),
            _buildTextField(
              controller: _ownerNameController,
              label: 'Owner Name',
              hint: 'Enter building owner name',
              icon: Icons.person_outline,
              validator: (val) => val == null || val.isEmpty ? 'Owner name required' : null,
            ),
            const SizedBox(height: 15),
            
            // Administrative Unit Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAdminUnitType,
              decoration: _inputDecoration(
                label: 'Administrative Unit Type',
                icon: Icons.account_balance_outlined,
              ),
              items: _adminUnitTypes.map((t) {
                return DropdownMenuItem<String>(
                  value: t.id.toString(),
                  child: Text(t.name),
                );
              }).toList(),
              onChanged: _onAdminUnitTypeSelected,
            ),
            const SizedBox(height: 15),

            // Administrative Unit Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAdminUnit,
              decoration: _inputDecoration(
                label: 'Administrative Unit',
                icon: Icons.map,
              ),
              items: _adminUnits.map((u) {
                return DropdownMenuItem<String>(
                  value: u.id.toString(),
                  child: Text(u.name.length > 30 ? '${u.name.substring(0, 30)}...' : u.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedAdminUnit = val);
              },
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _ownerAddressController,
              label: 'Owner Contact Address',
              hint: 'P.O Box or Physical Address',
              icon: Icons.local_post_office_outlined,
              validator: (val) => val == null || val.isEmpty ? 'Address required' : null,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _siteLocationController,
              label: 'Site Location',
              hint: 'Plot number, Street, details...',
              icon: Icons.location_on_outlined,
              validator: (val) => val == null || val.isEmpty ? 'Site location required' : null,
            ),
            
            const SizedBox(height: 30),

            // Violations Section
            const _SectionHeader(title: 'VIOLATION REASONS (Tick Applicable)'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: _violations.keys.map((key) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          key,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppTheme.danger,
                        dense: true,
                        value: _violations[key],
                        onChanged: (bool? val) {
                          setState(() {
                            _violations[key] = val ?? false;
                          });
                        },
                      ),
                      if (key == 'Others (Specify)' && _violations[key] == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: _buildTextField(
                            controller: _otherReasonController,
                            label: 'Specify other reasons',
                            hint: 'Enter detailed violations',
                            icon: Icons.edit_note,
                          ),
                        ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Remedial Measures Section
            const _SectionHeader(title: 'REMEDIAL MEASURES REQUIRED'),
            _buildTextField(
              controller: _remedialMeasuresController,
              label: 'Instructions to lift order',
              hint: 'Take the following measures to the satisfaction of the Building Committee...',
              icon: Icons.construction,
              maxLines: 4,
              validator: (val) => val == null || val.isEmpty ? 'Remedial measures required' : null,
            ),

            const SizedBox(height: 30),
            
            // Signature / Confirm
            const _SectionHeader(title: 'BCO AUTHORIZATION'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.fingerprint, size: 40, color: AppTheme.primaryGreen),
                  const SizedBox(height: 10),
                  const Text(
                    'DIGITAL SEAL WILL BE APPLIED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Date Issued: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Issue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'ISSUE OFFICIAL ORDER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryGreen),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(label: label, icon: icon, hint: hint),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black54,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
