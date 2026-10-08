import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';

enum ScoreFactorType {
  scanWebsite,
  reportScam,
  enableProtection,
  openHighRiskLink,
  disableProtection,
  suspiciousActivityDetected;

  String get label {
    switch (this) {
      case ScoreFactorType.scanWebsite:
        return 'Scanned Website';
      case ScoreFactorType.reportScam:
        return 'Reported Scam Incident';
      case ScoreFactorType.enableProtection:
        return 'Shield Protection Enabled';
      case ScoreFactorType.openHighRiskLink:
        return 'High-Risk Link Opened';
      case ScoreFactorType.disableProtection:
        return 'Protection Shield Disabled';
      case ScoreFactorType.suspiciousActivityDetected:
        return 'Suspicious Telephony / IOC Detected';
    }
  }

  int get defaultDelta {
    switch (this) {
      case ScoreFactorType.scanWebsite:
        return 35;
      case ScoreFactorType.reportScam:
        return 30;
      case ScoreFactorType.enableProtection:
        return 75;
      case ScoreFactorType.openHighRiskLink:
        return -100;
      case ScoreFactorType.disableProtection:
        return -150;
      case ScoreFactorType.suspiciousActivityDetected:
        return -60;
    }
  }

  bool get isPositive => defaultDelta > 0;

  IconData get icon {
    switch (this) {
      case ScoreFactorType.scanWebsite:
        return Icons.link_rounded;
      case ScoreFactorType.reportScam:
        return Icons.flag_rounded;
      case ScoreFactorType.enableProtection:
        return Icons.shield_rounded;
      case ScoreFactorType.openHighRiskLink:
        return Icons.warning_amber_rounded;
      case ScoreFactorType.disableProtection:
        return Icons.shield_outlined;
      case ScoreFactorType.suspiciousActivityDetected:
        return Icons.crisis_alert_rounded;
    }
  }

  Color get color {
    if (isPositive) {
      return CyberColors.neonCyan;
    } else {
      return CyberColors.riskCritical;
    }
  }
}

class ScoreFactorEvent {
  final String id;
  final ScoreFactorType type;
  final int pointsDelta;
  final String title;
  final String description;
  final DateTime timestamp;

  const ScoreFactorEvent({
    required this.id,
    required this.type,
    required this.pointsDelta,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'points_delta': pointsDelta,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScoreFactorEvent.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'scanWebsite';
    final type = ScoreFactorType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => ScoreFactorType.scanWebsite,
    );

    return ScoreFactorEvent(
      id: map['id'] as String? ?? '',
      type: type,
      pointsDelta: (map['points_delta'] as num?)?.toInt() ?? type.defaultDelta,
      title: map['title'] as String? ?? type.label,
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
