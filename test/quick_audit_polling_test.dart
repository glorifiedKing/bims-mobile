import 'package:flutter_test/flutter_test.dart';
import 'package:bims_mobile_general/features/professional/models/quick_audit_model.dart';

void main() {
  group('QuickAuditModel Polling and Processing Status Tests', () {
    test('isProcessing is true until status is completed or failed', () {
      final pendingAudit = QuickAuditModel(
        id: 'audit-1',
        status: 'pending',
        originalName: 'Drawings.pdf',
        discipline: 'architectural',
      );
      expect(pendingAudit.isProcessing, isTrue);
      expect(pendingAudit.isCompleted, isFalse);
      expect(pendingAudit.isFailed, isFalse);

      final processingAudit = QuickAuditModel(
        id: 'audit-2',
        status: 'processing',
        originalName: 'Drawings.pdf',
        discipline: 'architectural',
      );
      expect(processingAudit.isProcessing, isTrue);
      expect(processingAudit.isCompleted, isFalse);
      expect(processingAudit.isFailed, isFalse);

      final analyzingAudit = QuickAuditModel(
        id: 'audit-3',
        status: 'analyzing',
        originalName: 'Drawings.pdf',
        discipline: 'architectural',
      );
      expect(analyzingAudit.isProcessing, isTrue);
      expect(analyzingAudit.isCompleted, isFalse);
      expect(analyzingAudit.isFailed, isFalse);

      final completedAudit = QuickAuditModel(
        id: 'audit-4',
        status: 'completed',
        originalName: 'Drawings.pdf',
        discipline: 'architectural',
      );
      expect(completedAudit.isProcessing, isFalse);
      expect(completedAudit.isCompleted, isTrue);
      expect(completedAudit.isFailed, isFalse);

      final failedAudit = QuickAuditModel(
        id: 'audit-5',
        status: 'failed',
        originalName: 'Drawings.pdf',
        discipline: 'architectural',
      );
      expect(failedAudit.isProcessing, isFalse);
      expect(failedAudit.isCompleted, isFalse);
      expect(failedAudit.isFailed, isTrue);
    });

    test('fromJson correctly sets status and isProcessing', () {
      final jsonPending = {
        'id': 'audit-123',
        'status': 'PENDING',
        'original_name': 'Sample.pdf',
        'discipline': 'structural',
      };
      final modelPending = QuickAuditModel.fromJson(jsonPending);
      expect(modelPending.status, 'pending');
      expect(modelPending.isProcessing, isTrue);
      expect(modelPending.isCompleted, isFalse);

      final jsonCompleted = {
        'id': 'audit-124',
        'status': 'completed',
        'original_name': 'Sample.pdf',
        'discipline': 'structural',
        'overall_status': 'PASS',
        'gross_floor_area_sqm': 500.0,
      };
      final modelCompleted = QuickAuditModel.fromJson(jsonCompleted);
      expect(modelCompleted.status, 'completed');
      expect(modelCompleted.isProcessing, isFalse);
      expect(modelCompleted.isCompleted, isTrue);
    });
  });
}
