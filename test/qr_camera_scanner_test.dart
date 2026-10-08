import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cyberguard_xai/features/qr_scanner/domain/entities/qr_camera_permission_state.dart';
import 'package:cyberguard_xai/features/qr_scanner/domain/entities/qr_payload_info.dart';
import 'package:cyberguard_xai/features/qr_scanner/presentation/controllers/qr_scanner_controller.dart';
import 'package:cyberguard_xai/features/qr_scanner/presentation/views/qr_scanner_screen.dart';
import 'package:cyberguard_xai/features/qr_scanner/presentation/widgets/qr_security_result_sheet.dart';
import 'package:cyberguard_xai/features/scanner/domain/entities/url_scan_result.dart';
import 'package:cyberguard_xai/features/scanner/domain/repositories/url_scanner_repository.dart';

class MockUrlScannerRepository implements UrlScannerRepository {
  String? lastScannedUrl;
  UrlScanResult? stubResult;

  @override
  Future<UrlScanResult> scanUrl(String url, {bool isQuickTest = false}) async {
    lastScannedUrl = url;
    if (stubResult != null) return stubResult!;

    final isSuspicious = url.contains('login') || url.contains('phish');
    return UrlScanResult(
      originalUrl: url,
      defangedUrl: url.replaceAll('https://', 'hxxps://').replaceAll('.', '[.]'),
      domain: 'example.com',
      protocol: 'https',
      path: '/login',
      query: '',
      riskScore: isSuspicious ? 87 : 5,
      threatLevel: isSuspicious ? ThreatLevel.critical : ThreatLevel.safe,
      confidence: 95,
      summary: isSuspicious
          ? 'Credential harvesting indicators and deceptive login paths detected.'
          : 'Verified nominal reputation.',
      recommendedAction: isSuspicious ? 'Do not visit this URL.' : 'Safe to proceed.',
      isHttps: true,
      httpsMeaning: 'HTTPS encrypts the connection but does not prove that the website is legitimate.',
      indicators: isSuspicious
          ? const [
              UrlThreatIndicator(
                name: 'Credential Harvesting Pattern',
                severity: IndicatorSeverity.critical,
                evidence: 'Login keyword and password input indicators present.',
                explanation: 'Observed targeting account credentials.',
              ),
              UrlThreatIndicator(
                name: 'Suspicious Domain',
                severity: IndicatorSeverity.high,
                evidence: 'Unverified brand registration telemetry.',
                explanation: 'Potential typosquatting impersonation.',
              ),
            ]
          : const [],
      scannedAt: DateTime.now(),
    );
  }

  @override
  Future<List<UrlScanResult>> getRecentScans() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 5, 8, 10, 11 — QR Payload Parsing & URL Extraction', () {
    test('TEST 1: QR containing standard URL extracts and normalizes URL safely', () {
      final payload = QrPayloadInfo.parse('https://google.com');

      expect(payload.isUrl, isTrue);
      expect(payload.payloadType, equals(QrPayloadType.url));
      expect(payload.originalUrl, equals('https://google.com/'));
      expect(payload.defangedUrl, equals('hxxps://google[.]com/'));
      expect(payload.displayContent, equals('hxxps://google[.]com/'));
    });

    test('TEST 2: QR containing login path preserves exact destination without corruption', () {
      const exactInput = 'https://example.com/login';
      final payload = QrPayloadInfo.parse(exactInput);

      expect(payload.isUrl, isTrue);
      expect(payload.originalUrl, equals('https://example.com/login'));
      expect(payload.defangedUrl, equals('hxxps://example[.]com/login'));
      // Ensure originalUrl is NEVER overwritten with defangedUrl
      expect(payload.originalUrl, isNot(equals(payload.defangedUrl)));
      // Ensure no malformed double scheme like https://hxxp://
      expect(payload.defangedUrl, isNot(contains('https://hxxp://')));
    });

    test('TEST 3: QR containing plain text HELLO CYBERGUARD is not treated as a URL', () {
      final payload = QrPayloadInfo.parse('HELLO CYBERGUARD');

      expect(payload.isUrl, isFalse);
      expect(payload.payloadType, equals(QrPayloadType.plainText));
      expect(payload.displayContent, equals('HELLO CYBERGUARD'));
      expect(payload.originalUrl, isNull);
    });

    test('Non-URL protocols (WIFI, tel, mailto, javascript) handled safely without execution', () {
      final wifi = QrPayloadInfo.parse('WIFI:T:WPA;S:Network;P:password;;');
      expect(wifi.isUrl, isFalse);
      expect(wifi.payloadType, equals(QrPayloadType.wifi));

      final tel = QrPayloadInfo.parse('tel:+123456789');
      expect(tel.isUrl, isFalse);
      expect(tel.payloadType, equals(QrPayloadType.tel));

      final mailto = QrPayloadInfo.parse('mailto:analyst@cyberguard.internal');
      expect(mailto.isUrl, isFalse);
      expect(mailto.payloadType, equals(QrPayloadType.mailto));

      final js = QrPayloadInfo.parse('javascript:alert(1)');
      expect(js.isUrl, isFalse);
      expect(js.payloadType, equals(QrPayloadType.unsupportedProtocol));
    });
  });

  group('Requirement 6 & 9 — Duplicate Scan Lock & Security Pipeline Integration', () {
    test('TEST 6: Scanning lock prevents duplicate processing across consecutive camera frames', () {
      final mockRepo = MockUrlScannerRepository();
      final controller = QrScannerController(urlRepository: mockRepo);

      int detectedCallbacks = 0;

      // Frame 1
      controller.onBarcodeDetected(
        'https://test-site.org/verify',
        onDetected: (_) => detectedCallbacks++,
      );

      expect(detectedCallbacks, equals(1));
      expect(controller.isProcessingQr, isTrue);

      // Frame 2 (identical or subsequent frame before user taps Scan Another)
      controller.onBarcodeDetected(
        'https://test-site.org/verify',
        onDetected: (_) => detectedCallbacks++,
      );

      // Callback count must NOT increment
      expect(detectedCallbacks, equals(1));

      // After user taps "Scan Another", lock resets
      controller.resumeScanning();
      expect(controller.isProcessingQr, isFalse);

      // Frame 3 succeeds
      controller.onBarcodeDetected(
        'https://second-site.org',
        onDetected: (_) => detectedCallbacks++,
      );
      expect(detectedCallbacks, equals(2));
    });

    test('TEST 9 & 10: Suspicious QR URL dispatches exact URL and verifies HTTPS truth', () async {
      final mockRepo = MockUrlScannerRepository();
      final controller = QrScannerController(urlRepository: mockRepo);

      controller.onBarcodeDetected(
        'https://secure-chase-update.net/login',
        onDetected: (_) {},
      );

      expect(controller.detectedPayload, isNotNull);
      final success = await controller.analyzeDetectedPayload();

      expect(success, isTrue);
      expect(mockRepo.lastScannedUrl, equals('https://secure-chase-update.net/login'));
      expect(controller.securityResult, isNotNull);
      expect(controller.securityResult!.riskScore, equals(87));
      expect(controller.securityResult!.threatLevel, equals(ThreatLevel.critical));
      expect(controller.securityResult!.isHttps, isTrue);
      expect(
        controller.securityResult!.httpsMeaning,
        equals('HTTPS encrypts the connection but does not prove that the website is legitimate.'),
      );
    });
  });

  group('Requirement 2, 3, 12, 13, 17, 18 — UI & Permission State Tests', () {
    testWidgets('TEST 4: Camera permission explanation card displays correct wording and actions', (tester) async {
      final controller = QrScannerController();
      controller.setPermissionStateForTest(QrCameraPermissionState.promptExplanation);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<QrScannerController>.value(
            value: controller,
            child: const QrScannerScreen(autoCheckPermission: false),
          ),
        ),
      );

      await tester.pump();

      // Verify explanation prompt widgets
      expect(find.text('Camera Access Required'), findsOneWidget);
      expect(
        find.text('Camera access is required to scan QR codes and check their destinations for potential security threats.'),
        findsOneWidget,
      );
      expect(find.text('CONTINUE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('TEST 5: Permanently denied permission renders Open App Settings', (tester) async {
      final controller = QrScannerController();
      controller.setPermissionStateForTest(QrCameraPermissionState.permanentlyDenied);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<QrScannerController>.value(
            value: controller,
            child: const QrScannerScreen(autoCheckPermission: false),
          ),
        ),
      );

      await tester.pump();

      // Check permanently denied card (Requirement 3)
      expect(find.text('Camera Permission Disabled'), findsOneWidget);
      expect(
        find.text('Camera permission is disabled for CyberGuard. Please enable it in Android system settings to continue scanning.'),
        findsOneWidget,
      );
      expect(find.text('OPEN APP SETTINGS'), findsOneWidget);
    });

    testWidgets('TEST 17 & 18: Camera hardware error renders neutral CAMERA ERROR with no fake perimeter breach', (tester) async {
      final controller = QrScannerController();
      controller.setCameraError('Camera in use by another process');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<QrScannerController>.value(
            value: controller,
            child: const QrScannerScreen(autoCheckPermission: false),
          ),
        ),
      );

      await tester.pump();

      // Check camera error card (Requirement 17 & 18)
      expect(find.text('CAMERA ERROR'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
      expect(find.text('BACK'), findsOneWidget);
      // Ensure NO fake military security threat wording is present
      expect(find.text('PERIMETER ISOLATION ACTIVE'), findsNothing);
      expect(find.text('runtime shields'), findsNothing);
    });

    testWidgets('TEST 12 & 13: QrSecurityResultSheet displays risk metrics, indicators and HTTPS warning', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleResult = UrlScanResult(
        originalUrl: 'https://paypal-verify-alert.com/login',
        defangedUrl: 'hxxps://paypal-verify-alert[.]com/login',
        domain: 'paypal-verify-alert.com',
        protocol: 'https',
        path: '/login',
        query: '',
        riskScore: 87,
        threatLevel: ThreatLevel.critical,
        confidence: 95,
        summary: 'Credential harvesting pattern and suspicious domain spoof detected.',
        recommendedAction: 'Do not open this destination.',
        isHttps: true,
        httpsMeaning: 'HTTPS encrypts the connection but does not prove that the website is legitimate.',
        indicators: const [
          UrlThreatIndicator(
            name: 'Credential harvesting pattern',
            severity: IndicatorSeverity.critical,
            evidence: 'Password input telemetry',
            explanation: 'Targets account credentials.',
          ),
          UrlThreatIndicator(
            name: 'Suspicious domain',
            severity: IndicatorSeverity.high,
            evidence: 'Newly observed hostname',
            explanation: 'Potential brand impersonation.',
          ),
        ],
        scannedAt: DateTime.now(),
      );

      bool scanAnotherTapped = false;
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrSecurityResultSheet(
              result: sampleResult,
              onScanAnother: () => scanAnotherTapped = true,
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('QR SECURITY RESULT'), findsOneWidget);
      expect(find.text('QR CODE: Detected ✓'), findsOneWidget);
      expect(find.text('hxxps://paypal-verify-alert[.]com/login'), findsOneWidget);
      expect(find.text('87 / 100'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('✓ HTTPS connection detected'), findsOneWidget);
      expect(
        find.text('HTTPS encrypts the connection but does not prove that the website is legitimate.'),
        findsOneWidget,
      );
      expect(find.text('Credential harvesting pattern'), findsOneWidget);
      expect(find.text('Do not open this destination.'), findsOneWidget);

      await tester.tap(find.text('SCAN ANOTHER QR'));
      expect(scanAnotherTapped, isTrue);

      await tester.tap(find.text('BACK'));
      expect(backTapped, isTrue);
    });
  });

}
