import 'package:flutter/material.dart';

enum ThreatCategory {
  website,
  qr,
  phone,
  email,
  notification,
  deepfake;

  String get label {
    switch (this) {
      case ThreatCategory.website:
        return 'Website';
      case ThreatCategory.qr:
        return 'QR';
      case ThreatCategory.phone:
        return 'Phone';
      case ThreatCategory.email:
        return 'Email';
      case ThreatCategory.notification:
        return 'Notification';
      case ThreatCategory.deepfake:
        return 'Deepfake';
    }
  }

  IconData get icon {
    switch (this) {
      case ThreatCategory.website:
        return Icons.language_rounded;
      case ThreatCategory.qr:
        return Icons.qr_code_2_rounded;
      case ThreatCategory.phone:
        return Icons.phone_in_talk_rounded;
      case ThreatCategory.email:
        return Icons.mark_email_unread_rounded;
      case ThreatCategory.notification:
        return Icons.notifications_active_rounded;
      case ThreatCategory.deepfake:
        return Icons.face_retouching_natural_rounded;
    }
  }

  static ThreatCategory fromString(String val) {
    final lower = val.toLowerCase().trim();
    switch (lower) {
      case 'website':
      case 'url':
        return ThreatCategory.website;
      case 'qr':
      case 'qrcode':
        return ThreatCategory.qr;
      case 'phone':
      case 'call':
        return ThreatCategory.phone;
      case 'email':
      case 'mail':
        return ThreatCategory.email;
      case 'notification':
      case 'notif':
        return ThreatCategory.notification;
      case 'deepfake':
      case 'media':
        return ThreatCategory.deepfake;
      default:
        return ThreatCategory.website;
    }
  }
}

enum ThreatSeverity {
  safe,
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case ThreatSeverity.safe:
        return 'SAFE';
      case ThreatSeverity.low:
        return 'LOW';
      case ThreatSeverity.medium:
        return 'MEDIUM';
      case ThreatSeverity.high:
        return 'HIGH';
      case ThreatSeverity.critical:
        return 'CRITICAL';
    }
  }

  static ThreatSeverity fromRiskScore(int score) {
    if (score >= 80) return ThreatSeverity.critical;
    if (score >= 60) return ThreatSeverity.high;
    if (score >= 40) return ThreatSeverity.medium;
    if (score >= 20) return ThreatSeverity.low;
    return ThreatSeverity.safe;
  }
}

class ThreatHistoryItem {
  final String id;
  final String title; // Target: e.g. domain, phone number, email subject, notification title
  final ThreatCategory category;
  final String threatType; // e.g. 'Phishing Domain', 'Robocall Extortion', 'Fake KYC SMS'
  final int riskScore; // 0 to 100
  final ThreatSeverity severity;
  final String reason; // AI reasoning and detected indicators
  final String recommendedAction;
  final String source; // e.g. 'Gemini 2.5 Flash', 'Telecom STIR/SHAKEN', 'Heuristic Defense'
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ThreatHistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.threatType,
    required this.riskScore,
    required this.severity,
    required this.reason,
    required this.recommendedAction,
    this.source = 'Gemini 2.5 Flash',
    required this.timestamp,
    this.metadata = const {},
  });

  ThreatHistoryItem copyWith({
    String? id,
    String? title,
    ThreatCategory? category,
    String? threatType,
    int? riskScore,
    ThreatSeverity? severity,
    String? reason,
    String? recommendedAction,
    String? source,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ThreatHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      threatType: threatType ?? this.threatType,
      riskScore: riskScore ?? this.riskScore,
      severity: severity ?? this.severity,
      reason: reason ?? this.reason,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'threat_type': threatType,
      'risk_score': riskScore,
      'severity': severity.name,
      'reason': reason,
      'recommended_action': recommendedAction,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ThreatHistoryItem.fromMap(Map<String, dynamic> map) {
    final risk = (map['risk_score'] as num?)?.toInt() ?? 0;
    final catStr = map['category'] as String? ?? 'website';
    final sevStr = map['severity'] as String?;

    return ThreatHistoryItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Unidentified Target',
      category: ThreatCategory.fromString(catStr),
      threatType: map['threat_type'] as String? ?? 'Suspicious Activity',
      riskScore: risk,
      severity: sevStr != null
          ? ThreatSeverity.values.firstWhere(
              (s) => s.name == sevStr,
              orElse: () => ThreatSeverity.fromRiskScore(risk),
            )
          : ThreatSeverity.fromRiskScore(risk),
      reason: map['reason'] as String? ?? 'No threat explanation provided.',
      recommendedAction:
          map['recommended_action'] as String? ?? 'Proceed with caution.',
      source: map['source'] as String? ?? 'CyberGuard Security Engine',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }
}
