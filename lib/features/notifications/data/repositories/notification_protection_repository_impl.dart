import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/protected_notification.dart';
import '../../domain/repositories/notification_protection_repository.dart';
import '../services/gemini_notification_service.dart';

class NotificationProtectionRepositoryImpl
    implements NotificationProtectionRepository {
  final GeminiNotificationService _service;
  FirebaseFirestore? _firestore;
  final List<ProtectedNotification> _localCache = [];

  NotificationProtectionRepositoryImpl({
    GeminiNotificationService? service,
    FirebaseFirestore? firestore,
  })  : _service = service ?? GeminiNotificationService(),
        _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  @override
  Future<ProtectedNotification> analyzeNotification({
    required String title,
    required String body,
    required String appSource,
  }) async {
    final result = await _service.analyzeNotification(
      title: title,
      body: body,
      appSource: appSource,
    );
    _localCache.insert(0, result);
    return result;
  }

  @override
  Future<void> saveNotificationResult(
    ProtectedNotification notification,
    String userId,
  ) async {
    try {
      final db = _db;
      if (db == null) return;
      await db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id)
          .set({
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'app_source': notification.appSource,
        'threat_category': notification.threatCategory.name,
        'severity': notification.severity.name,
        'is_malicious': notification.isMalicious,
        'explanation': notification.explanation,
        'recommended_action': notification.recommendedAction,
        'confidence': notification.confidence,
        'user_action': notification.userAction.name,
        'scanned_at': Timestamp.fromDate(notification.timestamp),
      }, SetOptions(merge: true));

      // Also sync to unified threat_history
      int risk = (notification.confidence * 100).toInt();
      if (!notification.isMalicious) {
        risk = 5;
      }

      await db
          .collection('users')
          .doc(userId)
          .collection('threat_history')
          .doc(notification.id)
          .set({
        'id': notification.id,
        'title': '${notification.appSource}: ${notification.title}',
        'category': 'notification',
        'threat_type': notification.threatCategory.label,
        'risk_score': risk,
        'severity': notification.severity.name,
        'reason': notification.explanation,
        'recommended_action': notification.recommendedAction,
        'source': 'Gemini 2.5 Flash / Notification Sentinel',
        'timestamp': notification.timestamp.toIso8601String(),
        'metadata': {
          'app_source': notification.appSource,
          'body': notification.body,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save notification fallback: $e');
    }
  }

  @override
  Future<void> updateNotificationUserAction(
    String notificationId,
    String userId,
    NotificationUserAction action,
  ) async {
    // 1. Update local cache
    final index = _localCache.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _localCache[index] = _localCache[index].copyWith(userAction: action);
    }

    // 2. Persist to Firestore
    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .update({
          'user_action': action.name,
          'action_updated_at': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Firestore update action fallback: $e');
    }
  }

  @override
  Future<List<ProtectedNotification>> getNotificationHistory(String userId) async {
    try {
      final db = _db;
      if (db == null) return List.unmodifiable(_localCache);
      final snapshot = await db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('scanned_at', descending: true)
          .limit(30)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ProtectedNotification(
            id: data['id'] as String? ?? doc.id,
            title: data['title'] as String? ?? '',
            body: data['body'] as String? ?? '',
            appSource: data['app_source'] as String? ?? 'Android System',
            threatCategory: _parseCategory(data['threat_category']),
            severity: _parseSeverity(data['severity']),
            isMalicious: data['is_malicious'] as bool? ?? false,
            explanation: data['explanation'] as String? ?? '',
            recommendedAction: data['recommended_action'] as String? ?? '',
            confidence: (data['confidence'] as num?)?.toDouble() ?? 0.95,
            userAction: _parseAction(data['user_action']),
            timestamp: (data['scanned_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Firestore load notifications fallback: $e');
    }

    return List.unmodifiable(_localCache);
  }

  NotificationThreatCategory _parseCategory(dynamic raw) {
    for (final cat in NotificationThreatCategory.values) {
      if (cat.name == raw) return cat;
    }
    return NotificationThreatCategory.clean;
  }

  NotificationSeverity _parseSeverity(dynamic raw) {
    for (final sev in NotificationSeverity.values) {
      if (sev.name == raw) return sev;
    }
    return NotificationSeverity.safe;
  }

  NotificationUserAction _parseAction(dynamic raw) {
    for (final act in NotificationUserAction.values) {
      if (act.name == raw) return act;
    }
    return NotificationUserAction.pending;
  }
}
