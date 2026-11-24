import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bims_mobile_general/core/theme.dart';
import 'package:bims_mobile_general/features/professional/models/quick_audit_model.dart';
import 'package:bims_mobile_general/features/professional/screens/quick_audits/professional_quick_audit_result_screen.dart';

void main() {
  group('DiscrepancyModel Severity Parsing Tests', () {
    test('parses ERROR, WARNING, and INFO case-insensitively', () {
      final d1 = DiscrepancyModel.fromJson({'severity': 'ERROR'});
      expect(d1.severity, 'ERROR');

      final d2 = DiscrepancyModel.fromJson({'severity': 'error'});
      expect(d2.severity, 'ERROR');

      final d3 = DiscrepancyModel.fromJson({'severity': 'warning'});
      expect(d3.severity, 'WARNING');

      final d4 = DiscrepancyModel.fromJson({'severity': 'WARNING'});
      expect(d4.severity, 'WARNING');

      final d5 = DiscrepancyModel.fromJson({'severity': 'info'});
      expect(d5.severity, 'INFO');

      final d6 = DiscrepancyModel.fromJson({'severity': 'INFO'});
      expect(d6.severity, 'INFO');
    });

    test('normalizes HIGH/CRITICAL to ERROR, MEDIUM/WARN to WARNING, LOW to INFO', () {
      expect(DiscrepancyModel.fromJson({'severity': 'high'}).severity, 'ERROR');
      expect(DiscrepancyModel.fromJson({'severity': 'CRITICAL'}).severity, 'ERROR');
      expect(DiscrepancyModel.fromJson({'severity': 'medium'}).severity, 'WARNING');
      expect(DiscrepancyModel.fromJson({'severity': 'warn'}).severity, 'WARNING');
      expect(DiscrepancyModel.fromJson({'severity': 'low'}).severity, 'INFO');
    });

    test('defaults to ERROR when severity is null or empty', () {
      expect(DiscrepancyModel.fromJson({}).severity, 'ERROR');
    });
  });

  group('ProfessionalQuickAuditResultScreen Discrepancy Colors Tests', () {
    testWidgets('renders ERROR, WARNING, and INFO discrepancies with distinct sevColors',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleAudit = QuickAuditModel(
        id: 'audit-test-colors',
        status: 'completed',
        originalName: 'Commercial_Plan.pdf',
        discipline: 'architectural',
        discrepancies: [
          DiscrepancyModel(
            ruleName: 'Fire Exit Clearance',
            clauseReference: 'Part 4.2',
            severity: 'ERROR',
            description: 'Fire exit corridor width 850mm is below minimum required 1200mm.',
          ),
          DiscrepancyModel(
            ruleName: 'Natural Ventilation Ratio',
            clauseReference: 'Part 6.1',
            severity: 'WARNING',
            description: 'Habitable room window area is slightly below 10% floor area guideline.',
          ),
          DiscrepancyModel(
            ruleName: 'Accessible Ramp Slope',
            clauseReference: 'Part 8.4',
            severity: 'INFO',
            description: 'Tactile paving recommended at ramp landing transition.',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProfessionalQuickAuditResultScreen(
            auditId: 'audit-test-colors',
            initialAudit: sampleAudit,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Find the severity badge texts
      final errorBadge = find.text('ERROR');
      final warningBadge = find.text('WARNING');
      final infoBadge = find.text('INFO');

      expect(errorBadge, findsOneWidget);
      expect(warningBadge, findsOneWidget);
      expect(infoBadge, findsOneWidget);

      // Verify the Text color for ERROR is danger (red)
      final Text errorTextWidget = tester.widget(errorBadge);
      expect(errorTextWidget.style?.color, AppTheme.danger);

      // Verify the Text color for WARNING is orange
      final Text warningTextWidget = tester.widget(warningBadge);
      expect(warningTextWidget.style?.color, Colors.orange.shade800);

      // Verify the Text color for INFO is blue
      final Text infoTextWidget = tester.widget(infoBadge);
      expect(infoTextWidget.style?.color, Colors.blue.shade700);

      // Verify the distinct icons for each severity
      expect(find.byIcon(Icons.error_outline), findsWidgets);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
