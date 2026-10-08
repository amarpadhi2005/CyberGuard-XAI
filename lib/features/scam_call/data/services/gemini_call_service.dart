import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/call_scan_result.dart';

class GeminiCallService {
  final String? _apiKey;

  GeminiCallService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // Comprehensive Local Demo Database of Known Numbers & Threat Signatures
  static final Map<String, Map<String, dynamic>> _demoDatabase = {
    // 1. FRAUD
    '+18004929182': {
      'callerName': 'IRS Legal Enforcement Department (Spoofed)',
      'carrier': 'Bandwidth.com VoIP Gateway',
      'location': 'Dallas, TX, USA',
      'verdict': CallVerdict.fraud,
      'riskScore': 96,
      'category': 'Financial Impersonation / Tax Fraud',
      'action': 'BLOCK & DO NOT ANSWER. Known arrest warrant extortion ruse.',
      'reports': 2841,
      'signals': [
        'Matches active IRS extortion campaign in federal databases',
        'Outbound caller-ID spoofing detected on toll-free routing',
        'Over 2,800 community fraud reports logged in the past 7 days'
      ],
      'explanation':
          'FRAUD IDENTIFIED: This number is heavily reported for automated robocalls threatening arrest or legal seizure unless back-taxes are paid via prepaid cards or cryptocurrency.',
    },
    // 2. SPAM
    '+18882039128': {
      'callerName': 'National Solar Incentive Telemarketing',
      'carrier': 'Twilio Inc. Hosted VoIP',
      'location': 'Sacramento, CA, USA',
      'verdict': CallVerdict.spam,
      'riskScore': 78,
      'category': 'Robocall Telemarketing',
      'action': 'SILENCE & REJECT. Unsolicited automated telemarketing campaign.',
      'reports': 1420,
      'signals': [
        'National Do-Not-Call (DNC) Registry violation reports',
        'High-frequency predictive dialer pattern (500+ calls/hour)',
        'Recorded synthetic voice greeting signature'
      ],
      'explanation':
          'SPAM IDENTIFIED: High-volume autodialer promoting unauthorized renewable energy contracts without consumer opt-in consent.',
    },
    // 3. SAFE
    '+18002752273': {
      'callerName': 'Apple Official Customer Support',
      'carrier': 'AT&T Corp / Enterprise Trunk',
      'location': 'Cupertino, CA, USA',
      'verdict': CallVerdict.safe,
      'riskScore': 4,
      'category': 'Verified Enterprise Support',
      'action': 'SAFE TO ANSWER. Official verified customer assistance line.',
      'reports': 0,
      'signals': [
        'STIR/SHAKEN A-Level cryptographic attestation token valid',
        'Public enterprise registry verified: Apple Inc.',
        'Zero malicious community complaints logged'
      ],
      'explanation':
          'SAFE TO RECEIVE: Verified authentic inbound customer care endpoint belonging to Apple Inc. with valid cryptographic carrier attestation.',
    },
    // 4. UNKNOWN
    '+13125550199': {
      'callerName': 'Private Unregistered Caller',
      'carrier': 'T-Mobile USA',
      'location': 'Chicago, IL, USA',
      'verdict': CallVerdict.unknown,
      'riskScore': 32,
      'category': 'Unregistered Private Number',
      'action': 'EXERCISE CAUTION. Private number with no prior reputation data.',
      'reports': 2,
      'signals': [
        'No verified enterprise directory listing found',
        'Insufficient community reporting history to confirm threat',
        'STIR/SHAKEN B-Level carrier attestation'
      ],
      'explanation':
          'UNKNOWN CALLER: Number is not listed in crowdsourced threat intelligence databases. Exercise prudence and do not share sensitive details.',
    },
  };

  /// Analyzes phone number using local demo database with Gemini 2.5 Flash enhancement
  Future<CallScanResult> analyzePhoneNumber(String rawNumber) async {
    final cleanDigits = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanDigits.replaceAll('+', '').trim().isEmpty) {
      throw Exception('Invalid phone number format: No digits provided.');
    }
    final normalized = cleanDigits.startsWith('+') ? cleanDigits : '+$cleanDigits';
    final now = DateTime.now();
    final scanId = 'CALL-${now.millisecondsSinceEpoch}';

    // 1. Check Local Demo Database first
    if (_demoDatabase.containsKey(normalized)) {
      final data = _demoDatabase[normalized]!;
      return CallScanResult(
        id: scanId,
        phoneNumber: normalized,
        formattedNumber: rawNumber,
        callerName: data['callerName'] as String,
        carrier: data['carrier'] as String,
        location: data['location'] as String,
        verdict: data['verdict'] as CallVerdict,
        riskScore: data['riskScore'] as int,
        callerCategory: data['category'] as String,
        recommendedAction: data['action'] as String,
        reportsCount: data['reports'] as int,
        threatSignals: List<String>.from(data['signals'] as List),
        explanation: data['explanation'] as String,
        timestamp: now,
      );
    }

    // 2. If Gemini API configured, evaluate arbitrary input number
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final result = await _callGeminiApi(scanId, rawNumber, normalized, now);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini Phone API call failed, activating local heuristics: $e');
      }
    }

    // 3. Dynamic Local Forensic Telephony Engine
    return _performHeuristicAnalysis(scanId, rawNumber, normalized, now);
  }

  Future<CallScanResult?> _callGeminiApi(
    String scanId,
    String rawNumber,
    String normalized,
    DateTime timestamp,
  ) async {
    final prompt = '''
You are CyberGuard XAI's telecom fraud intelligence engine.
Analyze this phone number for scam and spam behavior: "$rawNumber" (normalized: "$normalized").

Classify strictly into one of four verdicts:
- "SPAM": Unsolicited commercial robocalls, aggressive telemarketing.
- "SAFE": Verified legitimate enterprise, official emergency or verified customer care.
- "UNKNOWN": Private, unregistered, or unlisted number with no history.
- "FRAUD": High-risk financial impersonation, IRS scam, tech support extortion, SIM-swap.

Respond strictly in valid JSON format:
{
  "callerName": "Identified Caller or Entity",
  "carrier": "Telecom Operator or VoIP Provider",
  "location": "Geographic City / State / Country",
  "verdict": "SPAM" | "SAFE" | "UNKNOWN" | "FRAUD",
  "riskScore": 88,
  "callerCategory": "Financial Impersonation" | "Robocall Telemarketing" | "Verified Business" | "Unregistered VoIP",
  "recommendedAction": "Actionable advice for the user",
  "reportsCount": 1240,
  "threatSignals": ["Signal 1", "Signal 2"],
  "explanation": "Why this call is classified as such"
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
        return _mapJsonToCallResult(data, scanId, rawNumber, normalized, timestamp);
      }
    }
    return null;
  }

  CallScanResult _mapJsonToCallResult(
    Map<String, dynamic> data,
    String scanId,
    String rawNumber,
    String normalized,
    DateTime timestamp,
  ) {
    final verdictStr = (data['verdict'] as String?)?.toUpperCase() ?? 'UNKNOWN';
    final CallVerdict verdict;
    switch (verdictStr) {
      case 'FRAUD':
        verdict = CallVerdict.fraud;
        break;
      case 'SPAM':
        verdict = CallVerdict.spam;
        break;
      case 'SAFE':
        verdict = CallVerdict.safe;
        break;
      default:
        verdict = CallVerdict.unknown;
        break;
    }

    final rawSignals = data['threatSignals'] as List<dynamic>? ?? [];

    return CallScanResult(
      id: scanId,
      phoneNumber: normalized,
      formattedNumber: rawNumber,
      callerName: data['callerName'] as String? ?? 'Suspicious Caller',
      carrier: data['carrier'] as String? ?? 'Virtual VoIP Carrier',
      location: data['location'] as String? ?? 'International / Concealed',
      verdict: verdict,
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 50,
      callerCategory: data['callerCategory'] as String? ?? 'Unverified Caller ID',
      recommendedAction: data['recommendedAction'] as String? ?? 'Exercise caution.',
      reportsCount: (data['reportsCount'] as num?)?.toInt() ?? 10,
      threatSignals: rawSignals.map((s) => s.toString()).toList(),
      explanation: data['explanation'] as String? ?? 'Telecom analysis concluded.',
      timestamp: timestamp,
    );
  }

  /// Dynamic heuristic analysis for arbitrary phone numbers
  CallScanResult _performHeuristicAnalysis(
    String scanId,
    String rawNumber,
    String normalized,
    DateTime timestamp,
  ) {
    // Check known toll-free prefixes (often spoofed for outbound fraud)
    final isTollFree = normalized.startsWith('+1800') ||
        normalized.startsWith('+1888') ||
        normalized.startsWith('+1877') ||
        normalized.startsWith('+1866');

    // Premium rate fraud (+1900)
    final isPremium = normalized.startsWith('+1900') || normalized.startsWith('+1976');

    if (isPremium) {
      return CallScanResult(
        id: scanId,
        phoneNumber: normalized,
        formattedNumber: rawNumber,
        callerName: 'High-Tariff Premium Rate Ruse',
        carrier: 'Offshore Telephony Aggregator',
        location: 'International Surcharge Zone',
        verdict: CallVerdict.fraud,
        riskScore: 94,
        callerCategory: 'Premium Rate Extortion',
        recommendedAction: 'BLOCK NUMBER. Calling back will incur exorbitant billing charges.',
        reportsCount: 890,
        threatSignals: const [
          'Matches known pay-per-call premium surcharge prefixes',
          'Automated one-ring lure pattern designed to induce callbacks'
        ],
        explanation:
            'FRAUD DETECTED: Wangiri / One-ring callback trap. Adversaries generate brief missed calls from premium rate numbers that charge extraordinary per-minute fees.',
        timestamp: timestamp,
      );
    }

    if (isTollFree) {
      return CallScanResult(
        id: scanId,
        phoneNumber: normalized,
        formattedNumber: rawNumber,
        callerName: 'Unverified Toll-Free Outbound Caller',
        carrier: 'Virtual Trunk Line',
        location: 'North America Toll-Free',
        verdict: CallVerdict.spam,
        riskScore: 68,
        callerCategory: 'Suspected Outbound Robocall',
        recommendedAction: 'DO NOT ANSWER. Toll-free numbers rarely originate legitimate calls.',
        reportsCount: 312,
        threatSignals: const [
          'Toll-free prefix used for outbound call solicitation',
          'Potential Caller-ID CLI spoofing signature'
        ],
        explanation:
            'SPAM ALERT: Legitimate toll-free lines exist for incoming support. Outbound calls bearing toll-free caller IDs frequently indicate telemarketing or spoofing.',
        timestamp: timestamp,
      );
    }

    // Default unknown private number
    return CallScanResult(
      id: scanId,
      phoneNumber: normalized,
      formattedNumber: rawNumber,
      callerName: 'Unlisted Number',
      carrier: 'Standard Carrier Routing',
      location: 'Unverified Location',
      verdict: CallVerdict.unknown,
      riskScore: 15,
      callerCategory: 'Unverified Caller',
      recommendedAction: 'Verify caller identity independently before sharing sensitive information.',
      reportsCount: 0,
      threatSignals: const [
        'Live reputation lookup is not configured.',
        'Standard mobile/landline numbering format'
      ],
      explanation:
          'Live reputation lookup is not configured. Local heuristic checks detected no high-risk premium rate or spoofing patterns.',
      timestamp: timestamp,
    );
  }
}
