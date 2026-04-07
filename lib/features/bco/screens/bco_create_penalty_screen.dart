import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../../core/models/auxiliary/admin_unit.dart';
import '../../../core/models/auxiliary/express_penalty_offence_type.dart';
import '../../../core/models/auxiliary/building_classification.dart';
import '../bloc/create_penalty/bco_create_penalty_bloc.dart';
import '../bloc/create_penalty/bco_create_penalty_event.dart';
import '../bloc/create_penalty/bco_create_penalty_state.dart';
import '../bloc/penalties/bco_penalties_bloc.dart';
import '../bloc/penalties/bco_penalties_event.dart';

class BcoCreatePenaltyScreen extends StatefulWidget {
  const BcoCreatePenaltyScreen({super.key});

  @override
  State<BcoCreatePenaltyScreen> createState() => _BcoCreatePenaltyScreenState();
}

class _BcoCreatePenaltyScreenState extends State<BcoCreatePenaltyScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _sqmController = TextEditingController();
  final TextEditingController _offenderNameController = TextEditingController();
  final TextEditingController _offenderAgeController = TextEditingController();
  final TextEditingController _offenderPhoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _buildingPermitController = TextEditingController();
  final TextEditingController _occupationPermitController = TextEditingController();
  final TextEditingController _postalAddressController = TextEditingController();
  final TextEditingController _dateOfOffenceController = TextEditingController();

  String? _selectedOffenceType;
  String? _selectedBuildingClass;
  String? _selectedAdminUnitType;
  String? _selectedAdminUnit;
  String _offenderSex = 'Male';

  List<ExpressPenaltyOffenceType> _offenceTypes = [];
  List<BuildingClassification> _buildingClasses = [];
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];

  double _tentativeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAuxiliaryData();
    _sqmController.addListener(_calculateAmount);
  }

  void _loadAuxiliaryData() {
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _offenceTypes = auxRepo.getExpressPenaltyOffenceTypes();
      _buildingClasses = auxRepo.getBuildingClassifications();
      _adminUnitTypes = auxRepo.getAdminUnitTypes();
    });
  }

  void _onAdminUnitTypeSelected(String? typeIdStr) {
    if (typeIdStr == null) return;
    
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _selectedAdminUnitType = typeIdStr;
      _selectedAdminUnit = null; // reset child
      _adminUnits = auxRepo.getAdminUnits(int.parse(typeIdStr));
    });
  }

  void _calculateAmount() {
    if (_selectedOffenceType == null) {
      setState(() => _tentativeAmount = 0.0);
      return;
    }

    final offence = _offenceTypes.firstWhere((o) => o.id.toString() == _selectedOffenceType);
    double sqm = double.tryParse(_sqmController.text) ?? 0.0;
    
    // Formula: Amount = (charge_per_sqm ? square_metres : 1) * currency_points * 20000
    double chargeMultiplier = offence.chargePerSqm ? sqm : 1.0;
    double calculated = chargeMultiplier * offence.currencyPoints * 20000.0;

    setState(() {
      _tentativeAmount = calculated;
    });
  }

  @override
  void dispose() {
    _sqmController.dispose();
    _offenderNameController.dispose();
    _offenderAgeController.dispose();
    _offenderPhoneController.dispose();
    _locationController.dispose();
    _buildingPermitController.dispose();
    _occupationPermitController.dispose();
    _postalAddressController.dispose();
    _dateOfOffenceController.dispose();
    super.dispose();
  }

  DateTime? _selectedDateOfOffence;

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfOffence ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryGreen,
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateOfOffence != null
            ? TimeOfDay.fromDateTime(_selectedDateOfOffence!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: AppTheme.primaryGreen,
              colorScheme: const ColorScheme.light(primary: AppTheme.primaryGreen),
              buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateOfOffence = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateOfOffenceController.text = _formatDate(_selectedDateOfOffence!);
        });
      }
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  void _submitPenalty() {
    if (_formKey.currentState!.validate()) {
      if (_selectedOffenceType == null || 
          _selectedBuildingClass == null || 
          _selectedAdminUnitType == null || 
          _selectedAdminUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all required dropdown fields.')),
        );
        return;
      }

      final data = <String, dynamic>{
        "offence_id": int.parse(_selectedOffenceType!),
        "square_metres": double.tryParse(_sqmController.text) ?? 0.0,
        "offender_name": _offenderNameController.text.trim(),
        "offender_age": int.tryParse(_offenderAgeController.text) ?? 0,
        "offender_sex": _offenderSex,
        "offender_phone": _offenderPhoneController.text.trim(),
        "location": _locationController.text.trim(),
        "building_class": int.parse(_selectedBuildingClass!),
        "building_permit_number": _buildingPermitController.text.trim(),
        "occupation_permit_number": _occupationPermitController.text.trim(),
        "administrative_unit_type": int.parse(_selectedAdminUnitType!),
        "administrative_unit_id": int.parse(_selectedAdminUnit!),
        "postal_address": _postalAddressController.text.trim(),
        "date_of_offence": _selectedDateOfOffence != null ? _formatDate(_selectedDateOfOffence!) : _formatDate(DateTime.now()), 
      };

      context.read<BcoCreatePenaltyBloc>().add(SubmitBcoCreatePenalty(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Create Express Penalty', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocConsumer<BcoCreatePenaltyBloc, BcoCreatePenaltyState>(
        listener: (context, state) {
          if (state is BcoCreatePenaltySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Penalty Created Successfully!'), backgroundColor: AppTheme.primaryGreen),
            );
            // Refresh list
            context.read<BcoPenaltiesBloc>().add(const FetchBcoPenalties(status: 'ALL', isRefresh: true));
            context.pop(); // Go back
          } else if (state is BcoCreatePenaltyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: AppTheme.danger),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Offence Info Section
                const _SectionHeader(title: 'OFFENCE DETAILS'),
                
                _buildTextField(
                  controller: _dateOfOffenceController,
                  label: 'Date of Offence',
                  hint: 'Select Date & Time',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () => _selectDateAndTime(context),
                  validator: (val) => val == null || val.isEmpty ? 'Date required' : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedOffenceType,
                  decoration: _inputDecoration(
                    label: 'Offence Type',
                    icon: Icons.gavel,
                  ),
                  items: _offenceTypes.map((o) {
                    return DropdownMenuItem<String>(
                      value: o.id.toString(),
                      child: Text(o.offenceName, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedOffenceType = val);
                    _calculateAmount();
                  },
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _sqmController,
                  label: 'Square Metres',
                  hint: 'e.g. 150.5',
                  icon: Icons.square_foot,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => val == null || val.isEmpty ? 'Square metres required' : null,
                ),
                const SizedBox(height: 15),

                // Amount Display
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tentative Amount:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                      Text(
                        'UGX ${_tentativeAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Offender Details
                const _SectionHeader(title: 'OFFENDER DETAILS'),
                _buildTextField(
                  controller: _offenderNameController,
                  label: 'Offender Name',
                  hint: 'Enter offender name',
                  icon: Icons.person_outline,
                  validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _offenderAgeController,
                        label: 'Age',
                        hint: 'e.g. 33',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _offenderSex,
                        decoration: _inputDecoration(label: 'Sex', icon: Icons.wc),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _offenderSex = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _offenderPhoneController,
                  label: 'Phone Number',
                  hint: 'e.g. 256772...',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty ? 'Phone required' : null,
                ),
                const SizedBox(height: 30),

                // Location Details
                const _SectionHeader(title: 'LOCATION & BUILDING DETAILS'),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Plot, Street...',
                  icon: Icons.location_on_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'Location required' : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedBuildingClass,
                  decoration: _inputDecoration(label: 'Building Classification', icon: Icons.business),
                  items: _buildingClasses.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id.toString(),
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBuildingClass = val),
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _buildingPermitController,
                  label: 'Building Permit Number',
                  hint: '(Optional)',
                  icon: Icons.insert_drive_file_outlined,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _occupationPermitController,
                  label: 'Occupation Permit Number',
                  hint: '(Optional)',
                  icon: Icons.home_work_outlined,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedAdminUnitType,
                  decoration: _inputDecoration(label: 'Administrative Unit Type', icon: Icons.account_balance_outlined),
                  items: _adminUnitTypes.map((t) {
                    return DropdownMenuItem<String>(
                      value: t.id.toString(),
                      child: Text(t.name),
                    );
                  }).toList(),
                  onChanged: _onAdminUnitTypeSelected,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedAdminUnit,
                  decoration: _inputDecoration(label: 'Administrative Unit', icon: Icons.map),
                  items: _adminUnits.map((u) {
                    return DropdownMenuItem<String>(
                      value: u.id.toString(),
                      child: Text(u.name.length > 30 ? '${u.name.substring(0, 30)}...' : u.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAdminUnit = val),
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _postalAddressController,
                  label: 'Postal Address',
                  hint: 'P.O Box...',
                  icon: Icons.local_post_office_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'Address required' : null,
                ),

                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is BcoCreatePenaltyLoading ? null : _submitPenalty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: state is BcoCreatePenaltyLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'CREATE PENALTY',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
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
