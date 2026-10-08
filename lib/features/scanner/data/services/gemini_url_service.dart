import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/url_scan_result.dart';
import 'url_forensic_utils.dart';

class GeminiUrlService {
  final String? _apiKey;

  GeminiUrlService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Performs deep threat analysis via Gemini API with fallback to deterministic forensic engine.
  Future<UrlScanResult> analyzeUrl(String rawUrl, {bool isQuickTest = false}) async {
    // 1. Single Source of Truth: Validate & Normalize
    final NormalizedUrlData norm = UrlForensicUtils.normalize(rawUrl);

    // 2. Attempt Structured Gemini API call if key is configured
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final result = await _callStructuredGeminiApi(norm, isQuickTest);
        if (result != null) return result;
      } on SocketException {
        debugPrint('Gemini API: Network unavailable. Falling back to local forensic engine.');
      } on TimeoutException {
        debugPrint('Gemini API: Request timed out. Falling back to local forensic engine.');
      } catch (e) {
        debugPrint('Gemini API call warning ($e). Activating deterministic forensic engine.');
      }
    }

    // 3. Deterministic Local Forensic Scoring Engine
    return _performForensicAnalysis(norm, isQuickTest: isQuickTest);
  }

  /// Calls Gemini 2.5 Flash and requires structured JSON response matching the required schema.
  Future<UrlScanResult?> _callStructuredGeminiApi(
      NormalizedUrlData norm, bool isQuickTest) async {
    final prompt = '''
You are CyberGuard XAI's senior threat intelligence agent. Analyze this exact target URL: "${norm.normalizedUrl}".

CRITICAL INSTRUCTIONS:
1. Webpage content was NOT inspected. Do NOT claim you saw a webpage, HTML form, banking layout, or password input field. Set "webpageInspected" to false.
2. HTTPS only indicates transport encryption. It does NOT prove legitimacy. Do not mark a site safe simply because HTTPS is enabled.
3. Analyze strictly the URL structure: domain, subdomains, brand impersonation, typosquatting, suspicious keywords in path/parameters, IP address, and obfuscation.
4. Calculate a realistic riskScore between 0 and 100 based strictly on observed evidence.
5. Provide specific, concrete evidence for each indicator.

Return valid JSON adhering strictly to this schema:
{
  "verdict": "critical" | "high" | "medium" | "low" | "safe",
  "riskScore": 82,
  "confidence": 94,
  "summary": "High-risk phishing indicators detected in URL syntax.",
  "indicators": [
    {
      "name": "Credential harvesting pattern",
      "severity": "high",
      "evidence": "login-related URL path /auth/otp",
      "explanation": "The URL contains path parameters commonly associated with credential collection."
    }
  ],
  "https": {
    "enabled": ${norm.protocol == 'https'},
    "meaning": "Connection encrypted; does not indicate legitimacy."
  },
  "webpageInspected": false,
  "recommendedAction": "Do not visit this URL.",
  "defangedUrl": "${norm.defangedUrl}"
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
        final decoded = jsonDecode(textContent);
        if (decoded is Map<String, dynamic>) {
          return _validateAndMapGeminiResponse(decoded, norm, isQuickTest);
        }
      }
    } else {
      debugPrint('Gemini API returned HTTP status ${response.statusCode}: ${response.body}');
    }
    return null;
  }

  /// Validates the AI response against the required schema before displaying it.
  UrlScanResult? _validateAndMapGeminiResponse(
      Map<String, dynamic> data, NormalizedUrlData norm, bool isQuickTest) {
    try {
      // Validate riskScore (0..100)
      final rawScore = data['riskScore'];
      if (rawScore is! num || rawScore < 0 || rawScore > 100) {
        debugPrint('Validation failed: riskScore missing or out of bounds (0-100)');
        return null;
      }
      final int riskScore = rawScore.toInt();

      // Validate verdict
      final rawVerdict = data['verdict'];
      if (rawVerdict is! String || rawVerdict.trim().isEmpty) {
        debugPrint('Validation failed: verdict missing or invalid');
        return null;
      }

      // Validate confidence (0..100)
      final rawConfidence = data['confidence'];
      int confidence = 90;
      if (rawConfidence is num) {
        confidence = rawConfidence > 1 ? rawConfidence.toInt().clamp(0, 100) : (rawConfidence * 100).toInt().clamp(0, 100);
      }

      // Validate summary
      final rawSummary = data['summary'];
      if (rawSummary is! String || rawSummary.trim().isEmpty) {
        debugPrint('Validation failed: summary missing');
        return null;
      }

      // Validate indicators list
      final rawIndicators = data['indicators'];
      if (rawIndicators is! List) {
        debugPrint('Validation failed: indicators is not a list');
        return null;
      }

      final List<UrlThreatIndicator> indicators = [];
      for (final item in rawIndicators) {
        if (item is Map<String, dynamic>) {
          final name = item['name'] as String? ?? 'Security Finding';
          final severity = item['severity'] as String? ?? 'info';
          final evidence = item['evidence'] as String? ?? 'Detected in URL telemetry';
          final explanation = item['explanation'] as String? ?? '';

          indicators.add(UrlThreatIndicator(
            name: name,
            severity: IndicatorSeverity.fromString(severity),
            evidence: evidence,
            explanation: explanation,
            confidence: confidence,
          ));
        }
      }

      // Validate HTTPS details
      final httpsMap = data['https'] as Map<String, dynamic>?;
      final bool isHttps = (httpsMap?['enabled'] as bool?) ?? (norm.protocol == 'https');
      final String httpsMeaning = (httpsMap?['meaning'] as String?) ??
          (isHttps
              ? 'Connection encrypted; does not prove website is legitimate.'
              : 'Insecure unencrypted HTTP transport.');

      // Validate recommendedAction (ensuring no false quarantine claims)
      String recommendedAction = data['recommendedAction'] as String? ?? 'Do not visit this URL.';
      if (recommendedAction.toLowerCase().contains('quarantined')) {
        recommendedAction = riskScore >= 50
            ? 'Recommended Action: Do not visit this URL. Threat signatures detected.'
            : 'Recommended Action: Exercise caution before interacting with this endpoint.';
      }

      return UrlScanResult(
        originalUrl: norm.normalizedUrl,
        defangedUrl: norm.defangedUrl,
        domain: norm.domain,
        protocol: norm.protocol,
        port: norm.port,
        path: norm.path,
        query: norm.query,
        riskScore: riskScore,
        threatLevel: ThreatLevel.fromScore(riskScore),
        confidence: confidence,
        summary: rawSummary,
        recommendedAction: recommendedAction,
        isHttps: isHttps,
        httpsMeaning: httpsMeaning,
        webpageInspected: false, // Strictly enforced: webpage was not inspected
        indicators: indicators,
        scannedAt: DateTime.now(),
        isQuickTest: isQuickTest,
      );
    } catch (e) {
      debugPrint('Schema validation exception on Gemini response: $e');
      return null;
    }
  }

  /// Transparent, deterministic evidence-based forensic scoring engine.
  /// Normalized to 0–100 scale:
  /// 0–19 SAFE / LOW
  /// 20–39 LOW RISK
  /// 40–59 MEDIUM RISK
  /// 60–79 HIGH RISK
  /// 80–100 CRITICAL
  UrlScanResult _performForensicAnalysis(
      NormalizedUrlData norm, {bool isQuickTest = false}) {
    int riskScore = 0;
    final List<UrlThreatIndicator> indicators = [];
    final List<String> reasonSnippets = [];

    final domain = norm.domain;
    final path = norm.path.toLowerCase();
    final query = norm.query.toLowerCase();
    final fullUriString = '${norm.domain}$path$query';
    final isHttps = norm.protocol == 'https';

    // 1. IP Address Host Check (+35 Points - High)
    final isRawIpv4 = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(domain);
    if (isRawIpv4) {
      riskScore += 35;
      indicators.add(const UrlThreatIndicator(
        name: 'Direct IP Host',
        severity: IndicatorSeverity.high,
        evidence: 'Host uses numerical IP address rather than verified DNS domain name',
        explanation: 'Legitimate services use registered domains. Direct IP hosts are frequently used by phishing kits to bypass domain reputation blocklists.',
        confidence: 96,
      ));
      reasonSnippets.add('Direct numerical IP host detected.');
    }

    // 2. Typosquatting / Character Substitution (+40 Points - Critical)
    final targetBrands = [
      'paypal',
      'chase',
      'wellsfargo',
      'bankofamerica',
      'citi',
      'apple',
      'google',
      'microsoft',
      'amazon',
      'netflix',
      'binance',
      'coinbase',
      'meta',
      'instagram',
      'whatsapp',
      'dropbox',
    ];

    bool isTyposquat = false;
    final typoReplacements = {'0': 'o', '1': 'l', 'vv': 'w', 'rn': 'm'};
    for (final entry in typoReplacements.entries) {
      if (domain.contains(entry.key)) {
        final deObfuscated = domain.replaceAll(entry.key, entry.value);
        for (final brand in targetBrands) {
          if (deObfuscated.contains(brand) && !domain.contains(brand)) {
            isTyposquat = true;
            riskScore += 40;
            indicators.add(UrlThreatIndicator(
              name: 'Typosquatting / Homograph Spoof',
              severity: IndicatorSeverity.critical,
              evidence: 'Character "${entry.key}" substituted for "${entry.value}" targeting brand "$brand"',
              explanation: 'Visual look-alike technique designed to trick victims into trusting a fraudulent domain.',
              confidence: 98,
            ));
            reasonSnippets.add('Typosquatting homograph mimicking "$brand".');
            break;
          }
        }
      }
      if (isTyposquat) break;
    }

    // 3. Brand Impersonation / Look-alike Domains (+35 Points - High)
    bool isLookalike = false;
    String matchedBrand = '';
    for (final brand in targetBrands) {
      if (domain.contains(brand)) {
        final isOfficial = domain == '$brand.com' ||
            domain.endsWith('.$brand.com') ||
            domain == '$brand.org' ||
            domain.endsWith('.$brand.org') ||
            domain == '$brand.net' ||
            domain.endsWith('.$brand.net');
        if (!isOfficial) {
          isLookalike = true;
          matchedBrand = brand;
          break;
        }
      }
    }

    if (isLookalike && !isTyposquat) {
      riskScore += 35;
      indicators.add(UrlThreatIndicator(
        name: 'Brand Impersonation',
        severity: IndicatorSeverity.high,
        evidence: 'Domain contains brand name "$matchedBrand" outside authorized official root domain',
        explanation: 'Unauthorized usage of trademarked brands in subdomains or secondary domains indicates spoofing.',
        confidence: 94,
      ));
      reasonSnippets.add('Unauthorized brand impersonation of "$matchedBrand".');
    }

    // 4. Excessive Subdomains (+20 Points - Medium)
    final domainParts = domain.split('.');
    if (domainParts.length >= 4) {
      riskScore += 20;
      indicators.add(UrlThreatIndicator(
        name: 'Excessive Subdomain Depth',
        severity: IndicatorSeverity.medium,
        evidence: 'Detected ${domainParts.length - 2} levels of nested subdomains',
        explanation: 'Attackers create deeply nested subdomains to push the actual deceptive parent domain off mobile address bars.',
        confidence: 91,
      ));
      reasonSnippets.add('Deeply nested subdomain structure.');
    }

    // 5. Suspicious / High-Risk TLD (+20 Points - Medium)
    final highRiskTlds = ['.xyz', '.top', '.buzz', '.cc', '.tk', '.fit', '.work', '.click', '.live', '.rest', '.surf', '.kim'];
    final matchedTld = highRiskTlds.firstWhere((tld) => domain.endsWith(tld), orElse: () => '');
    if (matchedTld.isNotEmpty) {
      riskScore += 20;
      indicators.add(UrlThreatIndicator(
        name: 'High-Risk Top-Level Domain',
        severity: IndicatorSeverity.medium,
        evidence: 'Domain uses high-abuse TLD "$matchedTld"',
        explanation: 'Disposable, low-cost top-level domains are heavily correlated with short-lived phishing campaigns.',
        confidence: 89,
      ));
      reasonSnippets.add('High-risk disposable TLD ($matchedTld).');
    }

    // 6. Suspicious Domain Structure (Hyphens & Deceptive Prefixes) (+15 Points - Low/Medium)
    final hyphenCount = '-'.allMatches(domain).length;
    if (hyphenCount >= 2) {
      riskScore += 15;
      indicators.add(UrlThreatIndicator(
        name: 'Deceptive Domain Structure',
        severity: IndicatorSeverity.low,
        evidence: 'Domain contains $hyphenCount hyphens with security prefix structuring',
        explanation: 'Multiple hyphens are commonly used to create complex pseudo-official domain names (e.g. secure-login-update).',
        confidence: 86,
      ));
    }

    // 7. Credential-Harvesting Keywords in Path / Query (+25 Points - High)
    final credentialKeywords = ['password', 'credential', 'auth', 'token', 'otp', '2fa', 'pin', 'passcode', 'secret', 'seedphrase'];
    final matchedCreds = credentialKeywords.where((kw) => path.contains(kw) || query.contains(kw)).toList();
    if (matchedCreds.isNotEmpty) {
      riskScore += 25;
      indicators.add(UrlThreatIndicator(
        name: 'Credential Harvesting Pattern',
        severity: IndicatorSeverity.high,
        evidence: 'Found authentication secret parameters: ${matchedCreds.join(', ')}',
        explanation: 'The URL path or query string directly targets authentication secrets or multi-factor one-time passcodes.',
        confidence: 95,
      ));
      reasonSnippets.add('Credential-soliciting path parameters (${matchedCreds.first}).');
    }

    // 8. Deceptive Authentication Terminology (+15 Points - Medium)
    final authLures = ['login', 'signin', 'verify', 'account', 'billing', 'invoice', 'checkout', 'wallet', 'recover', 'banking', 'update'];
    final matchedLures = authLures.where((lure) => fullUriString.contains(lure)).toList();
    if (matchedLures.isNotEmpty && matchedCreds.isEmpty) {
      riskScore += 15;
      indicators.add(UrlThreatIndicator(
        name: 'Authentication Lure Keywords',
        severity: IndicatorSeverity.medium,
        evidence: 'URL contains sensitive account action terms: ${matchedLures.take(3).join(', ')}',
        explanation: 'Sensitive intent terminology detected in URL structure.',
        confidence: 88,
      ));
    }

    // 9. URL Obfuscation & Authority Tricks (+30 Points - High)
    bool hasObfuscation = false;
    String obfuscationEvidence = '';
    if (norm.normalizedUrl.contains('@')) {
      hasObfuscation = true;
      obfuscationEvidence = 'Uses "@" symbol in URL authority to disguise true destination';
    } else if ('%'.allMatches(norm.normalizedUrl).length >= 4) {
      hasObfuscation = true;
      obfuscationEvidence = 'Heavy percent-encoding obfuscation detected in URL string';
    } else if (norm.port != null && norm.port != 80 && norm.port != 443 && norm.port != 8080 && norm.port != 8443) {
      hasObfuscation = true;
      obfuscationEvidence = 'Non-standard port (${norm.port}) assigned to web endpoint';
    }

    if (hasObfuscation) {
      riskScore += 30;
      indicators.add(UrlThreatIndicator(
        name: 'URL Obfuscation',
        severity: IndicatorSeverity.high,
        evidence: obfuscationEvidence,
        explanation: 'Obfuscation techniques are designed to bypass perimeter inspection filters.',
        confidence: 93,
      ));
      reasonSnippets.add('URL obfuscation technique detected.');
    }

    // 10. Open Redirect Vector (+20 Points - Medium)
    if (query.contains('url=http') || query.contains('redirect=http') || query.contains('target=http') || query.contains('next=http')) {
      riskScore += 20;
      indicators.add(const UrlThreatIndicator(
        name: 'Open Redirect Vector',
        severity: IndicatorSeverity.medium,
        evidence: 'Query parameter contains secondary destination URL',
        explanation: 'Open redirect parameters can bounce victims from a reputable site to an untrusted malicious page.',
        confidence: 90,
      ));
      reasonSnippets.add('Open redirect parameter detected.');
    }

    // 11. Transport Security (Plaintext HTTP vs HTTPS)
    if (!isHttps) {
      riskScore += 15;
      indicators.add(const UrlThreatIndicator(
        name: 'Unencrypted HTTP Protocol',
        severity: IndicatorSeverity.low,
        evidence: 'Insecure plaintext HTTP (port 80) active without TLS encryption',
        explanation: 'Traffic is sent in plaintext. Sensitive credentials and cookies can be intercepted via network eavesdropping.',
        confidence: 99,
      ));
      reasonSnippets.add('Unencrypted plaintext HTTP protocol.');
    } else {
      indicators.add(const UrlThreatIndicator(
        name: 'Encrypted Transport (HTTPS)',
        severity: IndicatorSeverity.info,
        evidence: 'TLS/SSL connection is active',
        explanation: 'Connection encrypted; does NOT prove that the website or its owner is legitimate.',
        confidence: 99,
      ));
    }

    // Normalize final score to 0–100
    final finalScore = riskScore.clamp(0, 100);
    final ThreatLevel finalLevel = ThreatLevel.fromScore(finalScore);

    // Calculate confidence based on evidence count
    final int confidence = (85 + (indicators.length * 2.5)).clamp(88, 98).toInt();

    // Plain English summary
    final String summary;
    if (reasonSnippets.isEmpty) {
      summary = 'No anomalous or deceptive patterns identified in URL syntax. Standard lexical structure observed.';
    } else {
      summary = 'Forensic evaluation flagged multiple indicators: ${reasonSnippets.join(' ')}';
    }

    // Recommended Action (NO FALSE QUARANTINE CLAIMS)
    final String recommendedAction;
    if (finalScore >= 80) {
      recommendedAction = 'Recommended Action: Do not visit this URL. Critical threat signatures detected.';
    } else if (finalScore >= 60) {
      recommendedAction = 'Recommended Action: Do not visit this URL. High-risk indicators detected.';
    } else if (finalScore >= 40) {
      recommendedAction = 'Recommended Action: Proceed with extreme caution. Verify the official web address directly.';
    } else if (finalScore >= 20) {
      recommendedAction = 'Recommended Action: Exercise caution before interacting with this endpoint.';
    } else {
      recommendedAction = 'Recommended Action: Endpoint exhibits standard nominal structure. Standard continuous monitoring active.';
    }

    return UrlScanResult(
      originalUrl: norm.normalizedUrl,
      defangedUrl: norm.defangedUrl,
      domain: norm.domain,
      protocol: norm.protocol,
      port: norm.port,
      path: norm.path,
      query: norm.query,
      riskScore: finalScore,
      threatLevel: finalLevel,
      confidence: confidence,
      summary: summary,
      recommendedAction: recommendedAction,
      isHttps: isHttps,
      httpsMeaning: isHttps
          ? 'Connection encrypted; does not prove website is legitimate.'
          : 'Insecure unencrypted HTTP transport.',
      webpageInspected: false,
      indicators: indicators,
      scannedAt: DateTime.now(),
      isQuickTest: isQuickTest,
    );
  }
}
