import 'package:flutter/material.dart';
import '../../../../core/theme/cyber_colors.dart';

enum XaiSeverity {
  critical,
  high,
  medium,
  safe;

  String get label {
    switch (this) {
      case XaiSeverity.critical:
        return 'CRITICAL THREAT';
      case XaiSeverity.high:
        return 'HIGH RISK';
      case XaiSeverity.medium:
        return 'SUSPICIOUS';
      case XaiSeverity.safe:
        return 'VERIFIED SAFE';
    }
  }

  Color get color {
    switch (this) {
      case XaiSeverity.critical:
        return CyberColors.riskCritical;
      case XaiSeverity.high:
        return CyberColors.riskWarning;
      case XaiSeverity.medium:
        return const Color(0xFFFFB800);
      case XaiSeverity.safe:
        return const Color(0xFF00FF9D);
    }
  }
}

class XaiEvidenceItem {
  final String title;
  final String description;
  final double severityWeight; // 0.0 to 1.0
  final IconData icon;
  final bool isFlagged;

  const XaiEvidenceItem({
    required this.title,
    required this.description,
    required this.severityWeight,
    required this.icon,
    this.isFlagged = true,
  });
}

class XaiFactorMetric {
  final String name;
  final double score; // 0.0 to 1.0 (or percentage)
  final String summary;
  final Color color;

  const XaiFactorMetric({
    required this.name,
    required this.score,
    required this.summary,
    required this.color,
  });
}

class XaiResultModel {
  final String id;
  final String target; // URL, phone number, email subject, notification text
  final String category; // Website, QR, Phone, Email, Notification
  final String threatType; // Specific type: e.g. "Fake Banking Login Page (Phishing)"
  final int riskScore; // 0 to 100
  final double confidence; // e.g. 0.984 (98.4%)
  final XaiSeverity severity;

  // Simple Non-Technical Explanations
  final String plainEnglishSummary;
  final String howItWorks;
  final String realWorldAnalogy;

  // Structured Evidence & Charts Data
  final List<XaiEvidenceItem> evidenceList;
  final List<XaiFactorMetric> factorMetrics;

  // Concrete Actionable Guidance
  final List<String> recommendedActions;
  final DateTime timestamp;

  const XaiResultModel({
    required this.id,
    required this.target,
    required this.category,
    required this.threatType,
    required this.riskScore,
    required this.confidence,
    required this.severity,
    required this.plainEnglishSummary,
    required this.howItWorks,
    required this.realWorldAnalogy,
    required this.evidenceList,
    required this.factorMetrics,
    required this.recommendedActions,
    required this.timestamp,
  });

  double get riskPercentage => (riskScore / 100.0).clamp(0.0, 1.0);
  double get confidencePercentage => confidence.clamp(0.0, 1.0);
}
