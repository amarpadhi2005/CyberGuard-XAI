import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/call_scan_result.dart';
import '../../domain/repositories/scam_call_repository.dart';
import '../services/gemini_call_service.dart';

class ScamCallRepositoryImpl implements ScamCallRepository {
  final GeminiCallService _service;
  FirebaseFirestore? _firestore;
  final List<CallScanResult> _localCache = [];

  ScamCallRepositoryImpl({
    GeminiCallService? service,
    FirebaseFirestore? firestore,
  })  : _service = service ?? GeminiCallService(),
        _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<CallScanResult> analyzePhoneNumber(String phoneNumber) async {
    final result = await _service.analyzePhoneNumber(phoneNumber);
    _localCache.insert(0, result);
    return result;
  }

  @override
  Future<void> saveCallScan(CallScanResult scan, String userId) async {
    try {
      final db = _db;
      if (db == null) return;
      await db
          .collection('users')
          .doc(userId)
          .collection('call_scans')
          .doc(scan.id)
          .set({
        'id': scan.id,
        'phone_number': scan.phoneNumber,
        'formatted_number': scan.formattedNumber,
        'caller_name': scan.callerName,
        'carrier': scan.carrier,
        'location': scan.location,
        'verdict': scan.verdict.name,
        'risk_score': scan.riskScore,
        'caller_category': scan.callerCategory,
        'recommended_action': scan.recommendedAction,
        'reports_count': scan.reportsCount,
        'threat_signals': scan.threatSignals,
        'explanation': scan.explanation,
        'is_blocked': scan.isBlocked,
        'scanned_at': Timestamp.fromDate(scan.timestamp),
      }, SetOptions(merge: true));

      // Also sync to unified threat_history
      String severity = 'safe';
      if (scan.verdict == CallVerdict.fraud) {
        severity = 'critical';
      } else if (scan.verdict == CallVerdict.spam) {
        severity = 'high';
      } else if (scan.verdict == CallVerdict.unknown) {
        severity = 'medium';
      }

      await db
          .collection('users')
          .doc(userId)
          .collection('threat_history')
          .doc(scan.id)
          .set({
        'id': scan.id,
        'title': '${scan.callerName} (${scan.formattedNumber})',
        'category': 'phone',
        'threat_type': scan.callerCategory,
        'risk_score': scan.riskScore,
        'severity': severity,
        'reason': scan.explanation,
        'recommended_action': scan.recommendedAction,
        'source': 'Gemini 2.5 Flash / STIR/SHAKEN',
        'timestamp': scan.timestamp.toIso8601String(),
        'metadata': {
          'carrier': scan.carrier,
          'location': scan.location,
          'reports': scan.reportsCount,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save call scan fallback: $e');
    }
  }

  @override
  Future<List<CallScanResult>> getScanHistory(String userId) async {
    try {
      final db = _db;
      if (db == null) return List.unmodifiable(_localCache);
      final snapshot = await db
          .collection('users')
          .doc(userId)
          .collection('call_scans')
          .orderBy('scanned_at', descending: true)
          .limit(25)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return CallScanResult(
            id: data['id'] as String? ?? doc.id,
            phoneNumber: data['phone_number'] as String? ?? '',
            formattedNumber: data['formatted_number'] as String? ?? '',
            callerName: data['caller_name'] as String? ?? 'Unknown Caller',
            carrier: data['carrier'] as String? ?? 'Telecom Carrier',
            location: data['location'] as String? ?? 'Unverified Location',
            verdict: _parseVerdict(data['verdict']),
            riskScore: (data['risk_score'] as num?)?.toInt() ?? 50,
            callerCategory: data['caller_category'] as String? ?? 'Telephony Lookup',
            recommendedAction: data['recommended_action'] as String? ?? 'Exercise caution.',
            reportsCount: (data['reports_count'] as num?)?.toInt() ?? 0,
            threatSignals: List<String>.from(data['threat_signals'] as List? ?? []),
            explanation: data['explanation'] as String? ?? '',
            isBlocked: data['is_blocked'] as bool? ?? false,
            timestamp: (data['scanned_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore load call scans fallback: $e');
    }

    return List.unmodifiable(_localCache);
  }

  @override
  Future<void> blockPhoneNumber(String phoneNumber, String userId) async {
    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('blocked_numbers')
            .doc(phoneNumber.replaceAll('+', ''))
            .set({
          'phone_number': phoneNumber,
          'blocked_at': Timestamp.now(),
          'source': 'Truecaller Scam Prototype',
        });
      }
    } catch (e) {
      debugPrint('Firestore block number fallback: $e');
    }
  }

  CallVerdict _parseVerdict(dynamic raw) {
    for (final v in CallVerdict.values) {
      if (v.name == raw) return v;
    }
    return CallVerdict.unknown;
  }
}
