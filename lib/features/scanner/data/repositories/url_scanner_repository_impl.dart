import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/url_scan_result.dart';
import '../../domain/repositories/url_scanner_repository.dart';
import '../services/gemini_url_service.dart';

class UrlScannerRepositoryImpl implements UrlScannerRepository {
  final GeminiUrlService _service;
  FirebaseFirestore? _firestore;
  final List<UrlScanResult> _history = [];

  UrlScannerRepositoryImpl({
    GeminiUrlService? service,
    FirebaseFirestore? firestore,
  })  : _service = service ?? GeminiUrlService(),
        _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<UrlScanResult> scanUrl(String url, {bool isQuickTest = false}) async {
    final result = await _service.analyzeUrl(url, isQuickTest: isQuickTest);
    _history.insert(0, result);
    if (_history.length > 20) {
      _history.removeLast();
    }

    // Persist to Cloud Firestore threat history asynchronously
    _saveToFirestore(result);

    return result;
  }

  Future<void> _saveToFirestore(UrlScanResult result) async {
    try {
      final db = _db;
      if (db == null) return;
      final scanId = 'THREAT-URL-${result.scannedAt.millisecondsSinceEpoch}';
      const userId = 'DEMO_USER_001';

      // 1. Save to url_scans collection
      await db
          .collection('users')
          .doc(userId)
          .collection('url_scans')
          .doc(scanId)
          .set({
        'original_url': result.originalUrl,
        'defanged_url': result.defangedUrl,
        'domain': result.domain,
        'risk_score': result.riskScore,
        'threat_level': result.threatLevel.name,
        'confidence': result.confidence,
        'summary': result.summary,
        'recommended_action': result.recommendedAction,
        'is_https': result.isHttps,
        'https_meaning': result.httpsMeaning,
        'webpage_inspected': result.webpageInspected,
        'is_quick_test': result.isQuickTest,
        'indicators': result.indicators.map((i) => i.toJson()).toList(),
        'scanned_at': Timestamp.fromDate(result.scannedAt),
      }, SetOptions(merge: true));

      // 2. Save to unified threat_history collection
      await db
          .collection('users')
          .doc(userId)
          .collection('threat_history')
          .doc(scanId)
          .set({
        'id': scanId,
        'title': result.originalUrl,
        'category': 'website',
        'threat_type': result.threatLevel == ThreatLevel.safe
            ? 'Verified Web Destination'
            : 'Suspicious Web Domain',
        'risk_score': result.riskScore,
        'severity': result.threatLevel.name,
        'reason': result.summary,
        'recommended_action': result.recommendedAction,
        'source': 'Gemini 2.5 Flash / Forensic Sentinel',
        'timestamp': result.scannedAt.toIso8601String(),
        'metadata': {
          'domain': result.domain,
          'https': result.isHttps,
          'defanged_url': result.defangedUrl,
          'confidence': result.confidence,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore url scan save warning: $e');
    }
  }

  @override
  Future<List<UrlScanResult>> getRecentScans() async {
    return List.unmodifiable(_history);
  }
}
