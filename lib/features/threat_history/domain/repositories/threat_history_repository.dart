import '../entities/threat_history_item.dart';

abstract class ThreatHistoryRepository {
  /// Loads all chronological security scans for the specified user from Cloud Firestore
  Future<List<ThreatHistoryItem>> getThreatHistory(String userId);

  /// Saves a newly analyzed threat scan record in Cloud Firestore
  Future<void> saveThreatItem(ThreatHistoryItem item, String userId);

  /// Deletes a specific scan record from Cloud Firestore
  Future<void> deleteThreatItem(String itemId, String userId);

  /// Clears entire scan history for the user from Cloud Firestore
  Future<void> clearThreatHistory(String userId);

  /// Seeds realistic initial multi-vector demo threats covering all 5 categories
  Future<List<ThreatHistoryItem>> seedInitialDemoThreats(String userId);
}
