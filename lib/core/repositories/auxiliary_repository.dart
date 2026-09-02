import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../network/bco_api_client.dart';
import '../network/pro_api_client.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../models/auxiliary/admin_unit_type.dart';
import '../models/auxiliary/admin_unit.dart';
import '../models/auxiliary/user_role.dart';
import '../models/auxiliary/building_classification.dart';
import '../models/auxiliary/express_penalty_offence_type.dart';
import '../models/auxiliary/whistle_blower_category.dart';
import '../models/auxiliary/building_purpose.dart';
import '../models/auxiliary/land_tenures.dart';
import '../models/auxiliary/application_type.dart';
import '../models/auxiliary/form_type.dart';
import '../models/auxiliary/building_operation.dart';
import '../models/auxiliary/inspection_type.dart';
import '../models/auxiliary/inspection_status.dart';
import '../models/auxiliary/payment_mode.dart';

enum SyncStatusState { pending, syncing, success, failed }

class SyncItemStatus {
  final String key;
  final String title;
  final SyncStatusState status;
  final int count;
  final String? errorMessage;
  final DateTime? completedAt;

  const SyncItemStatus({
    required this.key,
    required this.title,
    this.status = SyncStatusState.pending,
    this.count = 0,
    this.errorMessage,
    this.completedAt,
  });

  SyncItemStatus copyWith({
    SyncStatusState? status,
    int? count,
    String? errorMessage,
    DateTime? completedAt,
  }) {
    return SyncItemStatus(
      key: key,
      title: title,
      status: status ?? this.status,
      count: count ?? this.count,
      errorMessage: errorMessage ?? this.errorMessage,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class AuxiliaryRepository {
  final BcoApiClient bcoApiClient;
  final ProApiClient proApiClient;
  final ApiClient clientApiClient;
  static const String _boxName = 'auxiliaryBox';

  static const List<Map<String, String>> syncItemDefinitions = [
    {'key': 'admin_unit_types', 'title': 'Administrative Unit Types'},
    {'key': 'admin_units', 'title': 'Administrative Units'},
    {'key': 'user_roles', 'title': 'User Roles'},
    {'key': 'building_classifications', 'title': 'Building Classifications'},
    {'key': 'eps_types', 'title': 'Express Penalty Types'},
    {'key': 'wb_categories', 'title': 'Whistleblower Categories'},
    {'key': 'building_purposes', 'title': 'Building Purposes'},
    {'key': 'land_tenures', 'title': 'Land Tenures'},
    {'key': 'application_types', 'title': 'Application Types'},
    {'key': 'form_types', 'title': 'Form Types'},
    {'key': 'building_operations', 'title': 'Building Operations'},
    {'key': 'inspection_types', 'title': 'Inspection Types'},
    {'key': 'inspection_statuses', 'title': 'Inspection Statuses'},
    {'key': 'payment_modes', 'title': 'Payment Modes'},
  ];

  AuxiliaryRepository({
    required this.bcoApiClient,
    required this.proApiClient,
    required this.clientApiClient,
  });

  Box get _box => Hive.box(_boxName);

  DateTime? getLastSyncTimestamp() {
    try {
      final lastSyncStr = _box.get('last_sync_timestamp');
      if (lastSyncStr != null) {
        return DateTime.parse(lastSyncStr as String);
      }
    } catch (_) {}
    return null;
  }

  Map<String, int> getStoredCounts() {
    final Map<String, int> counts = {};
    for (final def in syncItemDefinitions) {
      final key = def['key']!;
      try {
        final data = _box.get(key);
        if (data != null) {
          final List<dynamic> decoded = jsonDecode(data as String);
          counts[key] = decoded.length;
        } else {
          counts[key] = 0;
        }
      } catch (_) {
        counts[key] = 0;
      }
    }
    return counts;
  }

  Future<void> clearAuxiliaryData() async {
    for (final def in syncItemDefinitions) {
      await _box.delete(def['key']!);
    }
    await _box.delete('last_sync_timestamp');
  }

  Future<Map<String, SyncItemStatus>> syncAuxiliaryData({
    bool forceSync = false,
    void Function(Map<String, SyncItemStatus> statusMap)? onProgress,
  }) async {
    final Map<String, SyncItemStatus> statusMap = {};
    for (final def in syncItemDefinitions) {
      statusMap[def['key']!] = SyncItemStatus(
        key: def['key']!,
        title: def['title']!,
        status: SyncStatusState.pending,
        count: getStoredCounts()[def['key']!] ?? 0,
      );
    }
    onProgress?.call(Map.from(statusMap));

    if (!forceSync) {
      final lastSync = getLastSyncTimestamp();
      if (lastSync != null) {
        final diff = DateTime.now().difference(lastSync);
        if (diff.inDays < 30) {
          // Check if we actually have data stored; if empty, don't skip
          final counts = getStoredCounts();
          final hasData = counts.values.any((c) => c > 0);
          if (hasData) {
            return statusMap;
          }
        }
      }
    }

    void updateStatus(String key, SyncStatusState state, {int? count, String? error}) {
      final current = statusMap[key];
      if (current != null) {
        statusMap[key] = current.copyWith(
          status: state,
          count: count ?? current.count,
          errorMessage: error,
          completedAt: state == SyncStatusState.success || state == SyncStatusState.failed
              ? DateTime.now()
              : null,
        );
        onProgress?.call(Map.from(statusMap));
      }
    }

    List<Map<String, dynamic>> finalAdminUnitTypes = [];
    List<Map<String, dynamic>> finalApplicationTypes = [];

    // 1. Admin Unit Types
    updateStatus('admin_unit_types', SyncStatusState.syncing);
    try {
      final typesResponse = await clientApiClient.dio.get(ApiConstants.adminUnitTypes);
      final List<dynamic> typesData = typesResponse.data['data']?['data'] ?? [];
      finalAdminUnitTypes = typesData.map((typeJson) => {
        'id': typeJson['id'] is int ? typeJson['id'] : int.tryParse(typeJson['id']?.toString() ?? '') ?? 0,
        'name': typeJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('admin_unit_types', jsonEncode(finalAdminUnitTypes));
      updateStatus('admin_unit_types', SyncStatusState.success, count: finalAdminUnitTypes.length);
    } catch (e) {
      debugPrint('Error fetching admin unit types: $e');
      updateStatus('admin_unit_types', SyncStatusState.failed, error: e.toString());
    }

    // 2. Admin Units
    updateStatus('admin_units', SyncStatusState.syncing);
    try {
      final types = finalAdminUnitTypes.isNotEmpty
          ? finalAdminUnitTypes
          : getAdminUnitTypes().map((e) => e.toJson()).toList();

      final List<Map<String, dynamic>> finalAdminUnits = [];
      for (final typeJson in types) {
        final typeId = typeJson['id'];
        try {
          final unitsResponse = await clientApiClient.dio.get(
            '${ApiConstants.adminUnitsList}?type=$typeId',
          );
          final List<dynamic> unitsData = unitsResponse.data['data']?['data'] ?? [];
          for (final unitJson in unitsData) {
            finalAdminUnits.add({
              'id': unitJson['id'] is int ? unitJson['id'] : int.tryParse(unitJson['id']?.toString() ?? '') ?? 0,
              'name': unitJson['name']?.toString() ?? '',
              'typeId': typeId,
              'districtId': (unitJson['districtId'] ?? unitJson['dID'])?.toString() ?? '',
            });
          }
        } catch (e) {
          debugPrint('Error fetching admin units for type $typeId: $e');
        }
      }
      await _box.put('admin_units', jsonEncode(finalAdminUnits));
      updateStatus('admin_units', SyncStatusState.success, count: finalAdminUnits.length);
    } catch (e) {
      debugPrint('Error fetching admin units: $e');
      updateStatus('admin_units', SyncStatusState.failed, error: e.toString());
    }

    // 3. User Roles
    updateStatus('user_roles', SyncStatusState.syncing);
    try {
      final rolesResponse = await bcoApiClient.dio.get(ApiConstants.userRoles);
      final List<dynamic> rolesData = rolesResponse.data['data']?['data'] ?? [];
      final finalUserRoles = rolesData.map((roleJson) => {
        'id': roleJson['id'] is int ? roleJson['id'] : int.tryParse(roleJson['id']?.toString() ?? '') ?? 0,
        'name': roleJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('user_roles', jsonEncode(finalUserRoles));
      updateStatus('user_roles', SyncStatusState.success, count: finalUserRoles.length);
    } catch (e) {
      debugPrint('Error fetching user roles: $e');
      updateStatus('user_roles', SyncStatusState.failed, error: e.toString());
    }

    // 4. Building Classifications
    updateStatus('building_classifications', SyncStatusState.syncing);
    try {
      final bcResponse = await bcoApiClient.dio.get(ApiConstants.buildingClassifications);
      final List<dynamic> bcData = bcResponse.data['data']?['data'] ?? [];
      final finalBuildingClassifications = bcData.map((bcJson) => {
        'id': bcJson['id'] is int ? bcJson['id'] : int.tryParse(bcJson['id']?.toString() ?? '') ?? 0,
        'name': bcJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('building_classifications', jsonEncode(finalBuildingClassifications));
      updateStatus('building_classifications', SyncStatusState.success, count: finalBuildingClassifications.length);
    } catch (e) {
      debugPrint('Error fetching building classifications: $e');
      updateStatus('building_classifications', SyncStatusState.failed, error: e.toString());
    }

    // 5. Express Penalty Offence Types
    updateStatus('eps_types', SyncStatusState.syncing);
    try {
      final String response = await rootBundle.loadString('assets/eps_data.json');
      final epsResponse = json.decode(response);
      final List<dynamic> epsData = epsResponse['data']?['data'] ?? [];
      final finalEpsTypes = epsData.map((epsJson) => {
        'id': epsJson['id'] is int ? epsJson['id'] : int.tryParse(epsJson['id']?.toString() ?? '') ?? 0,
        'enactment': epsJson['enactment']?.toString() ?? '',
        'offence_name': (epsJson['offence_name'] ?? epsJson['offenceName'])?.toString() ?? '',
        'currency_points': epsJson['currency_points'] is int ? epsJson['currency_points'] : int.tryParse(epsJson['currency_points']?.toString() ?? '') ?? 0,
        'charge_per_sqm': epsJson['charge_per_sqm'] == true || epsJson['charge_per_sqm'] == 1 || epsJson['charge_per_sqm'] == '1',
      }).toList();
      await _box.put('eps_types', jsonEncode(finalEpsTypes));
      updateStatus('eps_types', SyncStatusState.success, count: finalEpsTypes.length);
    } catch (e) {
      debugPrint('Error loading EPS types: $e');
      updateStatus('eps_types', SyncStatusState.failed, error: e.toString());
    }

    // 6. Whistleblower Categories
    updateStatus('wb_categories', SyncStatusState.syncing);
    try {
      final wbResponse = await clientApiClient.dio.get(ApiConstants.wbCategories);
      final List<dynamic> wbData = wbResponse.data['data']?['data'] ?? [];
      final finalWbCategories = wbData.map((wbJson) => {
        'id': wbJson['id'] is int ? wbJson['id'] : int.tryParse(wbJson['id']?.toString() ?? '') ?? 0,
        'name': wbJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('wb_categories', jsonEncode(finalWbCategories));
      updateStatus('wb_categories', SyncStatusState.success, count: finalWbCategories.length);
    } catch (e) {
      debugPrint('Error fetching whistleblower categories: $e');
      updateStatus('wb_categories', SyncStatusState.failed, error: e.toString());
    }

    // 7. Building Purposes
    updateStatus('building_purposes', SyncStatusState.syncing);
    try {
      final bpResponse = await clientApiClient.dio.get(ApiConstants.buildingPurposes);
      final List<dynamic> bpData = bpResponse.data['data']?['data'] ?? [];
      final finalBuildingPurposes = bpData.map((bpJson) => {
        'id': bpJson['id'] is int ? bpJson['id'] : int.tryParse(bpJson['id']?.toString() ?? '') ?? 0,
        'name': bpJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('building_purposes', jsonEncode(finalBuildingPurposes));
      updateStatus('building_purposes', SyncStatusState.success, count: finalBuildingPurposes.length);
    } catch (e) {
      debugPrint('Error fetching building purposes: $e');
      updateStatus('building_purposes', SyncStatusState.failed, error: e.toString());
    }

    // 8. Land Tenures
    updateStatus('land_tenures', SyncStatusState.syncing);
    try {
      final ltResponse = await clientApiClient.dio.get(ApiConstants.landTenures);
      final List<dynamic> ltData = ltResponse.data['data']?['data'] ?? [];
      final finalLandTenures = ltData.map((ltJson) => {
        'id': ltJson['id'] is int ? ltJson['id'] : int.tryParse(ltJson['id']?.toString() ?? '') ?? 0,
        'name': ltJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('land_tenures', jsonEncode(finalLandTenures));
      updateStatus('land_tenures', SyncStatusState.success, count: finalLandTenures.length);
    } catch (e) {
      debugPrint('Error fetching land tenures: $e');
      updateStatus('land_tenures', SyncStatusState.failed, error: e.toString());
    }

    // 9. Application Types
    updateStatus('application_types', SyncStatusState.syncing);
    try {
      final appResponse = await clientApiClient.dio.get(ApiConstants.applicationTypes);
      final List<dynamic> appData = appResponse.data['data']?['data'] ?? [];
      finalApplicationTypes = appData.map((appJson) => {
        'id': appJson['id'] is int ? appJson['id'] : int.tryParse(appJson['id']?.toString() ?? '') ?? 0,
        'name': appJson['name']?.toString() ?? '',
        'slug': appJson['slug']?.toString() ?? '',
      }).toList();
      await _box.put('application_types', jsonEncode(finalApplicationTypes));
      updateStatus('application_types', SyncStatusState.success, count: finalApplicationTypes.length);
    } catch (e) {
      debugPrint('Error fetching application types: $e');
      updateStatus('application_types', SyncStatusState.failed, error: e.toString());
    }

    // 10. Form Types
    updateStatus('form_types', SyncStatusState.syncing);
    try {
      final apps = finalApplicationTypes.isNotEmpty
          ? finalApplicationTypes
          : getApplicationTypes().map((e) => e.toJson()).toList();

      final List<Map<String, dynamic>> finalFormTypes = [];
      for (final appJson in apps) {
        final slug = appJson['slug'];
        try {
          final ftResponse = await clientApiClient.dio.get(
            '${ApiConstants.formTypes}?slug=$slug',
          );
          final List<dynamic> ftData = ftResponse.data['data']?['data'] ?? [];
          for (final ftJson in ftData) {
            finalFormTypes.add({
              'id': ftJson['id'] is int ? ftJson['id'] : int.tryParse(ftJson['id']?.toString() ?? '') ?? 0,
              'name': ftJson['name']?.toString() ?? '',
              'application_type_slug': slug,
            });
          }
        } catch (e) {
          debugPrint('Error fetching form types for $slug: $e');
        }
      }
      await _box.put('form_types', jsonEncode(finalFormTypes));
      updateStatus('form_types', SyncStatusState.success, count: finalFormTypes.length);
    } catch (e) {
      debugPrint('Error fetching form types: $e');
      updateStatus('form_types', SyncStatusState.failed, error: e.toString());
    }

    // 11. Building Operations
    updateStatus('building_operations', SyncStatusState.syncing);
    try {
      final boResponse = await clientApiClient.dio.get(ApiConstants.buildingOperations);
      final List<dynamic> boData = boResponse.data['data']?['data'] ?? [];
      final finalBuildingOperations = boData.map((boJson) => {
        'id': boJson['id'] is int ? boJson['id'] : int.tryParse(boJson['id']?.toString() ?? '') ?? 0,
        'name': boJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('building_operations', jsonEncode(finalBuildingOperations));
      updateStatus('building_operations', SyncStatusState.success, count: finalBuildingOperations.length);
    } catch (e) {
      debugPrint('Error fetching building operations: $e');
      updateStatus('building_operations', SyncStatusState.failed, error: e.toString());
    }

    // 12. Inspection Types
    updateStatus('inspection_types', SyncStatusState.syncing);
    try {
      final itResponse = await bcoApiClient.dio.get(ApiConstants.inspectionTypes);
      final List<dynamic> itData = itResponse.data['data']?['data'] ?? [];
      final finalInspectionTypes = itData.map((itJson) => {
        'id': itJson['id'] is int ? itJson['id'] : int.tryParse(itJson['id']?.toString() ?? '') ?? 0,
        'name': itJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('inspection_types', jsonEncode(finalInspectionTypes));
      updateStatus('inspection_types', SyncStatusState.success, count: finalInspectionTypes.length);
    } catch (e) {
      debugPrint('Error fetching inspection types: $e');
      updateStatus('inspection_types', SyncStatusState.failed, error: e.toString());
    }

    // 13. Inspection Statuses
    updateStatus('inspection_statuses', SyncStatusState.syncing);
    try {
      final itResponse = await bcoApiClient.dio.get(ApiConstants.inspectionStatuses);
      final List<dynamic> itData = itResponse.data['data']?['data'] ?? [];
      final finalInspectionStatuses = itData.map((itJson) => {
        'id': itJson['id'] is int ? itJson['id'] : int.tryParse(itJson['id']?.toString() ?? '') ?? 0,
        'name': itJson['name']?.toString() ?? '',
      }).toList();
      await _box.put('inspection_statuses', jsonEncode(finalInspectionStatuses));
      updateStatus('inspection_statuses', SyncStatusState.success, count: finalInspectionStatuses.length);
    } catch (e) {
      debugPrint('Error fetching inspection statuses: $e');
      updateStatus('inspection_statuses', SyncStatusState.failed, error: e.toString());
    }

    // 14. Payment Modes
    updateStatus('payment_modes', SyncStatusState.syncing);
    try {
      final pmResponse = await clientApiClient.dio.get(ApiConstants.paymentModes);
      final List<dynamic> pmData = pmResponse.data['data']?['data'] ?? [];
      final finalPaymentModes = pmData.map((pmJson) => {
        'id': pmJson['id'] is int ? pmJson['id'] : int.tryParse(pmJson['id']?.toString() ?? '') ?? 0,
        'name': pmJson['name']?.toString() ?? '',
        'description': pmJson['description']?.toString() ?? '',
      }).toList();
      await _box.put('payment_modes', jsonEncode(finalPaymentModes));
      updateStatus('payment_modes', SyncStatusState.success, count: finalPaymentModes.length);
    } catch (e) {
      debugPrint('Error fetching payment modes: $e');
      updateStatus('payment_modes', SyncStatusState.failed, error: e.toString());
    }

    // Update last sync timestamp if any category succeeded
    final anySuccess = statusMap.values.any((s) => s.status == SyncStatusState.success);
    if (anySuccess) {
      await _box.put('last_sync_timestamp', DateTime.now().toIso8601String());
    }

    return statusMap;
  }

  List<T> _decodeList<T>(String key, T? Function(Map<String, dynamic>) fromJson) {
    final data = _box.get(key);
    if (data == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data as String);
      return decoded
          .map((e) {
            try {
              if (e is Map<String, dynamic>) {
                return fromJson(e);
              } else if (e is Map) {
                return fromJson(Map<String, dynamic>.from(e));
              }
              return null;
            } catch (err) {
              debugPrint('Error decoding item in $key: $err');
              return null;
            }
          })
          .whereType<T>()
          .toList();
    } catch (e) {
      debugPrint('Error reading $key from Hive: $e');
      return [];
    }
  }

  List<AdminUnitType> getAdminUnitTypes() {
    return _decodeList('admin_unit_types', (json) => AdminUnitType.fromJson(json));
  }

  List<AdminUnit> getAdminUnits(int typeId) {
    return getAllAdminUnits().where((unit) => unit.typeId == typeId).toList();
  }

  List<AdminUnit> getAllAdminUnits() {
    return _decodeList('admin_units', (json) => AdminUnit.fromJsonFull(json));
  }

  List<UserRole> getUserRoles() {
    return _decodeList('user_roles', (json) => UserRole.fromJson(json));
  }

  List<BuildingClassification> getBuildingClassifications() {
    return _decodeList('building_classifications', (json) => BuildingClassification.fromJson(json));
  }

  List<ExpressPenaltyOffenceType> getExpressPenaltyOffenceTypes() {
    return _decodeList('eps_types', (json) => ExpressPenaltyOffenceType.fromJson(json));
  }

  List<WhistleBlowerCategory> getWhistleBlowerCategories() {
    return _decodeList('wb_categories', (json) => WhistleBlowerCategory.fromJson(json));
  }

  List<BuildingPurpose> getBuildingPurposes() {
    return _decodeList('building_purposes', (json) => BuildingPurpose.fromJson(json));
  }

  List<LandTenure> getLandTenures() {
    return _decodeList('land_tenures', (json) => LandTenure.fromJson(json));
  }

  List<ApplicationType> getApplicationTypes() {
    return _decodeList('application_types', (json) => ApplicationType.fromJson(json));
  }

  List<FormType> getFormTypes(String applicationSlug) {
    return getAllFormTypes()
        .where((ft) => ft.applicationTypeSlug == applicationSlug)
        .toList();
  }

  List<FormType> getAllFormTypes() {
    return _decodeList('form_types', (json) => FormType.fromJsonFull(json));
  }

  List<BuildingOperation> getBuildingOperations() {
    return _decodeList('building_operations', (json) => BuildingOperation.fromJson(json));
  }

  List<InspectionType> getInspectionTypes() {
    return _decodeList('inspection_types', (json) => InspectionType.fromJson(json));
  }

  List<InspectionStatus> getInspectionStatuses() {
    return _decodeList('inspection_statuses', (json) => InspectionStatus.fromJson(json));
  }

  List<PaymentMode> getPaymentModes() {
    return _decodeList('payment_modes', (json) => PaymentMode.fromJson(json));
  }
}
