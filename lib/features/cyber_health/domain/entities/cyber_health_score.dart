import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';
import 'score_factor_event.dart';

enum HealthTier {
  critical,
  vulnerable,
  good,
  excellent;

  String get label {
    switch (this) {
      case HealthTier.critical:
        return 'CRITICAL EXPOSURE';
      case HealthTier.vulnerable:
        return 'DEFENSE DEGRADED';
      case HealthTier.good:
        return 'HARDENED PERIMETER';
      case HealthTier.excellent:
        return 'OPTIMAL DEFENSE';
    }
  }

  Color get color {
    switch (this) {
      case HealthTier.critical:
        return CyberColors.riskCritical;
      case HealthTier.vulnerable:
        return CyberColors.riskWarning;
      case HealthTier.good:
        return CyberColors.neonCyan;
      case HealthTier.excellent:
        return const Color(0xFF00FF9D);
    }
  }

  String get subtitle {
    switch (this) {
      case HealthTier.critical:
        return 'Immediate remediation required. Protection shield disabled or critical IOCs present.';
      case HealthTier.vulnerable:
        return 'Potential attack surfaces exposed. Audit recent links and re-enable active protection.';
      case HealthTier.good:
        return 'Robust security hygiene observed. Follow recommended suggestions to reach 1000.';
      case HealthTier.excellent:
        return 'Top-tier enterprise security score. Zero-trust principles fully maintained.';
    }
  }
}

class HealthSuggestion {
  final String id;
  final String title;
  final String description;
  final int pointsBoost;
  final IconData icon;
  final String actionRoute;

  const HealthSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsBoost,
    required this.icon,
    required this.actionRoute,
  });
}

class CyberHealthScore {
  static const int maxScore = 1000;

  final int score; // 0 to 1000
  final bool isShieldActive;
  final List<ScoreFactorEvent> history;
  final List<HealthSuggestion> suggestions;
  final DateTime lastUpdated;

  const CyberHealthScore({
    required this.score,
    required this.isShieldActive,
    required this.history,
    required this.suggestions,
    required this.lastUpdated,
  });

  double get progressPercentage => (score / maxScore).clamp(0.0, 1.0);

  HealthTier get tier {
    if (score >= 850) return HealthTier.excellent;
    if (score >= 700) return HealthTier.good;
    if (score >= 400) return HealthTier.vulnerable;
    return HealthTier.critical;
  }

  Color get tierColor => tier.color;

  CyberHealthScore copyWith({
    int? score,
    bool? isShieldActive,
    List<ScoreFactorEvent>? history,
    List<HealthSuggestion>? suggestions,
    DateTime? lastUpdated,
  }) {
    return CyberHealthScore(
      score: score != null ? score.clamp(0, maxScore) : this.score,
      isShieldActive: isShieldActive ?? this.isShieldActive,
      history: history ?? this.history,
      suggestions: suggestions ?? this.suggestions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'is_shield_active': isShieldActive,
      'history': history.map((e) => e.toMap()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory CyberHealthScore.fromMap(Map<String, dynamic> map) {
    final rawScore = (map['score'] as num?)?.toInt() ?? 880;
    final isShield = map['is_shield_active'] as bool? ?? true;
    final rawHistory = map['history'] as List? ?? [];
    final history = rawHistory
        .map((e) => ScoreFactorEvent.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return CyberHealthScore(
      score: rawScore.clamp(0, maxScore),
      isShieldActive: isShield,
      history: history,
      suggestions: generateDynamicSuggestions(rawScore, isShield),
      lastUpdated: map['last_updated'] != null
          ? DateTime.tryParse(map['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<HealthSuggestion> generateDynamicSuggestions(
      int currentScore, bool shieldActive) {
    final list = <HealthSuggestion>[];

    if (!shieldActive) {
      list.add(const HealthSuggestion(
        id: 'sug_shield',
        title: 'Activate Protection Shield',
        description:
            'Enable active foreground defense to eliminate high-risk exposure penalties.',
        pointsBoost: 75,
        icon: Icons.shield_rounded,
        actionRoute: '/dashboard',
      ));
    }

    list.add(const HealthSuggestion(
      id: 'sug_url',
      title: 'Scan External Web Links',
      description:
          'Audit unverified URLs with Gemini AI before entering login or card credentials.',
      pointsBoost: 35,
      icon: Icons.link_rounded,
      actionRoute: '/url-scanner',
    ));

    list.add(const HealthSuggestion(
      id: 'sug_scam',
      title: 'Report Unsolicited Telephony Scams',
      description:
          'Flag robocalls or Wangiri callbacks to crowdsourced threat databases.',
      pointsBoost: 30,
      icon: Icons.phone_callback_rounded,
      actionRoute: '/scam-call',
    ));

    list.add(const HealthSuggestion(
      id: 'sug_qr',
      title: 'Verify Physical QR Codes',
      description:
          'Protect against quishing and malicious APK delivery by previewing destination domains.',
      pointsBoost: 25,
      icon: Icons.qr_code_scanner_rounded,
      actionRoute: '/qr-scanner',
    ));

    list.add(const HealthSuggestion(
      id: 'sug_threats',
      title: 'Review Threat History Timeline',
      description:
          'Acknowledge and clear historical IOC audit alerts across all 5 threat vectors.',
      pointsBoost: 20,
      icon: Icons.history_edu_rounded,
      actionRoute: '/threat-history',
    ));

    return list;
  }
}
