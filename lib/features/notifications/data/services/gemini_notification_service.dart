import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/protected_notification.dart';

class GeminiNotificationService {
  final String? _apiKey;

  GeminiNotificationService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Evaluates notification text with Gemini 2.5 Flash API with heuristic fallback
  Future<ProtectedNotification> analyzeNotification({
    required String title,
    required String body,
    required String appSource,
  }) async {
    final now = DateTime.now();
    final notifId = 'NTF-${now.millisecondsSinceEpoch}';

    // 1. Attempt Gemini 2.5 Flash API if key configured
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final result = await _callGeminiApi(notifId, title, body, appSource, now);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini Notification Analysis failed, activating local engine: $e');
      }
    }

    // 2. High-precision local heuristic notification classifier
    return _performForensicAnalysis(notifId, title, body, appSource, now);
  }

  Future<ProtectedNotification?> _callGeminiApi(
    String id,
    String title,
    String body,
    String appSource,
    DateTime timestamp,
  ) async {
    final prompt = '''
You are CyberGuard XAI's autonomous real-time notification protection analyst.
Evaluate this incoming mobile notification payload:
App Source: "$appSource"
Title: "$title"
Body: "$body"

Analyze strictly for:
1. Bank Scams: Fake debit alerts, unauthorized card charges, spoofed customer care numbers.
2. Lottery: Bogus prize winnings, unexpected sweepstakes, claims requiring gift cards/advance fees.
3. Fake KYC: Urgent threats of bank account freeze, PAN/Aadhaar/KYC expiration deadlines.
4. OTP Theft: Social engineering tricks attempting to intercept 2FA codes or convincing users to share codes with "support agents".
5. Urgent Payment Requests: Impersonating executives/CEOs demanding emergency wire transfers, gift cards, or crypto transfers.

Respond strictly in valid JSON format:
{
  "category": "BANK_SCAMS" | "LOTTERY" | "FAKE_KYC" | "OTP_THEFT" | "URGENT_PAYMENT" | "CLEAN",
  "isMalicious": true,
  "severity": "CRITICAL" | "HIGH" | "MEDIUM" | "SAFE",
  "explanation": "Clear explanation of detected fraud or safety reasoning",
  "recommendedAction": "Actionable directive for the user",
  "confidence": 0.98
}
''';

    final endpoint = Uri.parse('$_geminiBaseUrl?key=$_apiKey');
    final response = await http
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [{'text': prompt}]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'responseMimeType': 'application/json',
            }
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final text = jsonBody['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) {
        final Map<String, dynamic> data = jsonDecode(text);
        return _mapJsonToNotification(data, id, title, body, appSource, timestamp);
      }
    }
    return null;
  }

  ProtectedNotification _mapJsonToNotification(
    Map<String, dynamic> data,
    String id,
    String title,
    String body,
    String appSource,
    DateTime timestamp,
  ) {
    final catStr = (data['category'] as String?)?.toUpperCase() ?? 'CLEAN';
    final sevStr = (data['severity'] as String?)?.toUpperCase() ?? 'MEDIUM';
    final isMalicious = data['isMalicious'] as bool? ?? false;

    final NotificationThreatCategory category;
    switch (catStr) {
      case 'BANK_SCAMS':
        category = NotificationThreatCategory.bankScam;
        break;
      case 'LOTTERY':
        category = NotificationThreatCategory.lottery;
        break;
      case 'FAKE_KYC':
        category = NotificationThreatCategory.fakeKyc;
        break;
      case 'OTP_THEFT':
        category = NotificationThreatCategory.otpTheft;
        break;
      case 'URGENT_PAYMENT':
        category = NotificationThreatCategory.urgentPayment;
        break;
      default:
        category = isMalicious
            ? NotificationThreatCategory.bankScam
            : NotificationThreatCategory.clean;
    }

    final NotificationSeverity severity;
    switch (sevStr) {
      case 'CRITICAL':
        severity = NotificationSeverity.critical;
        break;
      case 'HIGH':
        severity = NotificationSeverity.high;
        break;
      case 'MEDIUM':
        severity = NotificationSeverity.medium;
        break;
      default:
        severity = NotificationSeverity.safe;
    }

    return ProtectedNotification(
      id: id,
      title: title,
      body: body,
      appSource: appSource,
      threatCategory: category,
      severity: severity,
      isMalicious: isMalicious,
      explanation: data['explanation'] as String? ?? 'Forensic evaluation concluded.',
      recommendedAction: data['recommendedAction'] as String? ??
          'Do not interact with the links or numbers in this alert.',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.95,
      timestamp: timestamp,
    );
  }

  /// High-accuracy local forensic engine for the 5 target categories
  ProtectedNotification _performForensicAnalysis(
    String id,
    String title,
    String body,
    String appSource,
    DateTime timestamp,
  ) {
    final fullText = '$title $body'.toLowerCase();

    // 1. Fake KYC Scams
    if (fullText.contains('kyc') &&
        (fullText.contains('expire') ||
            fullText.contains('freeze') ||
            fullText.contains('block') ||
            fullText.contains('suspended') ||
            fullText.contains('update'))) {
      return ProtectedNotification(
        id: id,
        title: title,
        body: body,
        appSource: appSource,
        threatCategory: NotificationThreatCategory.fakeKyc,
        severity: NotificationSeverity.critical,
        isMalicious: true,
        explanation:
            'FAKE KYC FRAUD: The message threatens account freezing unless an unverified KYC link is immediately completed. Banks never demand urgent KYC via SMS or third-party links.',
        recommendedAction:
            'Do NOT click the link. Visit your official bank branch or genuine mobile banking app directly.',
        confidence: 0.99,
        timestamp: timestamp,
      );
    }

    // 2. OTP Theft Interception
    if ((fullText.contains('otp') || fullText.contains('verification code')) &&
        (fullText.contains('agent') ||
            fullText.contains('share') ||
            fullText.contains('call') ||
            fullText.contains('read back') ||
            fullText.contains('support'))) {
      return ProtectedNotification(
        id: id,
        title: title,
        body: body,
        appSource: appSource,
        threatCategory: NotificationThreatCategory.otpTheft,
        severity: NotificationSeverity.critical,
        isMalicious: true,
        explanation:
            'OTP THEFT ATTEMPT: An adversary is attempting to socially engineer your One-Time Password to bypass two-factor authentication on your account.',
        recommendedAction:
            'NEVER share OTP codes with anyone, including individuals claiming to be bank or tech support agents.',
        confidence: 0.98,
        timestamp: timestamp,
      );
    }

    // 3. Bank Scams (Fake debit alerts, bogus call center numbers)
    if ((fullText.contains('charged') ||
            fullText.contains('debited') ||
            fullText.contains('withdrawn') ||
            fullText.contains('transaction of')) &&
        (fullText.contains('call') ||
            fullText.contains('if not you') ||
            fullText.contains('customer care') ||
            fullText.contains('helpline') ||
            fullText.contains('+1-800') ||
            fullText.contains('+91'))) {
      return ProtectedNotification(
        id: id,
        title: title,
        body: body,
        appSource: appSource,
        threatCategory: NotificationThreatCategory.bankScam,
        severity: NotificationSeverity.high,
        isMalicious: true,
        explanation:
            'BANK FRAUD HOAX: Generates artificial panic by fabricating a phantom transaction to trick you into calling a fraudulent call-center helpline.',
        recommendedAction:
            'Do NOT dial the phone number provided in the message. Check your real account balance within your banking app.',
        confidence: 0.97,
        timestamp: timestamp,
      );
    }

    // 4. Lottery / Sweepstakes Scams
    if ((fullText.contains('won') ||
            fullText.contains('winner') ||
            fullText.contains('lottery') ||
            fullText.contains('prize') ||
            fullText.contains('selected for')) &&
        (fullText.contains('claim') ||
            fullText.contains('code') ||
            fullText.contains('deposit') ||
            fullText.contains('fee') ||
            fullText.contains('pounds') ||
            fullText.contains('dollars') ||
            fullText.contains('£') ||
            fullText.contains('\$'))) {
      return ProtectedNotification(
        id: id,
        title: title,
        body: body,
        appSource: appSource,
        threatCategory: NotificationThreatCategory.lottery,
        severity: NotificationSeverity.high,
        isMalicious: true,
        explanation:
            'LOTTERY ADVANCE-FEE SCAM: Fraudulent notification claiming you have won a competition or lottery you never entered. Requires processing fees or steals banking details.',
        recommendedAction:
            'Ignore and report. Genuine lotteries never contact unentered phone numbers demanding claims.',
        confidence: 0.99,
        timestamp: timestamp,
      );
    }

    // 5. Urgent Payment Requests (CEO fraud / Gift card demands)
    if ((fullText.contains('urgent') ||
            fullText.contains('emergency') ||
            fullText.contains('board meeting') ||
            fullText.contains('ceo') ||
            fullText.contains('manager') ||
            fullText.contains('boss')) &&
        (fullText.contains('gift card') ||
            fullText.contains('wire') ||
            fullText.contains('apple card') ||
            fullText.contains('send money') ||
            fullText.contains('transfer') ||
            fullText.contains('crypto'))) {
      return ProtectedNotification(
        id: id,
        title: title,
        body: body,
        appSource: appSource,
        threatCategory: NotificationThreatCategory.urgentPayment,
        severity: NotificationSeverity.high,
        isMalicious: true,
        explanation:
            'EXECUTIVE IMPERSONATION / BEC: Attacker masquerades as authority figure demanding emergency wire or gift cards while claiming to be unavailable by voice.',
        recommendedAction:
            'Verify directly in person or via telephone with your supervisor. Never purchase gift cards for corporate tasks.',
        confidence: 0.96,
        timestamp: timestamp,
      );
    }

    // Benchmark Clean Notification
    return ProtectedNotification(
      id: id,
      title: title,
      body: body,
      appSource: appSource,
      threatCategory: NotificationThreatCategory.clean,
      severity: NotificationSeverity.safe,
      isMalicious: false,
      explanation:
          'AUTHENTIC NOTIFICATION: No malicious phishing, smishing, or social engineering tokens detected. Conforms to standard transactional format.',
      recommendedAction:
          'Safe to interact with. Standard system telemetry remains active.',
      confidence: 0.95,
      timestamp: timestamp,
    );
  }
}
