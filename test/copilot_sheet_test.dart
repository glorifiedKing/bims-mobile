import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bims_mobile_general/core/theme.dart';
import 'package:bims_mobile_general/features/professional/screens/copilot/professional_copilot_sheet.dart';
import 'package:bims_mobile_general/features/professional/models/copilot_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  testWidgets('ProfessionalCopilotSheet renders welcome and complex markdown properly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ProfessionalCopilotSheet(
            initialContextTitle: 'Floor Plan Review',
            initialContextDescription: 'Architectural compliance check',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check header and persona
    expect(find.text('Interactive AI Copilot'), findsOneWidget);
    expect(find.text('Grounded on: Floor Plan Review'), findsOneWidget);
    expect(find.text('Architectural compliance check'), findsOneWidget);

    // Check welcome message markdown rendered
    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('Uganda Building Control Regulations'), findsOneWidget);

    // Switch persona to Eng. Kigozi and verify switch notification markdown renders
    final kigoziFinder = find.text('Eng. Kigozi');
    expect(kigoziFinder, findsOneWidget);
    await tester.tap(kigoziFinder);
    await tester.pumpAndSettle();

    // Now should have 2 MarkdownBody widgets (welcome message + switch message)
    expect(find.byType(MarkdownBody), findsNWidgets(2));
    expect(find.textContaining('Switched to'), findsOneWidget);
  });

  testWidgets('Markdown rendering displays complex markdown blocks without error', (tester) async {
    const complexMarkdown = '''
### 1. General Requirements
The building must conform to **Section 12** of the Uganda Building Code.

- *Item A*: Minimum ventilation ratio: `10%`
- *Item B*: Corridor clearance width: `1500mm`

| Section | Status | Notes |
| --- | --- | --- |
| Ventilation | Compliant | Cross-ventilation provided |
| Accessibility | Pending | Ramps required |

> Important note: Review by municipal BCO is required before permit issuance.
''';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SelectionArea(
            child: MarkdownBody(
              data: complexMarkdown,
              selectable: false,
              styleSheet: MarkdownStyleSheet.fromTheme(AppTheme.lightTheme),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('General Requirements'), findsOneWidget);
    expect(find.textContaining('Section 12'), findsOneWidget);
    expect(find.textContaining('1500mm'), findsOneWidget);
    expect(find.textContaining('Important note: Review by municipal BCO'), findsOneWidget);
  });
}
