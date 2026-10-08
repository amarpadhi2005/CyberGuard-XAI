import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/threat_history_item.dart';
import '../../domain/repositories/threat_history_repository.dart';

class ThreatHistoryRepositoryImpl implements ThreatHistoryRepository {
  FirebaseFirestore? _firestore;
  final List<ThreatHistoryItem> _localCache = [];

  ThreatHistoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<List<ThreatHistoryItem>> getThreatHistory(String userId) async {
    try {
      final db = _db;
      if (db != null) {
        final snapshot = await db
          .collection('users')
          .doc(userId)
          .collection('threat_history')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            return ThreatHistoryItem.fromMap(data);
          }).toList();

          _localCache
            ..clear()
            ..addAll(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('Firestore getThreatHistory fallback to local: $e');
    }

    if (_localCache.isEmpty) {
      return await seedInitialDemoThreats(userId);
    }
    return List.unmodifiable(_localCache);
  }

  @override
  Future<void> saveThreatItem(ThreatHistoryItem item, String userId) async {
    // Add to local cache immediately
    _localCache.removeWhere((i) => i.id == item.id);
    _localCache.insert(0, item);

    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('threat_history')
            .doc(item.id)
            .set(item.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore saveThreatItem warning: $e');
    }
  }

  @override
  Future<void> deleteThreatItem(String itemId, String userId) async {
    _localCache.removeWhere((i) => i.id == itemId);

    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('threat_history')
            .doc(itemId)
            .delete();
      }
    } catch (e) {
      debugPrint('Firestore deleteThreatItem warning: $e');
    }
  }

  @override
  Future<void> clearThreatHistory(String userId) async {
    _localCache.clear();

    try {
      final db = _db;
      if (db != null) {
        final snapshot = await db
            .collection('users')
            .doc(userId)
            .collection('threat_history')
            .get();

        final batch = db.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Firestore clearThreatHistory warning: $e');
    }
  }

  @override
  Future<List<ThreatHistoryItem>> seedInitialDemoThreats(String userId) async {
    final now = DateTime.now();

    final demoItems = [
      // 1. Website
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 1000}',
        title: 'https://secure-chase-update.com/verify-account',
        category: ThreatCategory.website,
        threatType: 'Banking Credential Harvester',
        riskScore: 95,
        severity: ThreatSeverity.critical,
        reason:
            'Typosquatted domain mimicking JPMorgan Chase. Zero-day SSL certificate registered 48 hours ago from offshore anonymous registrar.',
        recommendedAction:
            'ISOLATE & BLOCK. Do not input login credentials or OTP codes.',
        source: 'Gemini 2.5 Flash',
        timestamp: now.subtract(const Duration(minutes: 18)),
        metadata: {'domain': 'secure-chase-update.com', 'ip': '185.220.101.44'},
      ),

      // 2. QR Code
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 2000}',
        title: 'https://pay-meter-city.parking.xyz/terminal?id=8831',
        category: ThreatCategory.qr,
        threatType: 'Quishing / Fraudulent Meter Overlay',
        riskScore: 88,
        severity: ThreatSeverity.critical,
        reason:
            'QR code points to an unofficial third-party payment gateway disguised as city municipal parking. Requests direct credit card CVV and billing address.',
        recommendedAction:
            'DO NOT PAY. Report physical QR sticker tampering to municipal authorities.',
        source: 'AI QR Sentinel',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 12)),
        metadata: {'qr_type': 'Dynamic URL', 'location': 'Downtown Bay'},
      ),

      // 3. Phone Call
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 3000}',
        title: '+1 (800) 492-9182',
        category: ThreatCategory.phone,
        threatType: 'IRS Extortion & Law Enforcement Spoof',
        riskScore: 96,
        severity: ThreatSeverity.critical,
        reason:
            'Automated robocall impersonating IRS CID officers threatening asset seizure. Outbound caller-ID spoofing on Bandwidth VoIP gateway.',
        recommendedAction:
            'BLOCK & TERMINATE. Federal agencies never demand immediate cryptocurrency or prepaid payments.',
        source: 'Telecom STIR/SHAKEN',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 40)),
        metadata: {'carrier': 'VoIP Gateway', 'reports': 2841},
      ),

      // 4. Email
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 4000}',
        title: 'Urgent Wire Transfer Authorization (CEO Executive Request)',
        category: ThreatCategory.email,
        threatType: 'Business Email Compromise (BEC)',
        riskScore: 91,
        severity: ThreatSeverity.critical,
        reason:
            'Display name spoofing executive management. Domain has mismatched SPF and failing DMARC policy. Employs urgency cues requesting \$42,000 wire.',
        recommendedAction:
            'FLAG AS PHISHING. Authenticate request out-of-band via telephone before executing financial transfers.',
        source: 'Gemini 2.5 Flash',
        timestamp: now.subtract(const Duration(hours: 14)),
        metadata: {'sender': 'ceo@executive-internal-corp.net', 'priority': 'High'},
      ),

      // 5. Notification
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 5000}',
        title: 'HDFC Bank: Mandatory KYC Pan card verification needed',
        category: ThreatCategory.notification,
        threatType: 'Smishing / Malicious APK Delivery',
        riskScore: 84,
        severity: ThreatSeverity.high,
        reason:
            'Urgent account suspension lure containing shortened bit.ly URL directing victim to download unverified banking utility APK.',
        recommendedAction:
            'DISMISS & REPORT. Banks never circulate direct application download links via SMS or push alerts.',
        source: 'AI Notification Sentinel',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        metadata: {'app': 'Messaging', 'urgency': 'Immediate Action'},
      ),

      // 6. Deepfake Forensic Scan
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 5500}',
        title: 'biometric_face_swap_id_scan.jpg',
        category: ThreatCategory.deepfake,
        threatType: 'Synthetic Identity Deepfake (GAN Face Swap)',
        riskScore: 92,
        severity: ThreatSeverity.critical,
        reason:
            'Prototype forensic model detected 3.42σ facial boundary contrast variance, divergent ocular reflections, and Fourier generative micro-texture smoothing.',
        recommendedAction:
            'REJECT BIOMETRIC KYC. Request dynamic live challenge verification.',
        source: 'Forensic Deepfake Model',
        timestamp: now.subtract(const Duration(hours: 18)),
        metadata: {'model': 'Heuristic Deepfake Forensics', 'anomalies_detected': 3},
      ),

      // 7. Safe Website Scan
      ThreatHistoryItem(
        id: 'THREAT-${now.millisecondsSinceEpoch - 6000}',
        title: 'https://github.com/security/cyberguard-xai',
        category: ThreatCategory.website,
        threatType: 'Verified Software Repository',
        riskScore: 2,
        severity: ThreatSeverity.safe,
        reason:
            'Domain is verified and owned by GitHub Inc. Extended Validation SSL active. Clean reputation across Google Safe Browsing and VirusTotal.',
        recommendedAction: 'SAFE TO ACCESS. Legitimate developer asset.',
        source: 'Gemini 2.5 Flash',
        timestamp: now.subtract(const Duration(days: 2)),
        metadata: {'domain': 'github.com', 'ssl_valid': true},
      ),
    ];

    _localCache
      ..clear()
      ..addAll(demoItems);

    // Save to Firestore in background
    for (final item in demoItems) {
      saveThreatItem(item, userId);
    }

    return demoItems;
  }
}
