import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bims_mobile_general/features/professional/models/quick_audit_model.dart';
import 'package:bims_mobile_general/features/professional/screens/quick_audits/floor_area_details_sheet.dart';

void main() {
  group('Floor Area Metrics Model Tests', () {
    final sampleJson = {
      'quick_audit_id': 'audit-test-123',
      'status': 'completed',
      'overall_status': 'PASS',
      'original_name': 'Commercial Complex Drawings.pdf',
      'discipline': 'architectural',
      'occupancy_class': 'Class B (Commercial & Offices)',
      'gross_floor_area_sqm': 1880.0,
      'estimated_statutory_fee_ugx': 2820000.0,
      'floor_area_metrics': {
        'floors': [
          {
            'page': 2,
            'floor_name': 'Basement Floor',
            'room_breakdown': [
              {'name': '[Basement Floor] Kitchen', 'area_sqm': null},
              {'name': '[Basement Floor] Cafeteria', 'area_sqm': null},
              {'name': '[Basement Floor] Storage', 'area_sqm': null},
              {'name': '[Basement Floor] Power Room', 'area_sqm': null},
            ],
            'gross_floor_area_sqm': 415,
            'net_internal_area_sqm': null,
          },
          {
            'page': 3,
            'floor_name': 'Ground Floor',
            'room_breakdown': [
              {'name': '[Ground Floor] Outdoor Dining', 'area_sqm': null},
              {'name': '[Ground Floor] Kitchen', 'area_sqm': null},
              {'name': '[Ground Floor] Staff Toilets', 'area_sqm': null},
              {'name': '[Ground Floor] Garbage Collection', 'area_sqm': null},
            ],
            'gross_floor_area_sqm': 405,
            'net_internal_area_sqm': null,
          },
          {
            'page': 4,
            'floor_name': 'First Floor',
            'room_breakdown': [
              {'name': '[First Floor] Flip Lounge', 'area_sqm': null},
              {'name': '[First Floor] Smoking Lounge', 'area_sqm': null},
              {'name': '[First Floor] Ladies', 'area_sqm': null},
              {'name': '[First Floor] Gents', 'area_sqm': null},
              {'name': '[First Floor] Lift', 'area_sqm': null},
            ],
            'gross_floor_area_sqm': 720,
            'net_internal_area_sqm': null,
          },
          {
            'page': 5,
            'floor_name': 'Roof Terrace',
            'room_breakdown': [
              {'name': '[Roof Terrace] Roof Terrace', 'area_sqm': 340},
            ],
            'gross_floor_area_sqm': 340,
            'net_internal_area_sqm': null,
          },
        ],
        'source': 'multimodal_multi_floor_cumulation',
        'is_floor_plan': true,
        'room_breakdown': [
          {'name': '[Basement Floor] Kitchen', 'area_sqm': null},
          {'name': '[Roof Terrace] Roof Terrace', 'area_sqm': 340},
        ],
        'confidence_score': 0.95,
        'gross_floor_area_sqm': 1880,
        'net_internal_area_sqm': null,
        'cumulated_floors_count': 4,
      },
    };

    test('QuickAuditModel correctly deserializes floor_area_metrics', () {
      final audit = QuickAuditModel.fromJson(sampleJson);

      expect(audit.id, 'audit-test-123');
      expect(audit.grossFloorAreaSqm, 1880.0);
      expect(audit.hasFloorAreaDetails, true);
      expect(audit.floorAreaMetrics, isNotNull);

      final metrics = audit.floorAreaMetrics!;
      expect(metrics.isFloorPlan, true);
      expect(metrics.cumulatedFloorsCount, 4);
      expect(metrics.confidenceScore, 0.95);
      expect(metrics.source, 'multimodal_multi_floor_cumulation');
      expect(metrics.floors.length, 4);

      // Verify Floor 1: Basement
      final basement = metrics.floors[0];
      expect(basement.floorName, 'Basement Floor');
      expect(basement.page, 2);
      expect(basement.grossFloorAreaSqm, 415.0);
      expect(basement.roomBreakdown.length, 4);
      expect(basement.roomBreakdown[0].cleanName, 'Kitchen');

      // Verify Floor 4: Roof Terrace
      final roof = metrics.floors[3];
      expect(roof.floorName, 'Roof Terrace');
      expect(roof.page, 5);
      expect(roof.grossFloorAreaSqm, 340.0);
      expect(roof.roomBreakdown[0].areaSqm, 340.0);
      expect(roof.roomBreakdown[0].cleanName, 'Roof Terrace');
    });

    testWidgets('FloorAreaDetailsSheet renders floor breakdown and rooms', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final audit = QuickAuditModel.fromJson(sampleJson);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => FloorAreaDetailsSheet.show(context, audit),
                  child: const Text('Open Details'),
                );
              },
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();

      // Verify Header & GFA
      expect(find.text('Gross Floor Area Schedule'), findsOneWidget);
      expect(find.text('1,880'), findsOneWidget);
      expect(find.text('4 Levels'), findsOneWidget);

      // Verify individual floor names
      expect(find.text('Basement Floor'), findsOneWidget);
      expect(find.text('Ground Floor'), findsOneWidget);
      expect(find.text('First Floor'), findsOneWidget);
      expect(find.text('Roof Terrace'), findsWidgets);

      // Verify area values
      expect(find.text('415 m²'), findsOneWidget);
      expect(find.text('405 m²'), findsOneWidget);
      expect(find.text('720 m²'), findsOneWidget);
      expect(find.text('340 m²'), findsWidgets);

      // Verify sheet page tags
      expect(find.text('Sheet P.2'), findsOneWidget);
      expect(find.text('Sheet P.3'), findsOneWidget);
      expect(find.text('Sheet P.4'), findsOneWidget);
      expect(find.text('Sheet P.5'), findsOneWidget);
    });
  });
}
