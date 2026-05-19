import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/public_repository.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/models/auxiliary/whistle_blower_category.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../../core/models/auxiliary/admin_unit.dart';

class WhistleBlowScreen extends StatefulWidget {
  const WhistleBlowScreen({super.key});

  @override
  State<WhistleBlowScreen> createState() => _WhistleBlowScreenState();
}

class _WhistleBlowScreenState extends State<WhistleBlowScreen> {
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  String? _selectedViolation;
  String? _selectedAdminUnitType;
  String? _selectedAdminUnit;

  final _detailsController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();

  List<WhistleBlowerCategory> _categories = [];
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];

  File? _attachment;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _loadAuxiliaryData();
  }

  void _loadAuxiliaryData() {
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _categories = auxRepo.getWhistleBlowerCategories();
      _adminUnitTypes = auxRepo.getAdminUnitTypes();
    });
  }

  void _onAdminUnitTypeSelected(String? typeIdStr) {
    if (typeIdStr == null) return;

    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _selectedAdminUnitType = typeIdStr;
      _selectedAdminUnit = null;
      _adminUnits = auxRepo.getAdminUnits(int.parse(typeIdStr));
    });
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied.')));
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _attachment = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_selectedViolation == null || _selectedAdminUnitType == null || _selectedAdminUnit == null || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required dropdowns and Address.'), backgroundColor: Colors.red));
      return;
    }

    if (!_isAnonymous && (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Phone are required for non-anonymous reports'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String base64Attachment = '';
      if (_attachment != null) {
        final bytes = await _attachment!.readAsBytes();
        base64Attachment = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final payload = {
        "feedback_type": int.parse(_selectedViolation!),
        "name": _isAnonymous ? "Anonymous" : _nameController.text.trim(),
        "phone": _isAnonymous ? "" : _phoneController.text.trim(),
        "email": _isAnonymous ? "" : _emailController.text.trim(),
        "location": _locationController.text.trim(),
        "administrative_unit_type": int.parse(_selectedAdminUnitType!),
        "administrative_unit_id": int.parse(_selectedAdminUnit!),
        "description": _detailsController.text.trim(),
        "attachment": base64Attachment,
        "latitude": _latitude ?? "",
        "longitude": _longitude ?? "",
      };

      final repo = PublicRepository();
      await repo.submitFeedback(ApiConstants.clientBaseUrl, payload);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Report Submitted'),
            content: Text(
              _isAnonymous
                ? 'Report Submitted Anonymously. Thank you for making the building industry safer.'
                : 'Report Submitted Successfully. Thank you for your feedback.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  context.pop(); // go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Report Construction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Anonymous Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4F4),
                          border: Border.all(color: const Color(0xFFFFDADA)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🛡️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'ANONYMOUS REPORT: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          'Turn off to provide your contact details.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: _isAnonymous,
                      activeColor: AppTheme.danger,
                      onChanged: (val) {
                        setState(() {
                          _isAnonymous = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (!_isAnonymous) ...[
                  _buildLabel('Name'),
                  _buildTextField(_nameController, 'Enter your name'),
                  const SizedBox(height: 15),
                  _buildLabel('Phone Number'),
                  _buildTextField(_phoneController, 'e.g. 2567000000', keyboardType: TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildLabel('Email (Optional)'),
                  _buildTextField(_emailController, 'Enter your email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                ],

                // Nature of Violation
                _buildLabel('Nature of Violation'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFEEF2EF),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text(
                        'Select an issue...',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      value: _selectedViolation,
                      items: _categories.map((WhistleBlowerCategory cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id.toString(),
                          child: Text(
                            cat.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedViolation = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Administrative Units
                _buildLabel('Administrative Unit Type'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEEF2EF), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select unit type', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      value: _selectedAdminUnitType,
                      items: _adminUnitTypes.map((t) {
                        return DropdownMenuItem<String>(
                          value: t.id.toString(),
                          child: Text(t.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: _onAdminUnitTypeSelected,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _buildLabel('Administrative Unit'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFEEF2EF), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Select unit', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      value: _selectedAdminUnit,
                      items: _adminUnits.map((u) {
                        return DropdownMenuItem<String>(
                          value: u.id.toString(),
                          child: Text(u.name, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedAdminUnit = val),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Location / GPS
                _buildLabel('Address / Location Name'),
                _buildTextField(_locationController, 'Plot, Street, or Landmark'),
                const SizedBox(height: 15),

                _buildLabel('Site Coordinates (GPS)'),
                InkWell(
                  onTap: _fetchLocation,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _latitude != null && _longitude != null
                          ? '📍 LAT: $_latitude, LNG: $_longitude'
                          : '📍 TAP TO FETCH SITE COORDINATES',
                        style: TextStyle(
                          color: _latitude != null ? AppTheme.primaryGreen : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Upload Evidence
                _buildLabel('Upload Evidence (Photos)'),
                if (_attachment != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _attachment!.path.split('/').last,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => setState(() => _attachment = null),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: _buildEvidenceBox(
                        icon: '📸',
                        text: 'TAKE PHOTO',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildEvidenceBox(
                        icon: '🖼️',
                        text: 'GALLERY',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Additional Details
                _buildLabel('Additional Details'),
                TextField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the situation here...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SUBMIT REPORT',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
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

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEF2EF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEF2EF), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEvidenceBox({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          border: Border.all(
            color: AppTheme.accentGold,
            width: 2,
          ), // dashed usually requires custom painter, using solid here
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
