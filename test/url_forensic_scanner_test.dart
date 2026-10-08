import 'package:flutter_test/flutter_test.dart';
import 'package:cyberguard_xai/features/scanner/data/services/url_forensic_utils.dart';
import 'package:cyberguard_xai/features/scanner/data/services/gemini_url_service.dart';
import 'package:cyberguard_xai/features/scanner/domain/entities/url_scan_result.dart';

void main() {
  group('1. URL Validation & Normalization (Single Source of Truth)', () {
    test('Rejects empty or whitespace-only input', () {
      expect(
        () => UrlForensicUtils.validateRawInput('   '),
        throwsA(isA<UrlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Please enter a URL'),
        )),
      );
    });

    test('Rejects dangerous protocols like javascript: or data:', () {
      expect(
        () => UrlForensicUtils.validateRawInput('javascript:alert(1)'),
        throwsA(isA<UrlValidationException>().having(
          (e) => e.message,
          'message',
          contains('Unsupported protocol'),
        )),
      );
    });

    test('Normalizes missing scheme to https://', () {
      final norm = UrlForensicUtils.normalize('example-domain.com/path');
      expect(norm.normalizedUrl, equals('https://example-domain.com/path'));
      expect(norm.domain, equals('example-domain.com'));
      expect(norm.protocol, equals('https'));
    });

    test('Rejects invalid hostnames without TLD or invalid characters', () {
      expect(
        () => UrlForensicUtils.normalize('not_a_valid_hostname'),
        throwsA(isA<UrlValidationException>()),
      );
    });

    test('Canonicalizes scheme and host to lowercase while preserving path case', () {
      final norm = UrlForensicUtils.normalize('HTTP://EXAMPLE.COM/SecureLogin/Path?Token=XYZ');
      expect(norm.normalizedUrl, equals('http://example.com/SecureLogin/Path?Token=XYZ'));
      expect(norm.protocol, equals('http'));
      expect(norm.domain, equals('example.com'));
      expect(norm.path, equals('/SecureLogin/Path'));
      expect(norm.query, equals('?Token=XYZ'));
    });
  });

  group('2. Correct URL Defanging', () {
    test('Defangs https:// to hxxps:// and dots in host to [.]', () {
      final defanged = UrlForensicUtils.defangUrl('https://example.com/login');
      expect(defanged, equals('hxxps://example[.]com/login'));
      // Never produces malformed https://hxxp:// combinations
      expect(defanged.contains('https://hxxp://'), isFalse);
    });

    test('Defangs http:// to hxxp:// correctly', () {
      final defanged = UrlForensicUtils.defangUrl('http://paypa1-security.com/auth/otp');
      expect(defanged, equals('hxxp://paypa1-security[.]com/auth/otp'));
    });

    test('Defangs complex nested subdomains', () {
      final defanged = UrlForensicUtils.defangUrl('https://sub.portal.bank.example.co.uk/verify');
      expect(defanged, equals('hxxps://sub[.]portal[.]bank[.]example[.]co[.]uk/verify'));
    });
  });

  group('3. Dynamic Risk Scoring & Evidence Engine', () {
    late GeminiUrlService service;

    setUp(() {
      service = GeminiUrlService();
    });

    test('Analyzes EXACT submitted URL without replacing it with sample URLs', () async {
      const targetUrl = 'https://my-custom-test-domain.org/resources';
      final result = await service.analyzeUrl(targetUrl);

      expect(result.originalUrl, equals(targetUrl));
      expect(result.domain, equals('my-custom-test-domain.org'));
      expect(result.defangedUrl, equals('hxxps://my-custom-test-domain[.]org/resources'));
      // Verifies originalUrl is never overwritten by defangedUrl
      expect(result.originalUrl, isNot(equals(result.defangedUrl)));
      // Verifies no hardcoded Chase Bank URL was injected
      expect(result.originalUrl.contains('chase'), isFalse);
    });

    test('Legitimate domain scores nominal (0-19 SAFE / LOW)', () async {
      final result = await service.analyzeUrl('https://google.com');

      expect(result.riskScore, lessThan(20));
      expect(result.threatLevel, equals(ThreatLevel.safe));
      expect(result.isHttps, isTrue);
    });

    test('Typosquatted domain with credential harvesting scores CRITICAL (80-100)', () async {
      final result = await service.analyzeUrl('http://paypa1-security-verification.com/auth/otp');

      expect(result.riskScore, greaterThanOrEqualTo(80));
      expect(result.threatLevel, equals(ThreatLevel.critical));

      // Verifies indicators contain actual observed evidence
      final typosquat = result.indicators.firstWhere((i) => i.name.contains('Typosquatting'));
      expect(typosquat.evidence, contains('1'));
      expect(typosquat.evidence, contains('paypal'));

      final creds = result.indicators.firstWhere((i) => i.name.contains('Credential'));
      expect(creds.evidence, contains('otp'));
    });

    test('Direct IP host triggers High severity host indicator', () async {
      final result = await service.analyzeUrl('http://192.168.1.1/admin/login');

      expect(result.indicators.any((i) => i.name == 'Direct IP Host'), isTrue);
      expect(result.riskScore, greaterThanOrEqualTo(35));
    });
  });

  group('4. HTTPS Must Not Mean Safe', () {
    test('HTTPS does not reduce threat score for malicious phishing domains', () async {
      final service = GeminiUrlService();

      // Same phishing vector over HTTP and HTTPS
      final httpResult = await service.analyzeUrl('http://paypa1-security.com/auth/otp');
      final httpsResult = await service.analyzeUrl('https://paypa1-security.com/auth/otp');

      // Both should be flagged as high/critical threats despite HTTPS
      expect(httpResult.riskScore, greaterThanOrEqualTo(65));
      expect(httpsResult.riskScore, greaterThanOrEqualTo(65));
      expect(httpsResult.threatLevel == ThreatLevel.high || httpsResult.threatLevel == ThreatLevel.critical, isTrue);

      // HTTPS disclosure confirms transport encryption does not prove legitimacy
      expect(httpsResult.httpsMeaning, contains('does not prove'));
    });
  });

  group('5. Evidence Separation & False Claims Removal', () {
    test('Webpage inspected is strictly FALSE (no remote DOM execution)', () async {
      final service = GeminiUrlService();
      final result = await service.analyzeUrl('https://example.com/test');

      expect(result.webpageInspected, isFalse);
    });

    test('Never claims domain was "quarantined" when only detected', () async {
      final service = GeminiUrlService();
      final result = await service.analyzeUrl('http://paypa1-security-verification.com/login');

      expect(result.recommendedAction.toLowerCase().contains('quarantined'), isFalse);
      expect(result.recommendedAction, contains('Do not visit this URL'));
    });
  });
}
