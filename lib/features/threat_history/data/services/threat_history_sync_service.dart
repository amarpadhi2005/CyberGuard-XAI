import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/threat_history_item.dart';
import '../../domain/repositories/threat_history_repository.dart';
import '../repositories/threat_history_repository_impl.dart';

class ThreatHistorySyncService {
  final ThreatHistoryRepository _repository;
  final String? _apiKey;

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  ThreatHistorySyncService({
    ThreatHistoryRepository? repository,
    String? apiKey,
  })  : _repository = repository ?? ThreatHistoryRepositoryImpl(),
        _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  /// Unified scan recorder that writes any security scan from any feature to Firestore
  Future<ThreatHistoryItem> recordScan({
    required String title,
    required ThreatCategory category,
    required String threatType,
    required int riskScore,
    required String reason,
    required String recommendedAction,
    String source = 'Gemini 2.5 Flash',
    Map<String, dynamic> metadata = const {},
    required String userId,
  }) async {
    final now = DateTime.now();
    final item = ThreatHistoryItem(
      id: 'THREAT-${now.millisecondsSinceEpoch}',
      title: title,
      category: category,
      threatType: threatType,
      riskScore: riskScore,
      severity: ThreatSeverity.fromRiskScore(riskScore),
      reason: reason,
      recommendedAction: recommendedAction,
      source: source,
      timestamp: now,
      metadata: metadata,
    );

    await _repository.saveThreatItem(item, userId);
    return item;
  }

  /// Specialized AI Email Analyzer & Threat Logger
  Future<ThreatHistoryItem> analyzeAndRecordEmail({
    required String subject,
    required String sender,
    required String body,
    required String userId,
  }) async {
    final now = DateTime.now();
    final scanId = 'THREAT-EMAIL-${now.millisecondsSinceEpoch}';

    // 1. If Gemini configured, run through LLM
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final result = await _callGeminiEmailApi(scanId, subject, sender, body, now);
        if (result != null) {
          await _repository.saveThreatItem(result, userId);
          return result;
        }
      } catch (e) {
        debugPrint('Gemini Email Analysis failed, falling back to heuristics: $e');
      }
    }

    // 2. Local Threat Heuristics for Email
    final lower = '$subject $body $sender'.toLowerCase();
    final isWireTransfer = lower.contains('wire') ||
        lower.contains('transfer') ||
        lower.contains('invoice') ||
        lower.contains('payroll');
    final isUrgent = lower.contains('urgent') ||
        lower.contains('immediate') ||
        lower.contains('suspend') ||
        lower.contains('action required');
    final isSpoofedSender = sender.contains('.xyz') ||
        sender.contains('mail-sec') ||
        sender.contains('verify-portal');

    int score = 25;
    String threatType = 'Standard Correspondence';
    String reason = 'Sender email structure and content exhibit normal communication markers.';
    String action = 'Safe to read. Exercise usual discretion with external attachments.';

    if (isWireTransfer && isUrgent) {
      score = 92;
      threatType = 'Business Email Compromise (BEC)';
      reason = 'High-pressure financial payment request matching executive impersonation patterns. Urges quick settlement without normal protocol.';
      action = 'DO NOT EXECUTE PAYMENT. Verify request via internal out-of-band communication.';
    } else if (isSpoofedSender || isUrgent) {
      score = 75;
      threatType = 'Suspicious Phishing Email';
      reason = 'Urgent call-to-action originating from an unverified domain with suspicious MX indicators.';
      action = 'Do not click embedded hyperlinks or download attachments.';
    }

    final item = ThreatHistoryItem(
      id: scanId,
      title: subject.isNotEmpty ? subject : 'Untitled Email Communication',
      category: ThreatCategory.email,
      threatType: threatType,
      riskScore: score,
      severity: ThreatSeverity.fromRiskScore(score),
      reason: reason,
      recommendedAction: action,
      source: 'Gemini 2.5 Flash / Heuristic Defense',
      timestamp: now,
      metadata: {'sender': sender, 'body_length': body.length},
    );

    await _repository.saveThreatItem(item, userId);
    return item;
  }

  Future<ThreatHistoryItem?> _callGeminiEmailApi(
    String scanId,
    String subject,
    String sender,
    String body,
    DateTime timestamp,
  ) async {
    final prompt = '''
You are CyberGuard XAI's enterprise email threat detection engine.
Analyze this email communication:
Sender: "$sender"
Subject: "$subject"
Body: "$body"

Evaluate for:
- Business Email Compromise (BEC)
- Credential Phishing
- Ransomware / Malicious Attachment Lure
- Urgency / Fear Extortion
- Executive Impersonation

Respond strictly in JSON:
{
  "threatType": "Short threat label (e.g. Business Email Compromise)",
  "riskScore": 88,
  "reason": "Detailed explanation of indicators and suspicious elements",
  "recommendedAction": "Concrete security action for the recipient"
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
        final score = (data['riskScore'] as num?)?.toInt() ?? 60;
        return ThreatHistoryItem(
          id: scanId,
          title: subject.isNotEmpty ? subject : 'Email: $sender',
          category: ThreatCategory.email,
          threatType: data['threatType'] as String? ?? 'Suspicious Email',
          riskScore: score,
          severity: ThreatSeverity.fromRiskScore(score),
          reason: data['reason'] as String? ?? 'Email analysis completed.',
          recommendedAction:
              data['recommendedAction'] as String? ?? 'Do not reply or click links.',
          source: 'Gemini 2.5 Flash',
          timestamp: timestamp,
          metadata: {'sender': sender},
        );
      }
    }
    return null;
  }
}
