import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cyberguard_xai/features/scanner/presentation/controllers/url_scanner_controller.dart';
import 'package:cyberguard_xai/features/scanner/presentation/views/url_scanner_screen.dart';

void main() {
  testWidgets('UrlScannerScreen renders input card and quick test signatures', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UrlScannerController()),
        ],
        child: const MaterialApp(
          home: UrlScannerScreen(),
        ),
      ),
    );

    expect(find.text('AI URL FORENSIC SCANNER'), findsOneWidget);
    expect(find.text('TARGET ENDPOINT / URL'), findsOneWidget);
    expect(find.text('ANALYZE WITH FORENSIC AI'), findsOneWidget);
    expect(find.text('QUICK TEST SIGNATURES (SAMPLE BENCHMARKS):'), findsOneWidget);
  });
}
