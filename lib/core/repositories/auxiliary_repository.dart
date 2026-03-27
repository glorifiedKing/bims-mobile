import 'dart:convert';
import 'package:hive/hive.dart';
import '../network/bco_api_client.dart';
import '../constants/api_constants.dart';
import '../models/auxiliary/admin_unit_type.dart';
import '../models/auxiliary/admin_unit.dart';
import '../models/auxiliary/user_role.dart';

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
      final typesResponse = await bcoApiClient.dio.get(ApiConstants.adminUnitTypes);
      List<dynamic> typesData = typesResponse.data['data']?['data'] ?? [];
      
      List<Map<String, dynamic>> finalAdminUnitTypes = [];
      List<Map<String, dynamic>> finalAdminUnits = [];
      
      for (var typeJson in typesData) {
        final typeId = typeJson['id'];
        finalAdminUnitTypes.add({'id': typeId, 'name': typeJson['name']});
        
        // 2. Fetch Admin Units for this type
        try {
          final unitsResponse = await bcoApiClient.dio.get('${ApiConstants.adminUnitsList}?type=$typeId');
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
        final rolesResponse = await bcoApiClient.dio.get(ApiConstants.userRoles);
        List<dynamic> rolesData = rolesResponse.data['data']?['data'] ?? [];
        for (var roleJson in rolesData) {
          finalUserRoles.add({
            'id': roleJson['id'],
            'name': roleJson['name'],
          });
        }
      } catch (e) {
        // print('Error fetching user roles: $e');
      }

      // Save to Hive
      await _box.put('admin_unit_types', jsonEncode(finalAdminUnitTypes));
      await _box.put('admin_units', jsonEncode(finalAdminUnits));
      await _box.put('user_roles', jsonEncode(finalUserRoles));
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
      return decoded.map((e) => AdminUnitType.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  List<AdminUnit> getAdminUnits(int typeId) {
    final data = _box.get('admin_units');
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(data);
      final allUnits = decoded.map((e) => AdminUnit.fromJsonFull(e as Map<String, dynamic>)).toList();
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
      return decoded.map((e) => AdminUnit.fromJsonFull(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  List<UserRole> getUserRoles() {
    final data = _box.get('user_roles');
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => UserRole.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}
