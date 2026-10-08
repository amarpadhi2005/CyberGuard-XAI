import '../entities/protected_notification.dart';

abstract class NotificationProtectionRepository {
  /// Analyzes incoming notification text using Gemini 2.5 Flash API
  Future<ProtectedNotification> analyzeNotification({
    required String title,
    required String body,
    required String appSource,
  });

  /// Persists notification telemetry and verdict inside Firestore
  Future<void> saveNotificationResult(
    ProtectedNotification notification,
    String userId,
  );

  /// Updates the user's action (Mark Safe or Report Scam) in Firestore
  Future<void> updateNotificationUserAction(
    String notificationId,
    String userId,
    NotificationUserAction action,
  );

  /// Retrieves persisted notification inspection history from Firestore
  Future<List<ProtectedNotification>> getNotificationHistory(String userId);
}
