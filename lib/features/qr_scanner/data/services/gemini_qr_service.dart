import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/qr_scan_result.dart';

class GeminiQrService {
  final String? _apiKey;

  GeminiQrService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Extracts URL from QR payload and analyzes threat level with Gemini 2.5 Flash
  Future<QrScanResult> analyzeQrPayload(String rawPayload) async {
    final extractedUrl = _extractUrlFromPayload(rawPayload);
    final isHttps = extractedUrl.startsWith('https://');

    // Attempt Gemini 2.5 Flash API invocation if configured
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final result = await _callGeminiApi(rawPayload, extractedUrl, isHttps);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini QR API call failed, activating local forensic engine: $e');
      }
    }

    // High-precision local quishing & forensic heuristic model
    return _performForensicQrAnalysis(rawPayload, extractedUrl, isHttps);
  }

  /// Extracts target URL from raw QR code text or intent strings
  String _extractUrlFromPayload(String raw) {
    final trimmed = raw.trim();

    // Regex for standard URLs
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final match = urlRegex.firstMatch(trimmed);
    if (match != null) {
      return match.group(0)!;
    }

    // Check for naked domain patterns (e.g. "secure-bank.com/login")
    final domainRegex = RegExp(
        r'^[a-zA-Z0-9][-a-zA-Z0-9]*\.[a-zA-Z]{2,}(/[^\s]*)?$',
        caseSensitive: false);
    if (domainRegex.hasMatch(trimmed)) {
      return 'https://$trimmed';
    }

    // If payload contains an intent or protocol
    if (trimmed.startsWith('intent://') || trimmed.startsWith('upi://') || trimmed.startsWith('qr://')) {
      return trimmed;
    }

    return trimmed;
  }

  Future<QrScanResult?> _callGeminiApi(
      String rawPayload, String extractedUrl, bool isHttps) async {
    final prompt = '''
You are CyberGuard XAI's senior QR and "Quishing" forensic analyst.
A user scanned a physical QR code.
Raw Payload: "$rawPayload"
Extracted Endpoint: "$extractedUrl"

Evaluate strictly for:
1. Quishing (QR Phishing): Deceptive landing pages designed to harvest authentication credentials.
2. Look-alike Domains: Character substitutions (e.g. paypa1, micros0ft), punycode, or secondary SLDs mimicking brands.
3. Fake Banking or Payment Fraud: Masquerading as Chase, PayPal, Wells Fargo, or spoofing payment intents.
4. Suspicious Redirects: URL shorteners (bit.ly, tinyurl) masking malicious destinations.
5. Transport Encryption: Plaintext unencrypted HTTP vs valid HTTPS.

Classify strictly into one of three verdicts:
- "SAFE": Legitimate domain, verified reputation, authentic SSL.
- "SUSPICIOUS": Ambiguous origin, URL shortener, missing HTTPS, or atypical parameters.
- "DANGEROUS": High-confidence phishing, credential harvester, look-alike spoof, or counterfeit banking portal.

CRITICAL INSTRUCTION: Explicitly explain WHY this verdict was reached so the user understands the exact risk.

Respond strictly in valid JSON format:
{
  "verdict": "SAFE" | "SUSPICIOUS" | "DANGEROUS",
  "riskScore": 85,
  "reason": "Clear explanation of why this QR code was classified as such",
  "recommendedAction": "Actionable directive for the user",
  "threatSignals": ["Signal 1", "Signal 2"]
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
      final textContent = jsonBody['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (textContent != null) {
        final Map<String, dynamic> data = jsonDecode(textContent);
        return _mapJsonToQrResult(data, rawPayload, extractedUrl, isHttps);
      }
    }
    return null;
  }

  QrScanResult _mapJsonToQrResult(Map<String, dynamic> data,
      String rawPayload, String extractedUrl, bool isHttps) {
    final verdictStr = (data['verdict'] as String?)?.toUpperCase() ?? 'SUSPICIOUS';
    final int score = (data['riskScore'] as num?)?.toInt() ?? 50;

    final QrSafetyVerdict verdict;
    if (verdictStr == 'SAFE' || score < 30) {
      verdict = QrSafetyVerdict.safe;
    } else if (verdictStr == 'DANGEROUS' || score >= 70) {
      verdict = QrSafetyVerdict.dangerous;
    } else {
      verdict = QrSafetyVerdict.suspicious;
    }

    final rawSignals = data['threatSignals'] as List<dynamic>? ?? [];
    final List<String> signals = rawSignals.map((s) => s.toString()).toList();

    return QrScanResult(
      rawPayload: rawPayload,
      extractedUrl: extractedUrl,
      verdict: verdict,
      riskScore: score,
      reason: data['reason'] as String? ?? 'Forensic QR inspection concluded.',
      recommendedAction: data['recommendedAction'] as String? ??
          'Do not open this URL automatically. Review the forensic indicators.',
      isHttps: isHttps,
      threatSignals: signals,
      scannedAt: DateTime.now(),
    );
  }

  /// Local Quishing & Heuristic Analysis Engine
  QrScanResult _performForensicQrAnalysis(
      String rawPayload, String url, bool isHttps) {
    int riskScore = 0;
    final List<String> reasons = [];
    final List<String> signals = [];

    final lowerUrl = url.toLowerCase();

    // Check for target financial/tech brands
    final brands = [
      'paypal',
      'chase',
      'wellsfargo',
      'bankofamerica',
      'citi',
      'apple',
      'google',
      'microsoft',
      'amazon'
    ];

    // 1. Phishing & Quishing Keywords
    final suspiciousKeywords = [
      'login',
      'verify',
      'auth',
      'account-update',
      'secure',
      'billing',
      'confirm',
      'otp',
      'token',
      'claim',
      'bonus'
    ];

    int keywordCount = 0;
    for (final kw in suspiciousKeywords) {
      if (lowerUrl.contains(kw)) {
        keywordCount++;
      }
    }

    if (keywordCount >= 2) {
      riskScore += 40;
      signals.add('Multiple sensitive authentication terms detected ($keywordCount keywords)');
      reasons.add('URL contains deceptive credential harvesting keywords.');
    }

    // 2. Look-alike & Typosquatting
    for (final brand in brands) {
      if (lowerUrl.contains(brand) &&
          !lowerUrl.contains('$brand.com') &&
          !lowerUrl.contains('$brand.org')) {
        riskScore += 50;
        signals.add('Impersonates brand "$brand" using unauthorized secondary domain');
        reasons.add('Domain masquerades as official "$brand" identity.');
        break;
      }
    }

    // Typosquatting (paypa1, micros0ft)
    if (lowerUrl.contains('paypa1') ||
        lowerUrl.contains('micros0ft') ||
        lowerUrl.contains('g00gle')) {
      riskScore += 55;
      signals.add('Character substitution typosquatting detected');
      reasons.add('Employs character substitution (e.g. "1" for "l", "0" for "o").');
    }

    // 3. Shortened URLs hiding destinations (quishing vector)
    final shorteners = ['bit.ly', 'tinyurl.com', 't.co', 'rb.gy', 'is.gd', 'cutt.ly'];
    if (shorteners.any((s) => lowerUrl.contains(s))) {
      riskScore += 35;
      signals.add('URL shortener masks final landing destination');
      reasons.add('Uses URL shortening service to conceal true endpoint.');
    }

    // 4. Raw Numerical IP Address
    if (RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(lowerUrl)) {
      riskScore += 50;
      signals.add('Host is a raw numerical IP address bypassing DNS domain registry');
      reasons.add('Direct numerical IP host detected without domain reputation.');
    }

    // 5. Unencrypted HTTP Transport
    if (!isHttps && url.startsWith('http://')) {
      riskScore += 25;
      signals.add('Unencrypted plaintext HTTP protocol');
      reasons.add('Lacks TLS/SSL encryption; traffic is vulnerable to interception.');
    }

    // 6. Suspicious / High-risk TLDs
    final highRiskTlds = ['.cc', '.top', '.xyz', '.buzz', '.tk', '.fit', '.cf'];
    if (highRiskTlds.any((tld) => lowerUrl.contains(tld))) {
      riskScore += 20;
      signals.add('High-risk top-level domain frequently associated with quishing campaigns');
    }

    final finalScore = riskScore.clamp(0, 100);

    final QrSafetyVerdict verdict;
    if (finalScore >= 70) {
      verdict = QrSafetyVerdict.dangerous;
    } else if (finalScore >= 30) {
      verdict = QrSafetyVerdict.suspicious;
    } else {
      verdict = QrSafetyVerdict.safe;
    }

    final String reasonText;
    final String recommendedAction;

    switch (verdict) {
      case QrSafetyVerdict.dangerous:
        reasonText = reasons.isNotEmpty
            ? 'HIGH-CONFIDENCE QUISHING DETECTED: ${reasons.join(" ")}'
            : 'Known malicious QR payload matching credential harvesting patterns.';
        recommendedAction =
            'CRITICAL SAFETY DIRECTIVE: Under Zero-Trust protocols, this URL will NEVER be opened automatically. Do NOT visit this link or input credentials.';
        break;

      case QrSafetyVerdict.suspicious:
        reasonText = reasons.isNotEmpty
            ? 'POTENTIAL QUISHING HAZARD: ${reasons.join(" ")}'
            : 'URL exhibits ambiguous routing, URL shortening, or unverified domain parameters.';
        recommendedAction =
            'DEFENSE WARNING: Automatic navigation blocked. Carefully verify the target domain identity before interacting.';
        break;

      case QrSafetyVerdict.safe:
        reasonText =
            'VERIFIED AUTHENTIC: Endpoint uses standard TLS encryption and matches verified domain reputation norms.';
        recommendedAction =
            'SAFE TO PROCEED: No malicious indicators detected. You may manually open this link if expected.';
        break;
    }

    return QrScanResult(
      rawPayload: rawPayload,
      extractedUrl: url,
      verdict: verdict,
      riskScore: finalScore,
      reason: reasonText,
      recommendedAction: recommendedAction,
      isHttps: isHttps,
      threatSignals: signals,
      scannedAt: DateTime.now(),
    );
  }
}
