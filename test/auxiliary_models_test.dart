import 'package:flutter_test/flutter_test.dart';
import 'package:bims_mobile_general/core/models/auxiliary/admin_unit.dart';
import 'package:bims_mobile_general/core/models/auxiliary/admin_unit_type.dart';
import 'package:bims_mobile_general/core/models/auxiliary/form_type.dart';
import 'package:bims_mobile_general/core/models/auxiliary/application_type.dart';
import 'package:bims_mobile_general/core/models/auxiliary/building_operation.dart';
import 'package:bims_mobile_general/core/models/auxiliary/building_purpose.dart';
import 'package:bims_mobile_general/core/models/auxiliary/land_tenures.dart';
import 'package:bims_mobile_general/core/models/auxiliary/express_penalty_offence_type.dart';
import 'package:bims_mobile_general/core/models/auxiliary/payment_mode.dart';

void main() {
  group('Auxiliary Models Deserialization Tests', () {
    test('AdminUnit handles null and string districtId safely', () {
      // Case 1: districtId is null (as in Town Council #501)
      final jsonWithNullDistrict = {
        'id': 501,
        'name': 'BUTARE KATOJO TC',
        'typeId': 4,
        'districtId': null,
      };
      final unit1 = AdminUnit.fromJsonFull(jsonWithNullDistrict);
      expect(unit1.id, 501);
      expect(unit1.name, 'BUTARE KATOJO TC');
      expect(unit1.typeId, 4);
      expect(unit1.districtId, '');

      // Case 2: districtId is a string
      final jsonWithStringDistrict = {
        'id': 1,
        'name': 'Kampala',
        'typeId': 1,
        'districtId': '2',
      };
      final unit2 = AdminUnit.fromJsonFull(jsonWithStringDistrict);
      expect(unit2.id, 1);
      expect(unit2.districtId, '2');

      // Case 3: dID fallback and string id
      final jsonWithDid = {
        'id': '10',
        'name': 'Entebbe',
        'dID': 134,
      };
      final unit3 = AdminUnit.fromJson(jsonWithDid, 2);
      expect(unit3.id, 10);
      expect(unit3.districtId, '134');
    });

    test('FormType handles integer and string application_type_slug safely', () {
      // Backend returns integer slug in some responses (e.g. 4331)
      final jsonWithIntSlug = {
        'id': 1,
        'name': 'Class C Form',
        'application_type_slug': 4331,
      };
      final ft1 = FormType.fromJsonFull(jsonWithIntSlug);
      expect(ft1.id, 1);
      expect(ft1.name, 'Class C Form');
      expect(ft1.applicationTypeSlug, '4331');

      // String slug
      final jsonWithStringSlug = {
        'id': 2,
        'name': 'Class A Form',
        'application_type_slug': '4331',
      };
      final ft2 = FormType.fromJsonFull(jsonWithStringSlug);
      expect(ft2.id, 2);
      expect(ft2.applicationTypeSlug, '4331');
    });

    test('ApplicationType handles non-string slug safely', () {
      final json = {
        'id': 1,
        'name': 'Building Permit Application',
        'slug': 4331,
      };
      final app = ApplicationType.fromJson(json);
      expect(app.id, 1);
      expect(app.slug, '4331');
    });

    test('BuildingOperation, BuildingPurpose, LandTenure parse string/int ids', () {
      final bo = BuildingOperation.fromJson({'id': '3', 'name': 'Demolition'});
      expect(bo.id, 3);
      expect(bo.name, 'Demolition');

      final bp = BuildingPurpose.fromJson({'id': 1, 'name': 'Residential'});
      expect(bp.id, 1);

      final lt = LandTenure.fromJson({'id': '2', 'name': 'Freehold'});
      expect(lt.id, 2);
    });

    test('ExpressPenaltyOffenceType parses various boolean/string flags', () {
      final eps = ExpressPenaltyOffenceType.fromJson({
        'id': 1,
        'enactment': 'Sec 33',
        'offence_name': 'No permit',
        'currency_points': '2',
        'charge_per_sqm': 1,
      });
      expect(eps.id, 1);
      expect(eps.currencyPoints, 2);
      expect(eps.chargePerSqm, true);
    });
  });
}
