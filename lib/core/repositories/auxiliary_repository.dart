import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../network/bco_api_client.dart';
import '../constants/api_constants.dart';
import '../models/auxiliary/admin_unit_type.dart';
import '../models/auxiliary/admin_unit.dart';
import '../models/auxiliary/user_role.dart';
import '../models/auxiliary/building_classification.dart';
import '../models/auxiliary/express_penalty_offence_type.dart';

class AuxiliaryRepository {
  final BcoApiClient bcoApiClient;
  static const String _boxName = 'auxiliaryBox';

  AuxiliaryRepository({required this.bcoApiClient});

  Box get _box => Hive.box(_boxName);

  Future<void> syncAuxiliaryData() async {
    try {
      final lastSyncStr = _box.get('last_sync_timestamp');
      bool shouldSync = true;

      if (lastSyncStr != null) {
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

      // Save to Hive
      await _box.put('admin_unit_types', jsonEncode(finalAdminUnitTypes));
      await _box.put('admin_units', jsonEncode(finalAdminUnits));
      await _box.put('user_roles', jsonEncode(finalUserRoles));
      await _box.put(
        'building_classifications',
        jsonEncode(finalBuildingClassifications),
      );
      await _box.put('eps_types', jsonEncode(finalEpsTypes));
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
}
