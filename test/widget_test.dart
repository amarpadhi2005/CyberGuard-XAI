import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cyberguard_xai/core/widgets/cyber_button.dart';
import 'package:cyberguard_xai/core/widgets/cyber_loading_indicator.dart';

void main() {
  testWidgets('CyberButton renders and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CyberButton(
            text: 'INITIALIZE DEFENSE',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('INITIALIZE DEFENSE'), findsOneWidget);
    await tester.tap(find.text('INITIALIZE DEFENSE'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('CyberLoadingIndicator renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CyberLoadingIndicator(
            statusText: 'SCANNING THREATS',
          ),
        ),
      ),
    );

    expect(find.text('SCANNING THREATS'), findsOneWidget);
  });
}
