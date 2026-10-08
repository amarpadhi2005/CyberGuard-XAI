import '../entities/cyber_health_score.dart';
import '../entities/score_factor_event.dart';

abstract class CyberHealthRepository {
  /// Fetches the user's current cyber health score and audit history from Cloud Firestore
  Future<CyberHealthScore> getHealthScore(String userId);

  /// Saves the updated cyber health score to Cloud Firestore
  Future<void> saveHealthScore(CyberHealthScore score, String userId);

  /// Applies a score factor event (increase or decrease) and persists to Firestore
  Future<CyberHealthScore> applyFactor(ScoreFactorEvent event, String userId);

  /// Resets cyber health score to baseline (e.g. 880/1000)
  Future<CyberHealthScore> resetScore(String userId);
}
