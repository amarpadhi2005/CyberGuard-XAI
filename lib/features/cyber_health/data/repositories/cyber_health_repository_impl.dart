import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cyber_health_score.dart';
import '../../domain/entities/score_factor_event.dart';
import '../../domain/repositories/cyber_health_repository.dart';

class CyberHealthRepositoryImpl implements CyberHealthRepository {
  FirebaseFirestore? _firestore;
  CyberHealthScore? _cachedScore;

  CyberHealthRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<CyberHealthScore> getHealthScore(String userId) async {
    try {
      final db = _db;
      if (db != null) {
        final doc = await db
            .collection('users')
            .doc(userId)
            .collection('cyber_health')
            .doc('current')
            .get();

        if (doc.exists && doc.data() != null) {
          final score = CyberHealthScore.fromMap(doc.data()!);
          _cachedScore = score;
          return score;
        }
      }
    } catch (e) {
      debugPrint('Firestore getHealthScore fallback to memory: $e');
    }

    if (_cachedScore != null) {
      return _cachedScore!;
    }

    // Default baseline 880 / 1000 with seed events
    final baseline = _generateBaselineScore();
    _cachedScore = baseline;
    saveHealthScore(baseline, userId);
    return baseline;
  }

  @override
  Future<void> saveHealthScore(CyberHealthScore score, String userId) async {
    _cachedScore = score;
    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('cyber_health')
            .doc('current')
            .set(score.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore saveHealthScore warning: $e');
    }
  }

  @override
  Future<CyberHealthScore> applyFactor(
      ScoreFactorEvent event, String userId) async {
    final current = await getHealthScore(userId);
    final newScoreValue =
        (current.score + event.pointsDelta).clamp(0, CyberHealthScore.maxScore);

    final updatedHistory = List<ScoreFactorEvent>.from(current.history)
      ..insert(0, event);
    if (updatedHistory.length > 30) {
      updatedHistory.removeLast();
    }

    final isShield = event.type == ScoreFactorType.enableProtection
        ? true
        : (event.type == ScoreFactorType.disableProtection
            ? false
            : current.isShieldActive);

    final updated = current.copyWith(
      score: newScoreValue,
      isShieldActive: isShield,
      history: updatedHistory,
      lastUpdated: DateTime.now(),
    );

    await saveHealthScore(updated, userId);
    return updated;
  }

  @override
  Future<CyberHealthScore> resetScore(String userId) async {
    final baseline = _generateBaselineScore();
    await saveHealthScore(baseline, userId);
    return baseline;
  }

  CyberHealthScore _generateBaselineScore() {
    final now = DateTime.now();
    final history = [
      ScoreFactorEvent(
        id: 'EVT-01',
        type: ScoreFactorType.enableProtection,
        pointsDelta: 75,
        title: 'Zero-Trust Shield Protection Active',
        description: 'Device runtime defense and AI telemetry enabled.',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ScoreFactorEvent(
        id: 'EVT-02',
        type: ScoreFactorType.scanWebsite,
        pointsDelta: 35,
        title: 'Inspected Web Domain with Gemini',
        description: 'github.com verified clean and authentic.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ScoreFactorEvent(
        id: 'EVT-03',
        type: ScoreFactorType.reportScam,
        pointsDelta: 30,
        title: 'Reported Robocall Extortion Campaign',
        description: '+1 (800) 492-9182 flagged to federal threat intelligence.',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      ScoreFactorEvent(
        id: 'EVT-04',
        type: ScoreFactorType.suspiciousActivityDetected,
        pointsDelta: -60,
        title: 'SMS Smishing Attempt Detected',
        description: 'Phishing SMS intercepted before user engagement.',
        timestamp: now.subtract(const Duration(hours: 12)),
      ),
    ];

    const initialScore = 880;
    return CyberHealthScore(
      score: initialScore,
      isShieldActive: true,
      history: history,
      suggestions:
          CyberHealthScore.generateDynamicSuggestions(initialScore, true),
      lastUpdated: now,
    );
  }
}
