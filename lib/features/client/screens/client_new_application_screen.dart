import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/network/public_repository.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auxiliary/application_type.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../../core/models/auxiliary/admin_unit.dart';
import '../../../core/models/auxiliary/building_purpose.dart';
import '../../../core/models/auxiliary/building_operation.dart';
import '../../../core/models/auxiliary/land_tenures.dart';
import '../../../core/models/auxiliary/building_classification.dart';
import '../../../core/models/auxiliary/form_type.dart';
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
  List<FormType> _formTypes = [];
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];
  List<BuildingPurpose> _buildingPurposes = [];
  List<BuildingOperation> _buildingOperations = [];
  List<LandTenure> _landTenures = [];
  List<BuildingClassification> _buildingClassifications = [];

  List<Map<String, dynamic>> _subcounties = [];
  List<Map<String, dynamic>> _parishes = [];
  List<Map<String, dynamic>> _villages = [];
  List<Map<String, dynamic>> _roads = [];

  // Form State
  String? _applicationTypeId;
  String? _formTypeId;
  String? _adminUnitTypeId;
  String? _adminUnitId;
  String? _buildingPurposeId;
  String? _buildingOperationId;

  String? _subcountyId;
  String? _parishId;
  String? _villageId;
  String? _roadId;

  final TextEditingController _contactPersonCtrl = TextEditingController();
  final TextEditingController _contactMobileCtrl = TextEditingController();
  final TextEditingController _contactEmailCtrl = TextEditingController();

  final TextEditingController _locationCtrl =
      TextEditingController(); // Plot number
  final TextEditingController _squareMetresCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _buildingNameCtrl = TextEditingController();
  final TextEditingController _descIntendedUseCtrl = TextEditingController();

  // Dynamic Form Variables
  String? _legalStatus;
  final TextEditingController _ninCtrl = TextEditingController();
  final TextEditingController _applicantNameCtrl = TextEditingController();
  final TextEditingController _applicantAddressCtrl = TextEditingController();
  final TextEditingController _physicalAddressCtrl = TextEditingController();
  final TextEditingController _postalAddressCtrl = TextEditingController();
  final TextEditingController _phoneFixedLineCtrl = TextEditingController();
  final TextEditingController _phoneMobileCtrl = TextEditingController();
  final TextEditingController _faxNumberCtrl = TextEditingController();
  final TextEditingController _contractorCtrl = TextEditingController();
  final TextEditingController _developmentPermitCtrl = TextEditingController();

  final TextEditingController _ppcMinuteNumberCtrl = TextEditingController();
  final TextEditingController _ppcDateCtrl = TextEditingController();
  final TextEditingController _ppcApplicantNameCtrl = TextEditingController();
  final TextEditingController _ppcNumLevelsCtrl = TextEditingController();
  final TextEditingController _ppcNumBlocksCtrl = TextEditingController();
  final TextEditingController _ppcPhysicalPlannerCtrl = TextEditingController();
  String? _ppcApprovedLandUse;
  String? _surveyorId;

  // Land Tenure Conditional Fields
  final TextEditingController _folioCtrl = TextEditingController();
  final TextEditingController _volumeCtrl = TextEditingController();
  final TextEditingController _countyCtrl = TextEditingController();
  final TextEditingController _plotNumberCtrl = TextEditingController();
  final TextEditingController _blockNumberCtrl = TextEditingController();

  // Built-up Area Computation
  List<Map<String, dynamic>> _buildingsArea = [];
  final TextEditingController _builtupAreaCtrl = TextEditingController();

  // Supply Connections
  String? _waterSupply;
  String? _sewerConnection;
  String? _electricitySupply;
  String? _internetSupply;

  // File Upload Paths
  String? _certificateOfTitlePath;
  String? _powerOfAttorneyPath;
  String? _salesAgreementPath;
  String? _letterOfAdministrationPath;
  String? _boundaryOpeningReportPath;
  String? _lcLetterPath;
  String? _sketchPlanPath;
  String? _certificateNemaPath;
  String? _trafficImpactAssessmentPath;
  String? _geoTechReportPath;
  String? _oldPermitPath;

  // Pro Link Code Controllers
  final TextEditingController _boundaryOpeningReportCodeCtrl =
      TextEditingController();
  final TextEditingController _architecturalDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _servicesDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _mechanicalDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _electricalDrawingsCodeCtrl =
      TextEditingController();

  final TextEditingController _asBuiltDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _certificateOfPracticalCompletionCodeCtrl =
      TextEditingController();
  final TextEditingController _certificateOfApprovalForFireDetectionCodeCtrl =
      TextEditingController();
  final TextEditingController _asBuiltStructuralDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _asBuiltElectricalDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController _asBuiltMechanicalDrawingsCodeCtrl =
      TextEditingController();
  final TextEditingController
  _certificateOfFitnessOfTheMechanicalInstallationCodeCtrl =
      TextEditingController();

  // Verification states for Pro Link Codes (true if verified)
  final Map<String, bool> _verifiedProCodes = {};

  // Occupation Permit Flow State
  bool? _hasApprovedPermit;
  final TextEditingController _permitSerialCtrl = TextEditingController();
  bool _isFetchingPermit = false;
  bool _isPermitVerified = false;

  // Development Permit Verification
  bool _isDevelopmentPermitVerified = false;
  bool _isVerifyingDevelopmentPermit = false;

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

  Future<void> _pickFile(Function(String) onFilePicked) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        onFilePicked(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }

  Future<void> _fetchSubcounties(String districtId) async {
    final results = await context.read<ClientRepository>().getSubcounties(
      districtId,
    );
    setState(() {
      _subcounties = results;
    });
  }

  Future<void> _fetchParishes(String subcountyId) async {
    final results = await context.read<ClientRepository>().getParishes(
      subcountyId,
    );
    setState(() {
      _parishes = results;
    });
  }

  Future<void> _fetchVillages(String parishId) async {
    final results = await context.read<ClientRepository>().getVillages(
      parishId,
    );
    setState(() {
      _villages = results;
    });
  }

  Future<void> _fetchRoads(String villageId) async {
    final results = await context.read<ClientRepository>().getRoads(villageId);
    setState(() {
      _roads = results;
    });
  }

  void _nextStep() {
    if (_currentStep < 6) {
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
      "subcountyId": _subcountyId != null ? int.tryParse(_subcountyId!) : null,
      "parishId": _parishId != null ? int.tryParse(_parishId!) : null,
      "villageId": _villageId != null ? int.tryParse(_villageId!) : null,
      "roadId": _roadId != null ? int.tryParse(_roadId!) : null,
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

      // Dynamic fields
      "form_type": _formTypeId,
      "legalStatus": _legalStatus,
      "identificationNumber": _ninCtrl.text.trim(),
      "applicantName": _applicantNameCtrl.text.trim(),
      "applicantAddress": _applicantAddressCtrl.text.trim(),
      "physicalAddress": _physicalAddressCtrl.text.trim(),
      "postalAddress": _postalAddressCtrl.text.trim(),
      "phoneFixedLine": _phoneFixedLineCtrl.text.trim(),
      "phoneMobile": _phoneMobileCtrl.text.trim(),
      "faxNumber": _faxNumberCtrl.text.trim(),
      "contractor": _contractorCtrl.text.trim(),
      "development_permit": _developmentPermitCtrl.text.trim(),
      "ppcMinuteNumber": _ppcMinuteNumberCtrl.text.trim(),
      "ppcDate": _ppcDateCtrl.text.trim(),
      "ppcApplicantName": _ppcApplicantNameCtrl.text.trim(),
      "ppcApprovedLandUse": _ppcApprovedLandUse,
      "ppcNumLevels": _ppcNumLevelsCtrl.text.trim(),
      "ppcNumBlocks": _ppcNumBlocksCtrl.text.trim(),
      "ppcPhysicalPlanner": _ppcPhysicalPlannerCtrl.text.trim(),
      "folio": _folioCtrl.text.trim(),
      "volume": _volumeCtrl.text.trim(),
      "county": _countyCtrl.text.trim(),
      "plotNumber": _plotNumberCtrl.text.trim(),
      "blockNumber": _blockNumberCtrl.text.trim(),
      "builtupArea": _builtupAreaCtrl.text.trim(),
      "buildingsArea": _buildingsArea.isNotEmpty ? _buildingsArea : null,
      "waterSupply": _waterSupply,
      "sewerConnection": _sewerConnection,
      "electricitySupply": _electricitySupply,
      "internetSupply": _internetSupply,
      "nameOfLandSurveyor": _surveyorId,
      // File paths (will require multi-part form update in backend/bloc later if actual files are expected)
      "certificateTitleFile": _certificateOfTitlePath,
      "powerAttorneyFile": _powerOfAttorneyPath,
      "salesAgreementFile": _salesAgreementPath,
      "letterAdministrationFile": _letterOfAdministrationPath,
      "lcLetter": _lcLetterPath,
      "sketchPlan": _sketchPlanPath,
      "certificateNema": _certificateNemaPath,
      "trafficImpactAssessment": _trafficImpactAssessmentPath,
      "geoTechReport": _geoTechReportPath,
      "oldPermit": _oldPermitPath,
      "boundaryOpeningReport":
          _verifiedProCodes['boundaryOpeningReport'] == true
          ? _boundaryOpeningReportCodeCtrl.text.trim()
          : null,
      "architecturalDrawings":
          _verifiedProCodes['architecturalDrawings'] == true
          ? _architecturalDrawingsCodeCtrl.text.trim()
          : null,
      "servicesDrawings": _verifiedProCodes['servicesDrawings'] == true
          ? _servicesDrawingsCodeCtrl.text.trim()
          : null,
      "mechanicalDrawings": _verifiedProCodes['mechanicalDrawings'] == true
          ? _mechanicalDrawingsCodeCtrl.text.trim()
          : null,
      "electricalDrawings": _verifiedProCodes['electricalDrawings'] == true
          ? _electricalDrawingsCodeCtrl.text.trim()
          : null,
      "asBuiltDrawings": _verifiedProCodes['asBuiltDrawings'] == true
          ? _asBuiltDrawingsCodeCtrl.text.trim()
          : null,
      "certificateOfPracticalCompletion":
          _verifiedProCodes['certificateOfPracticalCompletion'] == true
          ? _certificateOfPracticalCompletionCodeCtrl.text.trim()
          : null,
      "certificateOfApprovalForFireDetection":
          _verifiedProCodes['certificateOfApprovalForFireDetection'] == true
          ? _certificateOfApprovalForFireDetectionCodeCtrl.text.trim()
          : null,
      "asBuiltStructuralDrawings":
          _verifiedProCodes['asBuiltStructuralDrawings'] == true
          ? _asBuiltStructuralDrawingsCodeCtrl.text.trim()
          : null,
      "asBuiltElectricalDrawings":
          _verifiedProCodes['asBuiltElectricalDrawings'] == true
          ? _asBuiltElectricalDrawingsCodeCtrl.text.trim()
          : null,
      "asBuiltMechanicalDrawings":
          _verifiedProCodes['asBuiltMechanicalDrawings'] == true
          ? _asBuiltMechanicalDrawingsCodeCtrl.text.trim()
          : null,
      "certificateOfFitnessOfTheMechanicalInstallation":
          _verifiedProCodes['certificateOfFitnessOfTheMechanicalInstallation'] ==
              true
          ? _certificateOfFitnessOfTheMechanicalInstallationCodeCtrl.text.trim()
          : null,
      "permitSerial": _permitSerialCtrl.text.trim(),
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

    _ninCtrl.dispose();
    _applicantNameCtrl.dispose();
    _applicantAddressCtrl.dispose();
    _physicalAddressCtrl.dispose();
    _postalAddressCtrl.dispose();
    _phoneFixedLineCtrl.dispose();
    _phoneMobileCtrl.dispose();
    _faxNumberCtrl.dispose();
    _contractorCtrl.dispose();
    _developmentPermitCtrl.dispose();

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
                            _currentStep == 6 ? 'SUBMIT' : 'CONTINUE',
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
      case 5:
        return _buildStep5();
      case 6:
        return _buildStep6();
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

  bool get _isClassC {
    if (_formTypeId == null) return false;
    final type = _formTypes
        .where((t) => t.id.toString() == _formTypeId)
        .firstOrNull;
    return type?.name.contains('Class C') ?? false;
  }

  bool get _isClassB {
    if (_formTypeId == null) return false;
    final type = _formTypes
        .where((t) => t.id.toString() == _formTypeId)
        .firstOrNull;
    return type?.name.contains('Class B') ?? false;
  }

  bool get _isClassA {
    if (_formTypeId == null) return false;
    final type = _formTypes
        .where((t) => t.id.toString() == _formTypeId)
        .firstOrNull;
    return type?.name.contains('Class A') ?? false;
  }

  bool get _isOccupationPermit {
    if (_applicationTypeId == null) return false;
    final type = _applicationTypes
        .where((a) => a.id.toString() == _applicationTypeId)
        .firstOrNull;
    return type?.name.toLowerCase().contains('occupation') ?? false;
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 1 OF 6', 'Application & Authority'),
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
            setState(() {
              _applicationTypeId = val;
              _formTypeId = null;
              if (val != null) {
                final appType = _applicationTypes
                    .where((a) => a.id.toString() == val)
                    .firstOrNull;
                if (appType != null) {
                  _formTypes = context.read<AuxiliaryRepository>().getFormTypes(
                    appType.slug,
                  );
                } else {
                  _formTypes = [];
                }
              } else {
                _formTypes = [];
              }
            });
          },
        ),
        if (_formTypes.isNotEmpty) ...[
          _buildLabel('FORM TYPE'),
          DropdownButtonFormField<String>(
            decoration: _inputDec(),
            hint: const Text('Select form type...'),
            value: _formTypeId,
            items: _formTypes
                .map(
                  (f) => DropdownMenuItem(
                    value: f.id.toString(),
                    child: Text(f.name, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => _formTypeId = val);
            },
          ),
        ],
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
            setState(() {
              _adminUnitId = val;
              _subcountyId = null;
              _parishId = null;
              _villageId = null;
              _roadId = null;
              _subcounties = [];
              _parishes = [];
              _villages = [];
              _roads = [];
            });
            if (val != null) _fetchSubcounties(val);
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 2 OF 6', 'Applicant Information'),
        _buildLabel('LEGAL STATUS OF APPLICANT'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select legal status'),
          value: _legalStatus,
          items: const [
            DropdownMenuItem(value: 'Individual', child: Text('Individual')),
            DropdownMenuItem(value: 'Company', child: Text('Company')),
            DropdownMenuItem(
              value: 'Organization',
              child: Text('Organization'),
            ),
          ],
          onChanged: (val) {
            setState(() => _legalStatus = val);
          },
        ),
        _buildLabel('NATIONAL ID NUMBER (NIN) / IDENTIFICATION NO.'),
        TextFormField(
          controller: _ninCtrl,
          decoration: _inputDec().copyWith(hintText: 'Enter NIN'),
        ),
        if (_isClassC) ...[
          _buildLabel('NAME OF APPLICANT'),
          TextFormField(
            controller: _applicantNameCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter name'),
          ),
          _buildLabel('ADDRESS OF APPLICANT'),
          TextFormField(
            controller: _applicantAddressCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter address'),
          ),
        ],
        _buildLabel('CONTACT PERSON (IF DIFFERENT)'),
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
        if (!_isClassC) ...[
          const SizedBox(height: 15),
          const Text(
            'Particulars of Applicant',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          _buildLabel('NAME'),
          TextFormField(
            controller: _applicantNameCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter name'),
          ),
          _buildLabel('PHYSICAL ADDRESS'),
          TextFormField(
            controller: _physicalAddressCtrl,
            decoration: _inputDec().copyWith(
              hintText: 'Enter physical address',
            ),
          ),
          _buildLabel('POSTAL ADDRESS'),
          TextFormField(
            controller: _postalAddressCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter postal address'),
          ),
          _buildLabel('TELEPHONE (FIXED LINE)'),
          TextFormField(
            controller: _phoneFixedLineCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDec().copyWith(hintText: 'Enter fixed line'),
          ),
          _buildLabel('MOBILE PHONE'),
          TextFormField(
            controller: _phoneMobileCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDec().copyWith(hintText: 'Enter mobile phone'),
          ),
          _buildLabel('FAX'),
          TextFormField(
            controller: _faxNumberCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter fax number'),
          ),
        ],
      ],
    );
  }

  Widget _buildFilePickerRow(
    String title,
    String? path,
    Function(String) onPicked,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              path == null
                  ? 'No file selected'
                  : path.split('\\').last.split('/').last,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ElevatedButton(
            onPressed: () => _pickFile(onPicked),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            ),
            child: const Text('UPLOAD', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 3 OF 6', 'Development Permission'),
        _buildLabel('DEVELOPMENT PERMIT NUMBER'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _developmentPermitCtrl,
                decoration: _inputDec().copyWith(hintText: 'Enter permit number'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isVerifyingDevelopmentPermit
                  ? null
                  : () async {
                      final permitNum = _developmentPermitCtrl.text.trim();
                      if (permitNum.isEmpty) return;
                      setState(() => _isVerifyingDevelopmentPermit = true);
                      try {
                        final isValid = await context
                            .read<ClientRepository>()
                            .verifyDevelopmentPermit(permitNum);
                        setState(() {
                          _isDevelopmentPermitVerified = isValid;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isValid
                                    ? 'Verified successfully!'
                                    : 'Invalid permit number',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          _isDevelopmentPermitVerified = false;
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid permit: $e')),
                          );
                        }
                      } finally {
                        setState(() => _isVerifyingDevelopmentPermit = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDevelopmentPermitVerified
                    ? Colors.green
                    : AppTheme.accentGold,
              ),
              child: _isVerifyingDevelopmentPermit
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isDevelopmentPermitVerified ? 'VERIFIED' : 'VERIFY',
                      style: const TextStyle(fontSize: 11),
                    ),
            ),
          ],
        ),
        if (!_isDevelopmentPermitVerified) ...[
        _buildLabel('PPC MINUTE NUMBER'),
        TextFormField(
          controller: _ppcMinuteNumberCtrl,
          decoration: _inputDec().copyWith(hintText: 'e.g PPC-MIN-1234'),
        ),
        _buildLabel('DATE OF PPC MEETING'),
        TextFormField(
          controller: _ppcDateCtrl,
          readOnly: true,
          decoration: _inputDec().copyWith(
            hintText: 'e.g 06/15/2026',
            suffixIcon: const Icon(Icons.calendar_today, size: 16),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _ppcDateCtrl.text =
                    "\${date.month.toString().padLeft(2, '0')}/\${date.day.toString().padLeft(2, '0')}/\${date.year}";
              });
            }
          },
        ),
        _buildLabel('APPLICANT NAME'),
        TextFormField(
          controller: _ppcApplicantNameCtrl,
          decoration: _inputDec().copyWith(hintText: 'e.g John Doe'),
        ),
        _buildLabel('APPROVED LAND-USE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select land-use'),
          value: _ppcApprovedLandUse,
          items: const [
            DropdownMenuItem(value: 'Residential', child: Text('Residential')),
            DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
            DropdownMenuItem(
              value: 'Institutional',
              child: Text('Institutional'),
            ),
            DropdownMenuItem(value: 'Industrial', child: Text('Industrial')),
            DropdownMenuItem(
              value: 'Recreational',
              child: Text('Recreational'),
            ),
            DropdownMenuItem(value: 'Mixed use', child: Text('Mixed use')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (val) {
            setState(() => _ppcApprovedLandUse = val);
          },
        ),
        _buildLabel('NUMBER OF LEVELS'),
        TextFormField(
          controller: _ppcNumLevelsCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDec().copyWith(hintText: 'e.g 1'),
        ),
        _buildLabel('NUMBER OF BLOCKS'),
        TextFormField(
          controller: _ppcNumBlocksCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDec().copyWith(hintText: 'e.g 1'),
        ),
        _buildLabel('PHYSICAL PLANNER (CONSULTANT)'),
        TextFormField(
          controller: _ppcPhysicalPlannerCtrl,
          decoration: _inputDec().copyWith(hintText: 'e.g Jane Doe'),
        ),
        _buildLabel('SUBCOUNTY'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Subcounty'),
          value: _subcountyId,
          items: _subcounties
              .map(
                (s) => DropdownMenuItem(
                  value: s['subcountyId'].toString(),
                  child: Text(
                    s['subCountyName'].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _subcountyId = val;
              _parishId = null;
              _villageId = null;
              _roadId = null;
              _parishes = [];
              _villages = [];
              _roads = [];
            });
            if (val != null) _fetchParishes(val);
          },
        ),

        _buildLabel('PARISH'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Parish'),
          value: _parishId,
          items: _parishes
              .map(
                (p) => DropdownMenuItem(
                  value: p['parishId'].toString(),
                  child: Text(
                    p['parishName'].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _parishId = val;
              _villageId = null;
              _roadId = null;
              _villages = [];
              _roads = [];
            });
            if (val != null) _fetchVillages(val);
          },
        ),

        _buildLabel('VILLAGE'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Village'),
          value: _villageId,
          items: _villages
              .map(
                (v) => DropdownMenuItem(
                  value: v['villageId'].toString(),
                  child: Text(
                    v['villageName'].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _villageId = val;
              _roadId = null;
              _roads = [];
            });
            if (val != null) _fetchRoads(val);
          },
        ),

        _buildLabel('ROAD'),
        DropdownButtonFormField<String>(
          decoration: _inputDec(),
          hint: const Text('Select Road'),
          value: _roadId,
          items: _roads
              .map(
                (r) => DropdownMenuItem(
                  value: r['roadId'].toString(),
                  child: Text(
                    r['streetName'].toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _roadId = val;
            });
          },
        ),
        const SizedBox(height: 15),
        // const Text(
        //   'Proof of Land ownership',
        //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        // ),
        // _buildLabel('CERTIFICATE OF TITLE'),
        // _buildFilePickerRow(
        //   'Certificate of Title',
        //   _certificateOfTitlePath,
        //   (path) => setState(() => _certificateOfTitlePath = path),
        // ),
        // _buildLabel('POWER OF ATTORNEY'),
        // _buildFilePickerRow(
        //   'Power of Attorney',
        //   _powerOfAttorneyPath,
        //   (path) => setState(() => _powerOfAttorneyPath = path),
        // ),
        // _buildLabel('SALES AGREEMENT'),
        // _buildFilePickerRow(
        //   'Sales Agreement',
        //   _salesAgreementPath,
        //   (path) => setState(() => _salesAgreementPath = path),
        // ),
        // _buildLabel('LETTER OF ADMINISTRATION'),
        // _buildFilePickerRow(
        //   'Letter of Administration',
        //   _letterOfAdministrationPath,
        //   (path) => setState(() => _letterOfAdministrationPath = path),
        // ),

        // const SizedBox(height: 15),
        // _buildLabel('BOUNDARY OPENING REPORT'),
        // _buildFilePickerRow(
        //   'Boundary Opening Report',
        //   _boundaryOpeningReportPath,
        //   (path) => setState(() => _boundaryOpeningReportPath = path),
        // ),

        // _buildLabel('REGISTERED LAND SURVEYOR'),
        // // Hardcoded dummy dropdown for now, since we haven't mapped the API for surveyors
        // DropdownButtonFormField<String>(
        //   decoration: _inputDec(),
        //   hint: const Text('Select Surveyor'),
        //   value: _surveyorId,
        //   items: const [
        //     DropdownMenuItem(value: '1', child: Text('Timothy Mutabaazi')),
        //     DropdownMenuItem(value: '2', child: Text('John Doe')),
        //   ],
        //   onChanged: (val) {
        //     setState(() => _surveyorId = val);
        //   },
        // ),
        // ),
        ]
      ],
    );
  }

  String _getSelectedLandTenureName() {
    if (_landTenureId == null) return '';
    final tenure = _landTenures
        .where((t) => t.id.toString() == _landTenureId)
        .firstOrNull;
    return tenure?.name.toLowerCase() ?? '';
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 4 OF 6', 'Site Details'),
        if (_isClassC) ...[
          _buildLabel('CONTRACTOR / BUILDING OPERATOR'),
          TextFormField(
            controller: _contractorCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter contractor name'),
          ),
        ],
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
          validator: (value) {
            if (_isClassC) {
              final val = double.tryParse(value ?? '');
              if (val != null && val > 30) {
                return 'Site Area cannot exceed 30 sq meters for Class C';
              }
            }
            return null;
          },
        ),
        _buildLabel('BUILDING HEIGHT (METERS)'),
        TextFormField(
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDec().copyWith(hintText: '0.00'),
          validator: (value) {
            if (_isClassC) {
              final val = double.tryParse(value ?? '');
              if (val != null && val > 3) {
                return 'Building Height cannot exceed 3 meters for Class C';
              }
            }
            return null;
          },
        ),
        if (!_isClassC) ...[
          _buildLabel('BUILT-UP AREA (SQUARE METRES)'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _builtupAreaCtrl,
                  readOnly: true,
                  decoration: _inputDec().copyWith(hintText: '0.00'),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _showBuiltUpAreaWizard(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                ),
                child: const Text('COMPUTE', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          _buildLabel('WATER SUPPLY'),
          DropdownButtonFormField<String>(
            decoration: _inputDec(),
            hint: const Text('Select Water Supply'),
            value: _waterSupply,
            items: const [
              DropdownMenuItem(value: 'YES', child: Text('YES')),
              DropdownMenuItem(value: 'NO', child: Text('NO')),
              DropdownMenuItem(value: 'N/A', child: Text('N/A')),
            ],
            onChanged: (val) => setState(() => _waterSupply = val),
          ),
          _buildLabel('SEWER CONNECTION'),
          DropdownButtonFormField<String>(
            decoration: _inputDec(),
            hint: const Text('Select Sewer Connection'),
            value: _sewerConnection,
            items: const [
              DropdownMenuItem(value: 'YES', child: Text('YES')),
              DropdownMenuItem(value: 'NO', child: Text('NO')),
              DropdownMenuItem(value: 'N/A', child: Text('N/A')),
            ],
            onChanged: (val) => setState(() => _sewerConnection = val),
          ),
          _buildLabel('ELECTRICITY SUPPLY'),
          DropdownButtonFormField<String>(
            decoration: _inputDec(),
            hint: const Text('Select Electricity Supply'),
            value: _electricitySupply,
            items: const [
              DropdownMenuItem(value: 'YES', child: Text('YES')),
              DropdownMenuItem(value: 'NO', child: Text('NO')),
              DropdownMenuItem(value: 'N/A', child: Text('N/A')),
            ],
            onChanged: (val) => setState(() => _electricitySupply = val),
          ),
          _buildLabel('INTERNET SUPPLY'),
          DropdownButtonFormField<String>(
            decoration: _inputDec(),
            hint: const Text('Select Internet Supply'),
            value: _internetSupply,
            items: const [
              DropdownMenuItem(value: 'YES', child: Text('YES')),
              DropdownMenuItem(value: 'NO', child: Text('NO')),
              DropdownMenuItem(value: 'N/A', child: Text('N/A')),
            ],
            onChanged: (val) => setState(() => _internetSupply = val),
          ),
        ],
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
        if (_getSelectedLandTenureName().contains('freehold') ||
            _getSelectedLandTenureName().contains('leasehold')) ...[
          _buildLabel('FOLIO'),
          TextFormField(
            controller: _folioCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter Folio'),
          ),
          _buildLabel('VOLUME'),
          TextFormField(
            controller: _volumeCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter Volume'),
          ),
        ] else if (_getSelectedLandTenureName().contains('mailo')) ...[
          _buildLabel('COUNTY'),
          TextFormField(
            controller: _countyCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter County'),
          ),
          _buildLabel('PLOT NUMBER'),
          TextFormField(
            controller: _plotNumberCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter Plot Number'),
          ),
          _buildLabel('BLOCK NUMBER'),
          TextFormField(
            controller: _blockNumberCtrl,
            decoration: _inputDec().copyWith(hintText: 'Enter Block Number'),
          ),
        ],
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

  Widget _buildProCodeField(
    String label,
    TextEditingController controller,
    String key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: _inputDec().copyWith(
                  hintText: 'Enter Pro link code...',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isEmpty) return;
                try {
                  final isValid = await context
                      .read<ClientRepository>()
                      .verifyAttachment(code);
                  setState(() {
                    _verifiedProCodes[key] = isValid;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isValid ? 'Verified successfully!' : 'Invalid code',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _verifiedProCodes[key] == true
                    ? Colors.green
                    : AppTheme.accentGold,
              ),
              child: Text(
                _verifiedProCodes[key] == true ? 'VERIFIED' : 'VERIFY',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 5 OF 6', 'Supporting Documents'),

        if (_isOccupationPermit) ...[
          _buildLabel('DO YOU HAVE AN APPROVED BUILDING PERMIT?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes', style: TextStyle(fontSize: 13)),
                  value: true,
                  groupValue: _hasApprovedPermit,
                  onChanged: (val) => setState(() {
                    _hasApprovedPermit = val;
                    _isPermitVerified = false;
                  }),
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No', style: TextStyle(fontSize: 13)),
                  value: false,
                  groupValue: _hasApprovedPermit,
                  onChanged: (val) => setState(() => _hasApprovedPermit = val),
                ),
              ),
            ],
          ),
          if (_hasApprovedPermit == true) ...[
            _buildLabel('PERMIT NUMBER'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _permitSerialCtrl,
                    decoration: _inputDec().copyWith(
                      hintText: 'Enter permit serial number',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isFetchingPermit
                      ? null
                      : () async {
                          final serial = _permitSerialCtrl.text.trim();
                          if (serial.isEmpty) return;
                          setState(() => _isFetchingPermit = true);
                          try {
                            final publicRepo = PublicRepository();
                            await publicRepo.verifyPermit(
                              serial,
                              ApiConstants.baseUrl,
                            );
                            setState(() {
                              _isPermitVerified = true;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Permit Verified successfully!',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _isPermitVerified = false;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid permit: $e')),
                              );
                            }
                          } finally {
                            setState(() => _isFetchingPermit = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPermitVerified
                        ? Colors.green
                        : AppTheme.accentGold,
                  ),
                  child: _isFetchingPermit
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isPermitVerified ? 'VERIFIED' : 'VERIFY',
                          style: const TextStyle(fontSize: 11),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (_hasApprovedPermit == false) ...[
            _buildLabel('UPLOAD OLD PERMIT (Required)'),
            _buildFilePickerRow(
              'Old Permit',
              _oldPermitPath,
              (p) => setState(() => _oldPermitPath = p),
            ),
          ],

          _buildProCodeField(
            'AS BUILT DRAWINGS (Required)',
            _asBuiltDrawingsCodeCtrl,
            'asBuiltDrawings',
          ),
          _buildProCodeField(
            'CERTIFICATE OF PRACTICAL COMPLETION (Required)',
            _certificateOfPracticalCompletionCodeCtrl,
            'certificateOfPracticalCompletion',
          ),
          _buildProCodeField(
            'CERTIFICATE OF APPROVAL FOR FIRE DETECTION (Required)',
            _certificateOfApprovalForFireDetectionCodeCtrl,
            'certificateOfApprovalForFireDetection',
          ),
          _buildProCodeField(
            'AS BUILT STRUCTURAL DRAWINGS (Optional)',
            _asBuiltStructuralDrawingsCodeCtrl,
            'asBuiltStructuralDrawings',
          ),
          _buildProCodeField(
            'AS BUILT ELECTRICAL DRAWINGS (Optional)',
            _asBuiltElectricalDrawingsCodeCtrl,
            'asBuiltElectricalDrawings',
          ),
          _buildProCodeField(
            'AS BUILT MECHANICAL DRAWINGS (Optional)',
            _asBuiltMechanicalDrawingsCodeCtrl,
            'asBuiltMechanicalDrawings',
          ),
          _buildProCodeField(
            'CERTIFICATE OF FITNESS OF MECHANICAL INSTALLATION (Optional)',
            _certificateOfFitnessOfTheMechanicalInstallationCodeCtrl,
            'certificateOfFitnessOfTheMechanicalInstallation',
          ),
        ] else ...[
          // Building Permit Flow
          if (_isClassA || _isClassB || _isClassC) ...[
            _buildLabel('VILLAGE LC LETTER (Required)'),
            _buildFilePickerRow(
              'LC Letter',
              _lcLetterPath,
              (p) => setState(() => _lcLetterPath = p),
            ),
          ],

          if (_isClassC) ...[
            _buildLabel('BUILDING SKETCH PLAN (Required)'),
            _buildFilePickerRow(
              'Sketch Plan',
              _sketchPlanPath,
              (p) => setState(() => _sketchPlanPath = p),
            ),
          ],

          _buildLabel(
            'LAND TITLE (Optional if Sales Agreement/Power of Attorney uploaded)',
          ),
          _buildFilePickerRow(
            'Land Title',
            _certificateOfTitlePath,
            (p) => setState(() => _certificateOfTitlePath = p),
          ),

          _buildLabel(
            'POWER OF ATTORNEY (Optional if Land Title/Sales Agreement uploaded)',
          ),
          _buildFilePickerRow(
            'Power of Attorney',
            _powerOfAttorneyPath,
            (p) => setState(() => _powerOfAttorneyPath = p),
          ),

          if (_isClassA || _isClassC) ...[
            _buildLabel(
              'LAND SALES AGREEMENT (Optional if Land Title/Power of Attorney uploaded)',
            ),
            _buildFilePickerRow(
              'Sales Agreement',
              _salesAgreementPath,
              (p) => setState(() => _salesAgreementPath = p),
            ),

            _buildLabel(
              'CERTIFICATE OF ENVIRONMENTAL IMPACT ASSESSMENT (NEMA) (Optional)',
            ),
            _buildFilePickerRow(
              'NEMA Certificate',
              _certificateNemaPath,
              (p) => setState(() => _certificateNemaPath = p),
            ),

            _buildLabel('TRAFFIC IMPACT ASSESSMENT (Optional)'),
            _buildFilePickerRow(
              'Traffic Impact Assessment',
              _trafficImpactAssessmentPath,
              (p) => setState(() => _trafficImpactAssessmentPath = p),
            ),
          ],

          if (_isClassA) ...[
            _buildLabel('GEO TECHNICAL REPORT (Optional)'),
            _buildFilePickerRow(
              'Geo Technical Report',
              _geoTechReportPath,
              (p) => setState(() => _geoTechReportPath = p),
            ),
          ],

          if (_isClassA || _isClassC) ...[
            const Divider(height: 30),
            const Text(
              'PRO LINK CODES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 10),
            _buildProCodeField(
              'BOUNDARY OPENING REPORT (Required)',
              _boundaryOpeningReportCodeCtrl,
              'boundaryOpeningReport',
            ),
            _buildProCodeField(
              'ARCHITECTURAL DRAWINGS (Required)',
              _architecturalDrawingsCodeCtrl,
              'architecturalDrawings',
            ),
            _buildProCodeField(
              _isClassC
                  ? 'CIVIL/STRUCTURAL ENG DRAWINGS (Optional)'
                  : 'CIVIL/STRUCTURAL ENG DRAWINGS (Required)',
              _servicesDrawingsCodeCtrl,
              'servicesDrawings',
            ),
          ],

          if (_isClassA) ...[
            _buildProCodeField(
              'MECHANICAL ENGINEERING DRAWINGS (Required)',
              _mechanicalDrawingsCodeCtrl,
              'mechanicalDrawings',
            ),
            _buildProCodeField(
              'ELECTRICAL ENGINEERING DRAWINGS (Required)',
              _electricalDrawingsCodeCtrl,
              'electricalDrawings',
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStep6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('STEP 6 OF 6', 'Review & Submit'),
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

  Future<void> _showBuiltUpAreaWizard(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => BuiltUpAreaWizardDialog(initialData: _buildingsArea),
    );
    if (result != null) {
      setState(() {
        _buildingsArea = result['buildings'] as List<Map<String, dynamic>>;
        _builtupAreaCtrl.text = (result['total'] as double).toString();
      });
    }
  }
}

class BuiltUpAreaWizardDialog extends StatefulWidget {
  final List<Map<String, dynamic>> initialData;
  const BuiltUpAreaWizardDialog({super.key, required this.initialData});

  @override
  State<BuiltUpAreaWizardDialog> createState() =>
      _BuiltUpAreaWizardDialogState();
}

class _BuiltUpAreaWizardDialogState extends State<BuiltUpAreaWizardDialog> {
  // Each building is a list of floor areas
  List<List<TextEditingController>> _buildings = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData.isNotEmpty) {
      for (var b in widget.initialData) {
        List<TextEditingController> floorCtrls = [];
        List floors = b['floors'] ?? [];
        for (var f in floors) {
          floorCtrls.add(TextEditingController(text: f['area'].toString()));
        }
        _buildings.add(floorCtrls);
      }
    }
    if (_buildings.isEmpty) {
      _buildings.add([
        TextEditingController(),
      ]); // 1 building with 1 floor by default
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalArea = 0;
    for (var b in _buildings) {
      for (var f in b) {
        totalArea += double.tryParse(f.text) ?? 0.0;
      }
    }

    return AlertDialog(
      title: const Text(
        'Built-up Area Computation',
        style: TextStyle(fontSize: 16),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _buildings.length,
                itemBuilder: (context, bIndex) {
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Building ${bIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (_buildings.length > 1)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _buildings.removeAt(bIndex),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ...List.generate(_buildings[bIndex].length, (fIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Floor ${fIndex + 1} Area (sqm):',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      controller: _buildings[bIndex][fIndex],
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => setState(() {}),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  if (_buildings[bIndex].length > 1)
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _buildings[bIndex].removeAt(fIndex),
                                      ),
                                    )
                                  else
                                    const SizedBox(
                                      width: 16,
                                    ), // placeholder for alignment
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 24,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => setState(
                                () => _buildings[bIndex].add(
                                  TextEditingController(),
                                ),
                              ),
                              child: const Text(
                                '+ Add Floor',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_buildings.length < 50)
              TextButton(
                onPressed: () =>
                    setState(() => _buildings.add([TextEditingController()])),
                child: const Text('+ Add Building'),
              ),
            const Divider(),
            Text(
              'Total Built-up Area: $totalArea sqm',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            List<Map<String, dynamic>> result = [];
            for (int i = 0; i < _buildings.length; i++) {
              List<Map<String, dynamic>> floors = [];
              for (int j = 0; j < _buildings[i].length; j++) {
                floors.add({
                  'floorIndex': j + 1,
                  'area': double.tryParse(_buildings[i][j].text) ?? 0.0,
                });
              }
              result.add({
                'buildingIndex': i + 1,
                'numberOfFloors': _buildings[i].length,
                'floors': floors,
              });
            }
            Navigator.pop(context, {'buildings': result, 'total': totalArea});
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
