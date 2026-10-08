import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/qr_scan_result.dart';
import '../../domain/repositories/qr_scanner_repository.dart';
import '../services/gemini_qr_service.dart';

class QrScannerRepositoryImpl implements QrScannerRepository {
  final GeminiQrService _service;
  FirebaseFirestore? _firestore;
  final List<QrScanResult> _history = [];

  QrScannerRepositoryImpl({
    GeminiQrService? service,
    FirebaseFirestore? firestore,
  })  : _service = service ?? GeminiQrService(),
        _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<QrScanResult> processQrPayload(String rawPayload) async {
    final result = await _service.analyzeQrPayload(rawPayload);
    _history.insert(0, result);
    if (_history.length > 20) {
      _history.removeLast();
    }

    _saveToFirestore(result);

    return result;
  }

  Future<void> _saveToFirestore(QrScanResult result) async {
    try {
      final db = _db;
      if (db == null) return;
      final scanId = 'THREAT-QR-${result.scannedAt.millisecondsSinceEpoch}';
      const userId = 'DEMO_USER_001';

      // 1. Save to qr_scans
      await db
          .collection('users')
          .doc(userId)
          .collection('qr_scans')
          .doc(scanId)
          .set({
        'raw_payload': result.rawPayload,
        'extracted_url': result.extractedUrl,
        'verdict': result.verdict.name,
        'risk_score': result.riskScore,
        'reason': result.reason,
        'recommended_action': result.recommendedAction,
        'is_https': result.isHttps,
        'threat_signals': result.threatSignals,
        'scanned_at': Timestamp.fromDate(result.scannedAt),
      }, SetOptions(merge: true));

      // 2. Save to unified threat_history
      String severity = 'safe';
      if (result.verdict == QrSafetyVerdict.dangerous) {
        severity = 'critical';
      } else if (result.verdict == QrSafetyVerdict.suspicious) {
        severity = 'high';
      }

      await db
          .collection('users')
          .doc(userId)
          .collection('threat_history')
          .doc(scanId)
          .set({
        'id': scanId,
        'title': result.extractedUrl.isNotEmpty
            ? result.extractedUrl
            : result.rawPayload,
        'category': 'qr',
        'threat_type': result.verdict == QrSafetyVerdict.safe
            ? 'Safe Verified QR Code'
            : (result.verdict == QrSafetyVerdict.suspicious
                ? 'Suspicious QR Redirection'
                : 'Malicious Quishing Payload'),
        'risk_score': result.riskScore,
        'severity': severity,
        'reason': result.reason,
        'recommended_action': result.recommendedAction,
        'source': 'Gemini 2.5 Flash / QR Sentinel',
        'timestamp': result.scannedAt.toIso8601String(),
        'metadata': {
          'https': result.isHttps,
          'signals': result.threatSignals,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore qr scan save warning: $e');
    }
  }

  @override
  Future<List<QrScanResult>> getRecentQrScans() async {
    return List.unmodifiable(_history);
  }
}
