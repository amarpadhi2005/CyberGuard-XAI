enum ThreatLevel {
  safe,
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case ThreatLevel.safe:
        return 'SAFE / LOW';
      case ThreatLevel.low:
        return 'LOW RISK';
      case ThreatLevel.medium:
        return 'MEDIUM RISK';
      case ThreatLevel.high:
        return 'HIGH RISK';
      case ThreatLevel.critical:
        return 'CRITICAL';
    }
  }

  static ThreatLevel fromScore(int score) {
    if (score >= 80) return ThreatLevel.critical;
    if (score >= 60) return ThreatLevel.high;
    if (score >= 40) return ThreatLevel.medium;
    if (score >= 20) return ThreatLevel.low;
    return ThreatLevel.safe;
  }
}

enum IndicatorSeverity {
  critical,
  high,
  medium,
  low,
  info;

  String get label {
    switch (this) {
      case IndicatorSeverity.critical:
        return 'CRITICAL';
      case IndicatorSeverity.high:
        return 'HIGH';
      case IndicatorSeverity.medium:
        return 'MEDIUM';
      case IndicatorSeverity.low:
        return 'LOW';
      case IndicatorSeverity.info:
        return 'INFO';
    }
  }

  static IndicatorSeverity fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'critical':
        return IndicatorSeverity.critical;
      case 'high':
        return IndicatorSeverity.high;
      case 'medium':
        return IndicatorSeverity.medium;
      case 'low':
        return IndicatorSeverity.low;
      default:
        return IndicatorSeverity.info;
    }
  }
}

class UrlThreatIndicator {
  final String name;
  final IndicatorSeverity severity;
  final String evidence;
  final String explanation;
  final int? confidence;

  const UrlThreatIndicator({
    required this.name,
    required this.severity,
    required this.evidence,
    required this.explanation,
    this.confidence,
  });

  // Backward compatibility getters
  String get category => name;
  bool get isThreat =>
      severity == IndicatorSeverity.critical ||
      severity == IndicatorSeverity.high ||
      severity == IndicatorSeverity.medium;
  String get details => '$evidence. $explanation';

  Map<String, dynamic> toJson() => {
        'name': name,
        'severity': severity.name,
        'evidence': evidence,
        'explanation': explanation,
        if (confidence != null) 'confidence': confidence,
      };

  factory UrlThreatIndicator.fromJson(Map<String, dynamic> json) {
    return UrlThreatIndicator(
      name: json['name'] as String? ?? json['category'] as String? ?? 'Forensic Indicator',
      severity: IndicatorSeverity.fromString(json['severity'] as String? ?? 'info'),
      evidence: json['evidence'] as String? ?? json['details'] as String? ?? 'Observed in URL telemetry',
      explanation: json['explanation'] as String? ?? json['details'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toInt(),
    );
  }
}

// Backward-compatible alias for existing imports
typedef ThreatIndicator = UrlThreatIndicator;

class UrlScanResult {
  final String originalUrl;
  final String defangedUrl;
  final String domain;
  final String protocol;
  final int? port;
  final String path;
  final String query;
  final List<String> redirects;
  final int riskScore; // 0 to 100
  final ThreatLevel threatLevel;
  final int confidence; // 0 to 100
  final String summary;
  final String recommendedAction;
  final bool isHttps;
  final String httpsMeaning;
  final bool webpageInspected;
  final String? domainAge;
  final String reputationStatus;
  final List<UrlThreatIndicator> indicators;
  final DateTime scannedAt;
  final bool isQuickTest;

  const UrlScanResult({
    required this.originalUrl,
    required this.defangedUrl,
    required this.domain,
    required this.protocol,
    this.port,
    required this.path,
    required this.query,
    this.redirects = const [],
    required this.riskScore,
    required this.threatLevel,
    required this.confidence,
    required this.summary,
    required this.recommendedAction,
    required this.isHttps,
    required this.httpsMeaning,
    this.webpageInspected = false,
    this.domainAge,
    this.reputationStatus = 'Heuristic Evaluation Complete',
    required this.indicators,
    required this.scannedAt,
    this.isQuickTest = false,
  });

  // Backward compatibility getters
  String get url => originalUrl;
  String get reason => summary;
}
