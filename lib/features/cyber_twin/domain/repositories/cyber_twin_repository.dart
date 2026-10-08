import '../entities/cyber_twin_state.dart';
import '../entities/threat_dna_campaign.dart';

abstract class CyberTwinRepository {
  /// Evaluates stored Firestore threat history to correlate events into Threat DNA campaigns
  Future<CyberTwinState> evaluateThreatCorrelation({
    required String userId,
    int timeWindowHours = 24,
  });

  /// Simulates progressive stages of a multi-vector attack for hackathon demonstration
  Future<ThreatDnaCampaign> simulateCampaignStage({
    required int stageIndex, // 1 = Notification, 2 = URL, 3 = Phone Call (Coordinated Scam Alert)
    required String userId,
  });

  /// Persists mitigation / acknowledgement in Cloud Firestore
  Future<void> acknowledgeCampaign(String campaignId, String userId);
}
