import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/models/auxiliary/application_type.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../../core/models/auxiliary/admin_unit.dart';
import '../../../core/models/auxiliary/building_purpose.dart';
import '../../../core/models/auxiliary/building_operation.dart';
import '../../../core/models/auxiliary/land_tenures.dart';
import '../../../core/models/auxiliary/building_classification.dart';
import '../bloc/new_application/client_new_application_bloc.dart';
import '../bloc/new_application/client_new_application_event.dart';
import '../bloc/new_application/client_new_application_state.dart';
import '../repositories/client_repository.dart';

class ClientNewApplicationScreen extends StatefulWidget {
  final String? applicationKey;
  const ClientNewApplicationScreen({super.key, this.applicationKey});

  @override
  State<ClientNewApplicationScreen> createState() =>
      _ClientNewApplicationScreenState();
}

class _ClientNewApplicationScreenState
    extends State<ClientNewApplicationScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();

  // Auxiliary Lists
  List<ApplicationType> _applicationTypes = [];
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];
  List<BuildingPurpose> _buildingPurposes = [];
  List<BuildingOperation> _buildingOperations = [];
  List<LandTenure> _landTenures = [];
  List<BuildingClassification> _buildingClassifications = [];

  // Form State
  String? _applicationTypeId;
  String? _adminUnitTypeId;
  String? _adminUnitId;
  String? _buildingPurposeId;
  String? _buildingOperationId;

  final TextEditingController _contactPersonCtrl = TextEditingController();
  final TextEditingController _contactMobileCtrl = TextEditingController();
  final TextEditingController _contactEmailCtrl = TextEditingController();

  final TextEditingController _locationCtrl =
      TextEditingController(); // Plot number
  final TextEditingController _squareMetresCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _buildingNameCtrl = TextEditingController();
  final TextEditingController _descIntendedUseCtrl = TextEditingController();

  String? _longitude;
  String? _latitude;
  String? _landTenureId;
  String? _buildingClassification;

  bool _isFetchingLocation = false;
  bool _confirmed = false;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadAuxiliaryData();
    if (widget.applicationKey != null) {
      _fetchApplicationDetails();
    }
  }

  Future<void> _fetchApplicationDetails() async {
    setState(() {
      _isLoadingDetails = true;
    });
    try {
      final repo = context.read<ClientRepository>();
      final details = await repo.getApplicationDetails(widget.applicationKey!);

      setState(() {
        // Pre-fill dropdowns by matching strings to Auxiliary Models
        _applicationTypeId = _applicationTypes
            .where((e) => e.name == details.applicationType)
            .firstOrNull
            ?.id
            .toString();

        _adminUnitTypeId = _adminUnitTypes
            .where((e) => e.name == details.administrativeUnitType)
            .firstOrNull
            ?.id
            .toString();

        if (_adminUnitTypeId != null) {
          _adminUnits = context.read<AuxiliaryRepository>().getAdminUnits(
            int.parse(_adminUnitTypeId!),
          );
          _adminUnitId = _adminUnits
              .where((e) => e.name == details.administrativeUnitName)
              .firstOrNull
              ?.id
              .toString();
        }

        _buildingPurposeId = _buildingPurposes
            .where((e) => e.name == details.buildingPurpose)
            .firstOrNull
            ?.id
            .toString();

        _buildingOperationId = _buildingOperations
            .where((e) => e.name == details.buildingOperation)
            .firstOrNull
            ?.id
            .toString();

        _buildingClassification = _buildingClassifications
            .where((e) => e.name == details.buildingClassification)
            .firstOrNull
            ?.name;

        // Text Fields
        _contactPersonCtrl.text = details.applicant.name;
        _contactMobileCtrl.text = details.applicant.phone;
        _contactEmailCtrl.text = details.applicant.email;
        _squareMetresCtrl.text = details.totalSquareMetres.toString();

        if (details.location != null) _locationCtrl.text = details.location!;
        if (details.buildingName != null)
          _buildingNameCtrl.text = details.buildingName!;
        if (details.height != null) _heightCtrl.text = details.height!;
        if (details.descIntendedUse != null)
          _descIntendedUseCtrl.text = details.descIntendedUse!;

        _latitude = details.latitude;
        _longitude = details.longitude;
        _landTenureId = details.landtenure;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load application details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  void _loadAuxiliaryData() {
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _applicationTypes = auxRepo.getApplicationTypes();
      _adminUnitTypes = auxRepo.getAdminUnitTypes();
      _buildingPurposes = auxRepo.getBuildingPurposes();
      _buildingOperations = auxRepo.getBuildingOperations();
      _landTenures = auxRepo.getLandTenures();
      _buildingClassifications = auxRepo.getBuildingClassifications();
    });
  }

  void _onAdminUnitTypeSelected(String? val) {
    setState(() {
      _adminUnitTypeId = val;
      _adminUnitId = null;
      if (val != null) {
        _adminUnits = context.read<AuxiliaryRepository>().getAdminUnits(
          int.parse(val),
        );
      } else {
        _adminUnits = [];
      }
    });
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      // If we added a form key, we could validate per step. For now, we proceed.
      setState(() {
        _currentStep++;
      });
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitApplication() {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the information provided is accurate'),
        ),
      );
      return;
    }

    final payload = {
      "application_type": _applicationTypeId,
      "administrative_unit_type": _adminUnitTypeId,
      "administrative_unit_id": _adminUnitId,
      "contactPerson": _contactPersonCtrl.text.trim(),
      "contactMobilePhone": _contactMobileCtrl.text.trim(),
      "contactEmail": _contactEmailCtrl.text.trim(),
      "landtenure": _landTenureId != null ? int.tryParse(_landTenureId!) : null,
      "buildingPurpose": _buildingPurposeId != null
          ? int.tryParse(_buildingPurposeId!)
          : null,
      "location": _locationCtrl.text.trim(),
      "squareMetres": _squareMetresCtrl.text.trim(),
      "descIntendedUse": _descIntendedUseCtrl.text.trim(),
      "longitude": _longitude ?? '',
      "latitude": _latitude ?? '',
      "buildingClassification": _buildingClassification,
      "buildingOperation": _buildingOperationId != null
          ? int.tryParse(_buildingOperationId!)
          : null,
      "buildingName": _buildingNameCtrl.text.trim(),
      "height": _heightCtrl.text.trim(),
    };

    if (widget.applicationKey != null) {
      context.read<ClientNewApplicationBloc>().add(
        UpdateApplication(widget.applicationKey!, payload),
      );
    } else {
      context.read<ClientNewApplicationBloc>().add(SubmitApplication(payload));
    }
  }

  @override
  void dispose() {
    _contactPersonCtrl.dispose();
    _contactMobileCtrl.dispose();
    _contactEmailCtrl.dispose();
    _locationCtrl.dispose();
    _squareMetresCtrl.dispose();
    _heightCtrl.dispose();
    _buildingNameCtrl.dispose();
    _descIntendedUseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientNewApplicationBloc, ClientNewApplicationState>(
      listener: (context, state) {
        if (state is ClientNewApplicationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.applicationKey != null
                    ? 'Application Updated successfully!'
                    : 'Application Submitted successfully!',
              ),
            ),
          );
          context.go('/client/applications');
        } else if (state is ClientNewApplicationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 10),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryGreen,
          title: Text(
            widget.applicationKey != null
                ? 'EDIT APPLICATION'
                : 'NEW APPLICATION',
            style: const TextStyle(
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
                child: Form(key: _formKey, child: _buildCurrentStep()),
              ),
            ),

            // Next/Back Buttons
            BlocBuilder<ClientNewApplicationBloc, ClientNewApplicationState>(
              builder: (context, state) {
                if (state is ClientNewApplicationLoading || _isLoadingDetails) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return Container(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                          child: Text(
                            _currentStep == 4 ? 'SUBMIT' : 'CONTINUE',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
        return _buildStep4();
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
        _buildStepHeader('STEP 1 OF 4', 'Application & Authority'),
        _buildLabel('APPLICATION TYPE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select application...'),
          value: _applicationTypeId,
          items: _applicationTypes
              .map(
                (a) => DropdownMenuItem(
                  value: a.id.toString(),
                  child: Text(a.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _applicationTypeId = val);
          },
        ),
        _buildLabel('AUTHORITY TYPE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Type'),
          value: _adminUnitTypeId,
          items: _adminUnitTypes
              .map(
                (u) => DropdownMenuItem(
                  value: u.id.toString(),
                  child: Text(u.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: _onAdminUnitTypeSelected,
        ),
        _buildLabel('SELECT AUTHORITY'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select authority...'),
          value: _adminUnitId,
          items: _adminUnits
              .map(
                (a) => DropdownMenuItem(
                  value: a.id.toString(),
                  child: Text(a.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _adminUnitId = val);
          },
        ),
        _buildLabel('BUILDING PURPOSE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select purpose...'),
          value: _buildingPurposeId,
          items: _buildingPurposes
              .map(
                (b) => DropdownMenuItem(
                  value: b.id.toString(),
                  child: Text(b.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _buildingPurposeId = val);
          },
        ),
        _buildLabel('BUILDING OPERATION'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select operation...'),
          value: _buildingOperationId,
          items: _buildingOperations
              .map(
                (o) => DropdownMenuItem(
                  value: o.id.toString(),
                  child: Text(o.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _buildingOperationId = val);
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 2 OF 4', 'Applicant Particulars'),
        _buildLabel('CONTACT PERSON'),
        TextFormField(
          controller: _contactPersonCtrl,
          decoration: _inputDec().copyWith(hintText: 'Enter name'),
        ),
        _buildLabel('CONTACT MOBILE PHONE'),
        TextFormField(
          controller: _contactMobileCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDec().copyWith(hintText: 'e.g. 256789765678'),
        ),
        _buildLabel('CONTACT EMAIL'),
        TextFormField(
          controller: _contactEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDec().copyWith(hintText: 'Enter email address'),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 3 OF 4', 'Site Details'),
        _buildLabel('BUILDING NAME'),
        TextFormField(
          controller: _buildingNameCtrl,
          decoration: _inputDec().copyWith(hintText: 'e.g. Herald Towers'),
        ),
        _buildLabel('LOCATION / PLOT NUMBER'),
        TextFormField(
          controller: _locationCtrl,
          decoration: _inputDec().copyWith(
            hintText: 'e.g. Plot 23 Kampala Road',
          ),
        ),
        _buildLabel('SITE COORDINATES (GPS)'),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: Center(
            child: _isFetchingLocation
                ? const CircularProgressIndicator()
                : Text(
                    _latitude != null && _longitude != null
                        ? 'Lat: $_latitude\nLng: $_longitude'
                        : 'Coordinates not captured',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isFetchingLocation ? null : _fetchLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
            ),
            child: const Text(
              '📍 CAPTURE SITE LOCATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _buildLabel('SITE AREA (SQUARE METRES)'),
        TextFormField(
          controller: _squareMetresCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDec().copyWith(hintText: '0.00'),
        ),
        _buildLabel('BUILDING HEIGHT (METERS)'),
        TextFormField(
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDec().copyWith(hintText: '0.00'),
        ),
        _buildLabel('LAND TENURE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select tenure type'),
          value: _landTenureId,
          items: _landTenures
              .map(
                (l) => DropdownMenuItem(
                  value: l.id.toString(),
                  child: Text(l.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _landTenureId = val);
          },
        ),
        _buildLabel('USE CLASS'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select use class'),
          value: _buildingClassification,
          items: _buildingClassifications
              .map(
                (c) => DropdownMenuItem(
                  value: c.name, // The JSON uses string e.g. "CLASS A"
                  child: Text(c.name, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() => _buildingClassification = val);
          },
        ),
        _buildLabel('DESCRIPTION OF INTENDED USE'),
        TextFormField(
          controller: _descIntendedUseCtrl,
          maxLines: 3,
          decoration: _inputDec().copyWith(hintText: 'e.g. Commercial Offices'),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 4 OF 4', 'Review & Submit'),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            border: Border.all(color: AppTheme.accentGold),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Summary',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Review your details before submitting.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              _buildSummaryRow(
                'Application Type ID',
                _applicationTypeId ?? 'N/A',
              ),
              _buildSummaryRow('Authority ID', _adminUnitId ?? 'N/A'),
              _buildSummaryRow('Contact Person', _contactPersonCtrl.text),
              _buildSummaryRow('Contact Mobile', _contactMobileCtrl.text),
              _buildSummaryRow('Location', _locationCtrl.text),
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
              Checkbox(
                value: _confirmed,
                onChanged: (v) {
                  setState(() => _confirmed = v ?? false);
                },
                activeColor: AppTheme.primaryGreen,
              ),
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
