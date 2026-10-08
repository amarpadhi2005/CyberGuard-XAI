import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cyber_twin_state.dart';
import '../../domain/entities/threat_dna_campaign.dart';
import '../../domain/repositories/cyber_twin_repository.dart';
import '../services/threat_correlation_engine.dart';

class CyberTwinRepositoryImpl implements CyberTwinRepository {
  FirebaseFirestore? _firestore;
  final ThreatCorrelationEngine _engine;

  CyberTwinRepositoryImpl({
    FirebaseFirestore? firestore,
    ThreatCorrelationEngine? engine,
  })  : _firestore = firestore,
        _engine = engine ?? ThreatCorrelationEngine();

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<CyberTwinState> evaluateThreatCorrelation({
    required String userId,
    int timeWindowHours = 24,
  }) async {
    final List<Map<String, dynamic>> rawEvents = [];

    try {
      final db = _db;
      if (db != null) {
        final snapshot = await db
            .collection('users')
            .doc(userId)
            .collection('threat_history')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();

        for (final doc in snapshot.docs) {
          rawEvents.add(doc.data());
        }
      }
    } catch (e) {
      debugPrint('Firestore threat_history query fallback for correlation: $e');
    }

    final campaign = _engine.correlateMultiVectorEvents(
      rawEvents: rawEvents,
      timeWindowHours: timeWindowHours,
      userId: userId,
    );

    return CyberTwinState(
      guardianName: 'CYBER TWIN // AEGIS-X',
      status: campaign.eventCount >= 2
          ? CyberTwinStatus.alertElevated
          : CyberTwinStatus.activeGuardian,
      neuralSyncLevel: 0.994,
      timeWindowHours: timeWindowHours,
      activeCampaign: campaign,
      isCoordinatedScamDetected: campaign.eventCount >= 2,
      alertMessage: campaign.eventCount >= 2
          ? 'Possible coordinated scam activity detected.'
          : 'Perimeter monitored. No coordinated campaigns identified.',
      lastCorrelationCheck: DateTime.now(),
    );
  }

  @override
  Future<ThreatDnaCampaign> simulateCampaignStage({
    required int stageIndex,
    required String userId,
  }) async {
    return _engine.correlateMultiVectorEvents(
      rawEvents: [],
      maxStageLimit: stageIndex,
      userId: userId,
    );
  }

  @override
  Future<void> acknowledgeCampaign(String campaignId, String userId) async {
    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('mitigated_campaigns')
            .doc(campaignId)
            .set({
          'campaign_id': campaignId,
          'mitigated_at': Timestamp.now(),
          'status': 'MITIGATED_BY_USER',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore acknowledgeCampaign fallback: $e');
    }
  }
}
