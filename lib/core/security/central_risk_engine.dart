enum RiskSeverity {
  low,
  lowModerate,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case RiskSeverity.low:
        return 'LOW';
      case RiskSeverity.lowModerate:
        return 'LOW-MODERATE';
      case RiskSeverity.medium:
        return 'MEDIUM';
      case RiskSeverity.high:
        return 'HIGH';
      case RiskSeverity.critical:
        return 'CRITICAL';
    }
  }

  static RiskSeverity fromScore(int score) {
    if (score >= 80) return RiskSeverity.critical;
    if (score >= 60) return RiskSeverity.high;
    if (score >= 40) return RiskSeverity.medium;
    if (score >= 20) return RiskSeverity.lowModerate;
    return RiskSeverity.low;
  }
}

class SecurityIndicator {
  final String indicator;
  final String category;
  final RiskSeverity severity;
  final int confidence; // 0 to 100
  final String evidence;
  final double weight; // contribution to score

  const SecurityIndicator({
    required this.indicator,
    required this.category,
    required this.severity,
    required this.confidence,
    required this.evidence,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
        'indicator': indicator,
        'category': category,
        'severity': severity.label,
        'confidence': confidence,
        'evidence': evidence,
        'weight': weight,
      };

  factory SecurityIndicator.fromJson(Map<String, dynamic> json) {
    final sevStr = (json['severity'] as String? ?? 'LOW').toUpperCase();
    RiskSeverity sev = RiskSeverity.low;
    if (sevStr.contains('CRITICAL')) {
      sev = RiskSeverity.critical;
    } else if (sevStr.contains('HIGH')) {
      sev = RiskSeverity.high;
    } else if (sevStr.contains('MEDIUM')) {
      sev = RiskSeverity.medium;
    } else if (sevStr.contains('MODERATE')) {
      sev = RiskSeverity.lowModerate;
    }

    return SecurityIndicator(
      indicator: json['indicator'] as String? ?? 'General Finding',
      category: json['category'] as String? ?? 'Security',
      severity: sev,
      confidence: (json['confidence'] as num?)?.toInt() ?? 90,
      evidence: json['evidence'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 10.0,
    );
  }
}

class RiskAssessmentResult {
  final int riskScore; // 0 to 100
  final RiskSeverity severity;
  final int confidence; // 0 to 100
  final List<SecurityIndicator> indicators;
  final DateTime calculatedAt;

  const RiskAssessmentResult({
    required this.riskScore,
    required this.severity,
    required this.confidence,
    required this.indicators,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'riskScore': riskScore,
        'severity': severity.label,
        'confidence': confidence,
        'indicators': indicators.map((i) => i.toJson()).toList(),
        'calculatedAt': calculatedAt.toIso8601String(),
      };
}

class CentralRiskEngine {
  /// Dynamically computes a transparent 0-100 risk score based on structured evidence.
  /// Normalized Bands:
  /// 0–19   LOW
  /// 20–39  LOW-MODERATE
  /// 40–59  MEDIUM
  /// 60–79  HIGH
  /// 80–100 CRITICAL
  static RiskAssessmentResult evaluate(List<SecurityIndicator> indicators) {
    if (indicators.isEmpty) {
      return RiskAssessmentResult(
        riskScore: 0,
        severity: RiskSeverity.low,
        confidence: 99,
        indicators: const [],
        calculatedAt: DateTime.now(),
      );
    }

    double totalWeightedScore = 0.0;
    double totalConfidence = 0.0;

    for (final ind in indicators) {
      // Calculate contribution based on indicator severity and weight
      double basePoints;
      switch (ind.severity) {
        case RiskSeverity.critical:
          basePoints = 50.0;
          break;
        case RiskSeverity.high:
          basePoints = 30.0;
          break;
        case RiskSeverity.medium:
          basePoints = 18.0;
          break;
        case RiskSeverity.lowModerate:
          basePoints = 10.0;
          break;
        case RiskSeverity.low:
          basePoints = 0.0;
          break;
      }

      totalWeightedScore += (basePoints * (ind.weight / 10.0));
      totalConfidence += ind.confidence;
    }

    final int finalScore = totalWeightedScore.round().clamp(0, 100);
    final RiskSeverity finalSeverity = RiskSeverity.fromScore(finalScore);
    final int avgConfidence = (totalConfidence / indicators.length).round().clamp(85, 99);

    return RiskAssessmentResult(
      riskScore: finalScore,
      severity: finalSeverity,
      confidence: avgConfidence,
      indicators: List.unmodifiable(indicators),
      calculatedAt: DateTime.now(),
    );
  }
}
