import 'dart:convert';
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

class AuxiliaryRepository {
  final BcoApiClient bcoApiClient;
  final ProApiClient proApiClient;
  final ApiClient clientApiClient;
  static const String _boxName = 'auxiliaryBox';

  AuxiliaryRepository({
    required this.bcoApiClient,
    required this.proApiClient,
    required this.clientApiClient,
  });

  Box get _box => Hive.box(_boxName);

  Future<void> syncAuxiliaryData({bool forceSync = false}) async {
    try {
      final lastSyncStr = _box.get('last_sync_timestamp');
      bool shouldSync = true;

      if (!forceSync && lastSyncStr != null) {
        final lastSyncDate = DateTime.parse(lastSyncStr);
        final difference = DateTime.now().difference(lastSyncDate);
        if (difference.inDays < 30) {
          shouldSync = false;
        }
      }

      if (!shouldSync) {
        // print('Auxiliary data is up to date. Sychronization skipped.');
        return;
      }

      // print('Started synchronizing auxiliary data...');

      // 1. Fetch Admin Unit Types
      final typesResponse = await bcoApiClient.dio.get(
        ApiConstants.adminUnitTypes,
      );
      List<dynamic> typesData = typesResponse.data['data']?['data'] ?? [];

      List<Map<String, dynamic>> finalAdminUnitTypes = [];
      List<Map<String, dynamic>> finalAdminUnits = [];

      for (var typeJson in typesData) {
        final typeId = typeJson['id'];
        finalAdminUnitTypes.add({'id': typeId, 'name': typeJson['name']});

        // 2. Fetch Admin Units for this type
        try {
          final unitsResponse = await bcoApiClient.dio.get(
            '${ApiConstants.adminUnitsList}?type=$typeId',
          );
          List<dynamic> unitsData = unitsResponse.data['data']?['data'] ?? [];
          for (var unitJson in unitsData) {
            finalAdminUnits.add({
              'id': unitJson['id'],
              'name': unitJson['name'],
              'typeId': typeId,
            });
          }
        } catch (e) {
          // print('Error fetching admin units for type $typeId: $e');
        }
      }

      // 3. Fetch User Roles
      List<Map<String, dynamic>> finalUserRoles = [];
      try {
        final rolesResponse = await bcoApiClient.dio.get(
          ApiConstants.userRoles,
        );
        List<dynamic> rolesData = rolesResponse.data['data']?['data'] ?? [];
        for (var roleJson in rolesData) {
          finalUserRoles.add({'id': roleJson['id'], 'name': roleJson['name']});
        }
      } catch (e) {
        // print('Error fetching user roles: $e');
      }

      // 4. Fetch Building Classifications
      List<Map<String, dynamic>> finalBuildingClassifications = [];
      try {
        final bcResponse = await bcoApiClient.dio.get(
          ApiConstants.buildingClassifications,
        );
        List<dynamic> bcData = bcResponse.data['data']?['data'] ?? [];
        for (var bcJson in bcData) {
          finalBuildingClassifications.add({
            'id': bcJson['id'],
            'name': bcJson['name'],
          });
        }
      } catch (e) {
        // print('Error fetching building classifications: $e');
      }

      // 5. Fetch Express Penalty Offence Types
      List<Map<String, dynamic>> finalEpsTypes = [];
      try {
        //  final epsResponse = await bcoApiClient.dio.get(ApiConstants.epsTypes);

        // Load the string from assets
        final String response = await rootBundle.loadString(
          'assets/eps_data.json',
        );

        // Parse the string into a JSON object
        final epsResponse = await json.decode(response);
        // List<dynamic> epsData = epsResponse.data['data']?['data'] ?? [];
        List<dynamic> epsData = epsResponse['data']?['data'] ?? [];
        for (var epsJson in epsData) {
          finalEpsTypes.add({
            'id': epsJson['id'],
            'enactment': epsJson['enactment'],
            'offence_name': epsJson['offence_name'],
            'currency_points': epsJson['currency_points'],
            'charge_per_sqm': epsJson['charge_per_sqm'],
          });
        }
      } catch (e) {
        print('Error fetching EPS types: $e');
      }

      // 6. Fetch Whistleblower Categories
      List<Map<String, dynamic>> finalWbCategories = [];
      try {
        final wbResponse = await clientApiClient.dio.get(
          ApiConstants.wbCategories,
        );
        List<dynamic> wbData = wbResponse.data['data']?['data'] ?? [];
        for (var wbJson in wbData) {
          finalWbCategories.add({'id': wbJson['id'], 'name': wbJson['name']});
        }
      } catch (e) {
        print('Error fetching whistleblower categories: $e');
      }

      // 7. fetch building purposes
      List<Map<String, dynamic>> finalBuildingPurposes = [];
      try {
        final bpResponse = await clientApiClient.dio.get(
          ApiConstants.buildingPurposes,
        );
        List<dynamic> bpData = bpResponse.data['data']?['data'] ?? [];
        for (var bpJson in bpData) {
          finalBuildingPurposes.add({
            'id': bpJson['id'],
            'name': bpJson['name'],
          });
        }
      } catch (e) {
        print('Error fetching building purposes: $e');
      }

      // 8. fetch land tenures
      List<Map<String, dynamic>> finalLandTenures = [];
      try {
        final ltResponse = await clientApiClient.dio.get(
          ApiConstants.landTenures,
        );
        List<dynamic> ltData = ltResponse.data['data']?['data'] ?? [];
        for (var ltJson in ltData) {
          finalLandTenures.add({'id': ltJson['id'], 'name': ltJson['name']});
        }
      } catch (e) {
        print('Error fetching land tenures: $e');
      }

      // 9. fetch application types
      List<Map<String, dynamic>> finalApplicationTypes = [];
      List<Map<String, dynamic>> finalFormTypes = [];
      try {
        final appResponse = await clientApiClient.dio.get(
          ApiConstants.applicationTypes,
        );
        List<dynamic> appData = appResponse.data['data']?['data'] ?? [];

        for (var appJson in appData) {
          final applicationTypeSlug = appJson['slug'];

          finalApplicationTypes.add({
            'id': appJson['id'],
            'name': appJson['name'],
            'slug': appJson['slug'],
          });

          // fetch formtypes for every application type

          try {
            final ftResponse = await clientApiClient.dio.get(
              '${ApiConstants.formTypes}?slug=$applicationTypeSlug',
            );
            List<dynamic> ftData = ftResponse.data['data']?['data'] ?? [];
            for (var ftJson in ftData) {
              finalFormTypes.add({'id': ftJson['id'], 'name': ftJson['name'], 'application_type_slug': applicationTypeSlug});
            }
          } catch (e) {
            print('Error fetching form types: $e');
          }
        }
      } catch (e) {
        print('Error fetching application types: $e');
      }

      // 10. fetch building operations
      List<Map<String, dynamic>> finalBuildingOperations = [];
      try {
        final boResponse = await clientApiClient.dio.get(
          ApiConstants.buildingOperations,
        );
        List<dynamic> boData = boResponse.data['data']?['data'] ?? [];
        for (var boJson in boData) {
          finalBuildingOperations.add({
            'id': boJson['id'],
            'name': boJson['name'],
          });
        }
      } catch (e) {
        print('Error fetching building operations: $e');
      }

      // 11. fetch inspection types
      List<Map<String, dynamic>> finalInspectionTypes = [];
      try {
        final itResponse = await bcoApiClient.dio.get(
          ApiConstants.inspectionTypes,
        );
        List<dynamic> itData = itResponse.data['data']?['data'] ?? [];
        for (var itJson in itData) {
          finalInspectionTypes.add({
            'id': itJson['id'],
            'name': itJson['name'],
          });
        }
      } catch (e) {
        print('Error fetching inspection types: $e');
      }

      // 12. fetch inpection statuses
      List<Map<String, dynamic>> finalInspectionStatuses = [];
      try {
        final itResponse = await bcoApiClient.dio.get(
          ApiConstants.inspectionStatuses,
        );
        List<dynamic> itData = itResponse.data['data']?['data'] ?? [];
        for (var itJson in itData) {
          finalInspectionStatuses.add({
            'id': itJson['id'],
            'name': itJson['name'],
          });
        }
      } catch (e) {
        print('Error fetching inspection statuses: $e');
      }

      // Save to Hive
      await _box.put('admin_unit_types', jsonEncode(finalAdminUnitTypes));
      await _box.put('admin_units', jsonEncode(finalAdminUnits));
      await _box.put('user_roles', jsonEncode(finalUserRoles));
      await _box.put(
        'building_classifications',
        jsonEncode(finalBuildingClassifications),
      );
      await _box.put('eps_types', jsonEncode(finalEpsTypes));
      await _box.put('wb_categories', jsonEncode(finalWbCategories));
      await _box.put('building_purposes', jsonEncode(finalBuildingPurposes));
      await _box.put('land_tenures', jsonEncode(finalLandTenures));
      await _box.put('application_types', jsonEncode(finalApplicationTypes));
      await _box.put('form_types', jsonEncode(finalFormTypes));
      await _box.put(
        'building_operations',
        jsonEncode(finalBuildingOperations),
      );
      await _box.put('inspection_types', jsonEncode(finalInspectionTypes));
      await _box.put(
        'inspection_statuses',
        jsonEncode(finalInspectionStatuses),
      );
      await _box.put('last_sync_timestamp', DateTime.now().toIso8601String());

      // print('Successfully synchronized auxiliary data.');
    } catch (e) {
      // print('Error during auxiliary data synchronization: $e');
    }
  }

  List<AdminUnitType> getAdminUnitTypes() {
    final data = _box.get('admin_unit_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => AdminUnitType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<AdminUnit> getAdminUnits(int typeId) {
    final data = _box.get('admin_units');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      final allUnits = decoded
          .map((e) => AdminUnit.fromJsonFull(e as Map<String, dynamic>))
          .toList();
      return allUnits.where((unit) => unit.typeId == typeId).toList();
    } catch (e) {
      return [];
    }
  }

  List<AdminUnit> getAllAdminUnits() {
    final data = _box.get('admin_units');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => AdminUnit.fromJsonFull(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<UserRole> getUserRoles() {
    final data = _box.get('user_roles');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => UserRole.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<BuildingClassification> getBuildingClassifications() {
    final data = _box.get('building_classifications');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map(
            (e) => BuildingClassification.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<ExpressPenaltyOffenceType> getExpressPenaltyOffenceTypes() {
    final data = _box.get('eps_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map(
            (e) =>
                ExpressPenaltyOffenceType.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<WhistleBlowerCategory> getWhistleBlowerCategories() {
    final data = _box.get('wb_categories');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => WhistleBlowerCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<BuildingPurpose> getBuildingPurposes() {
    final data = _box.get('building_purposes');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => BuildingPurpose.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<LandTenure> getLandTenures() {
    final data = _box.get('land_tenures');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => LandTenure.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<ApplicationType> getApplicationTypes() {
    final data = _box.get('application_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => ApplicationType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<FormType> getFormTypes(String applicationSlug) {
    final data = _box.get('form_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      final allFormTypes = decoded
          .map((e) => FormType.fromJsonFull(e as Map<String, dynamic>))
          .toList();
      return allFormTypes
          .where((ft) => ft.applicationTypeSlug == applicationSlug)
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<FormType> getAllFormTypes() {
    final data = _box.get('form_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => FormType.fromJsonFull(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<BuildingOperation> getBuildingOperations() {
    final data = _box.get('building_operations');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => BuildingOperation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<InspectionType> getInspectionTypes() {
    final data = _box.get('inspection_types');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => InspectionType.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<InspectionStatus> getInspectionStatuses() {
    final data = _box.get('inspection_statuses');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((e) => InspectionStatus.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
