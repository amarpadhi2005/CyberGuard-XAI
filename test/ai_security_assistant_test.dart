import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cyberguard_xai/core/security/central_risk_engine.dart';
import 'package:cyberguard_xai/core/security/tool_dispatcher.dart';
import 'package:cyberguard_xai/core/security/file_inspector_service.dart';
import 'package:cyberguard_xai/core/security/device_security_service.dart';
import 'package:cyberguard_xai/features/assistant/data/services/gemini_assistant_service.dart';
import 'package:cyberguard_xai/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:cyberguard_xai/features/assistant/domain/entities/chat_message.dart';
import 'package:cyberguard_xai/features/assistant/presentation/controllers/assistant_controller.dart';

void main() {
  group('1. Central Risk Engine Tests', () {
    test('Evaluates low risk for benign indicators', () {
      final indicators = [
        const SecurityIndicator(
          indicator: 'Clean Domain Reputation',
          category: 'Reputation',
          severity: RiskSeverity.low,
          confidence: 95,
          evidence: 'Domain is well-established with no abuse complaints.',
          weight: 0.0,
        ),
      ];

      final assessment = CentralRiskEngine.evaluate(indicators);
      expect(assessment.riskScore, inInclusiveRange(0, 19));
      expect(assessment.severity, equals(RiskSeverity.low));
    });

    test('Computes critical risk band (80–100) for severe weighted threats', () {
      final indicators = [
        const SecurityIndicator(
          indicator: 'Credential Harvesting Pattern',
          category: 'Phishing',
          severity: RiskSeverity.critical,
          confidence: 98,
          evidence: 'Fake banking login path detected with zero SSL reputation.',
          weight: 12.0,
        ),
        const SecurityIndicator(
          indicator: 'Typosquatting Match',
          category: 'Domain Heuristics',
          severity: RiskSeverity.high,
          confidence: 90,
          evidence: 'Levenshtein distance match to chase.com.',
          weight: 8.0,
        ),
      ];

      final assessment = CentralRiskEngine.evaluate(indicators);
      expect(assessment.riskScore, inInclusiveRange(80, 100));
      expect(assessment.severity, equals(RiskSeverity.critical));
      expect(assessment.indicators, hasLength(2));
    });

    test('Band mapping adheres strictly to specifications', () {
      expect(RiskSeverity.fromScore(10), equals(RiskSeverity.low));
      expect(RiskSeverity.fromScore(25), equals(RiskSeverity.lowModerate));
      expect(RiskSeverity.fromScore(50), equals(RiskSeverity.medium));
      expect(RiskSeverity.fromScore(70), equals(RiskSeverity.high));
      expect(RiskSeverity.fromScore(90), equals(RiskSeverity.critical));
    });
  });

  group('2. Controlled Tool Dispatcher Tests', () {
    late SecurityToolDispatcher dispatcher;

    setUp(() {
      dispatcher = SecurityToolDispatcher();
    });

    test('Registers exactly 8 implemented security tools', () {
      expect(SecurityToolDispatcher.registeredTools.length, equals(8));
      expect(SecurityToolDispatcher.registeredTools, containsAll([
        'analyze_url',
        'scan_qr_code',
        'analyze_file',
        'get_device_security_status',
        'get_installed_apps',
        'check_domain_reputation',
        'calculate_risk_score',
        'generate_security_report',
      ]));
    });

    test('Rejects unregistered or fake tools immediately', () async {
      final result = await dispatcher.dispatch(toolName: 'unregistered_hack_tool');
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('is not registered'));
    });

    test('Captures execution duration and timeline steps', () async {
      final result = await dispatcher.dispatch(
        toolName: 'get_device_security_status',
      );
      expect(result.isSuccess, isTrue);
      expect(result.durationMs, isNonNegative);
      expect(result.timelineSteps, isNotEmpty);
      expect(result.assessment, isNotNull);
    });
  });

  group('3. Static File Inspector Tests (Zero Execution)', () {
    late FileInspectorService inspector;

    setUp(() {
      inspector = FileInspectorService();
    });

    test('Inspects APK bytes without executing code', () async {
      const dummyApkString = 'PK\x03\x04AndroidManifest.xml'
          'android.permission.RECEIVE_BOOT_COMPLETED'
          'android.permission.SEND_SMS'
          'android:debuggable="true"'
          'com.fake.trojan.BankingService';
      final apkBytes = Uint8List.fromList(utf8.encode(dummyApkString));

      final report = await inspector.analyzeFileBytes(bytes: apkBytes, fileName: 'fake_trojan.apk');
      expect(report.fileName, equals('fake_trojan.apk'));
      expect(report.sha256Hash, isNotEmpty);
      expect(report.sha256Hash.length, equals(64));
      expect(report.indicators, isNotEmpty);

      expect(report.indicators.any((i) => i.evidence.contains('SEND_SMS')), isTrue);
      expect(report.indicators.any((i) => i.indicator.contains('Debuggable')), isTrue);
    });

    test('Inspects PDF document for active content and URI actions', () async {
      const pdfContent = '%PDF-1.4 /Type /Action /S /JavaScript /JS (app.alert("xss")) /URI (http://malicious.ru)';
      final pdfBytes = Uint8List.fromList(utf8.encode(pdfContent));

      final report = await inspector.analyzeFileBytes(bytes: pdfBytes, fileName: 'invoice.pdf');
      expect(report.fileName, equals('invoice.pdf'));
      expect(report.indicators.any((i) => i.indicator.contains('JavaScript')), isTrue);
      expect(report.assessment.riskScore, greaterThan(0));
    });
  });

  group('4. Device Security Service Tests (Non-Intrusive)', () {
    test('Audits device security and uses permitted wording', () async {
      final service = DeviceSecurityService();
      final audit = await service.auditDeviceSecurity();

      expect(audit.deviceTelemetry, isNotEmpty);
      expect(audit.deviceTelemetry['platform'], isNotNull);

      // Crucial requirement: Never claim "Your device is virus free."
      expect(audit.complianceVerdict, isNot(contains('Your device is virus free')));
      expect(
        audit.complianceVerdict,
        contains('No threats were detected by the checks available to this application'),
      );
    });
  });

  group('5. Gemini Explanation Schema & Fallback Tests', () {
    late GeminiAssistantService geminiService;

    setUp(() {
      geminiService = GeminiAssistantService(apiKey: ''); // Will trigger local validation fallback
    });

    test('Enforces webpageInspected is always false', () async {
      final toolResult = ToolExecutionResult(
        toolName: 'analyze_url',
        isSuccess: true,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        durationMs: 12,
        evidence: [
          const SecurityIndicator(
            indicator: 'Phishing Keyword',
            category: 'URL Forensics',
            severity: RiskSeverity.high,
            confidence: 90,
            evidence: 'Contains credential reset lure',
            weight: 8.0,
          )
        ],
        assessment: RiskAssessmentResult(
          riskScore: 75,
          severity: RiskSeverity.high,
          confidence: 90,
          indicators: const [],
          calculatedAt: DateTime.now(),
        ),
        rawOutput: {'url': 'https://secure-login-chase.com'},
        timelineSteps: ['URL checked'],
      );

      final explanation = await geminiService.explainToolResult(
        toolResult: toolResult,
        userQuery: 'Is this URL safe?',
      );

      expect(explanation.webpageInspected, isFalse);
      expect(explanation.riskScore, equals(75));
      expect(explanation.riskLevel, equals(AssistantRiskLevel.high));
      expect(explanation.explanation, isNotEmpty);
      expect(explanation.recommendations, isNotEmpty);
    });

    test('Parses structured JSON correctly from mock backend payload', () {
      const rawMockAiJson = '''
      {
        "verdict": "critical",
        "riskScore": 87,
        "confidence": 93,
        "summary": "High-confidence credential harvesting attempt detected.",
        "indicators": ["Lookalike domain", "Suspicious query parameter"],
        "recommendation": "Do not navigate to this destination and block sender.",
        "webpageInspected": false
      }
      ''';

      final parsed = jsonDecode(rawMockAiJson) as Map<String, dynamic>;
      expect(parsed['verdict'], equals('critical'));
      expect(parsed['riskScore'], equals(87));
      expect(parsed['confidence'], equals(93));
      expect(parsed['webpageInspected'], isFalse);
    });
  });

  group('6. Assistant Controller & Repository Integration Tests', () {
    test('AssistantController dispatches tools and updates state', () async {
      final controller = AssistantController(
        repository: AssistantRepositoryImpl(),
        enableTypewriter: false,
      );

      // Trigger phone security check
      await controller.checkPhone();

      // Controller should now have messages including user prompt and tool response
      expect(controller.messages.length, greaterThanOrEqualTo(2));
      final lastMsg = controller.messages.last;
      expect(lastMsg.sender, equals(MessageSender.assistant));
      expect(lastMsg.hasToolExecution, isTrue);
      expect(lastMsg.structuredResponse?.toolName, equals('get_device_security_status'));
    });
  });
}
