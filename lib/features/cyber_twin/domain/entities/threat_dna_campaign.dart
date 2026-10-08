import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';

class ThreatDnaTimelineStep {
  final int stepNumber;
  final String vectorName; // e.g. 'SMS_NOTIFICATION', 'PHISHING_URL', 'SCAM_CALL'
  final String title;
  final String source;
  final int riskScore;
  final String elapsedStr; // e.g. 'T+00m', 'T+15m', 'T+32m'
  final DateTime timestamp;
  final String description;
  final IconData icon;

  const ThreatDnaTimelineStep({
    required this.stepNumber,
    required this.vectorName,
    required this.title,
    required this.source,
    required this.riskScore,
    required this.elapsedStr,
    required this.timestamp,
    required this.description,
    required this.icon,
  });
}

class RiskTrendPoint {
  final String label; // e.g. 'Stage 1 (SMS)', 'Stage 2 (URL)', 'Stage 3 (Call)'
  final int riskScore; // e.g. 72, 88, 96
  final String timestampStr;

  const RiskTrendPoint({
    required this.label,
    required this.riskScore,
    required this.timestampStr,
  });
}

class ThreatDnaCampaign {
  final String campaignId; // e.g. 'DNA-CMP-8491A'
  final String dnaFingerprint; // e.g. 'DNA:NOTIF+URL+CALL:CHASE:T-45M'
  final String status; // 'POSSIBLE_COORDINATED_SCAM'
  final List<String> vectorsInvolved; // ['Notification', 'Website', 'Phone Call']
  final int eventCount;
  final int timeSpanMinutes;
  final int baselineRiskScore;
  final int escalatedRiskScore; // e.g. 96 (Escalated due to multi-vector correlation)
  final int escalationBoost; // e.g. +18 PTS
  final double confidence; // e.g. 0.88 (88%)
  final String targetBrand; // e.g. 'Chase Bank'
  final List<String> correlationEvidence;
  final List<ThreatDnaTimelineStep> timeline;
  final List<RiskTrendPoint> riskTrend;
  final String recommendedPlaybook;
  final DateTime detectedAt;

  const ThreatDnaCampaign({
    required this.campaignId,
    required this.dnaFingerprint,
    this.status = 'POSSIBLE_COORDINATED_SCAM',
    required this.vectorsInvolved,
    required this.eventCount,
    required this.timeSpanMinutes,
    required this.baselineRiskScore,
    required this.escalatedRiskScore,
    required this.escalationBoost,
    required this.confidence,
    required this.targetBrand,
    required this.correlationEvidence,
    required this.timeline,
    required this.riskTrend,
    required this.recommendedPlaybook,
    required this.detectedAt,
  });

  Color get severityColor {
    if (escalatedRiskScore >= 80) return CyberColors.riskCritical;
    if (escalatedRiskScore >= 60) return CyberColors.riskWarning;
    return CyberColors.neonCyan;
  }
}
