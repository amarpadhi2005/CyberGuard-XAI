enum QrSafetyVerdict {
  safe,
  suspicious,
  dangerous;

  String get label {
    switch (this) {
      case QrSafetyVerdict.safe:
        return 'SAFE';
      case QrSafetyVerdict.suspicious:
        return 'SUSPICIOUS';
      case QrSafetyVerdict.dangerous:
        return 'DANGEROUS';
    }
  }
}

class QrScanResult {
  final String rawPayload;
  final String extractedUrl;
  final QrSafetyVerdict verdict;
  final int riskScore; // 0 to 100
  final String reason;
  final String recommendedAction;
  final bool isHttps;
  final List<String> threatSignals;
  final DateTime scannedAt;

  const QrScanResult({
    required this.rawPayload,
    required this.extractedUrl,
    required this.verdict,
    required this.riskScore,
    required this.reason,
    required this.recommendedAction,
    required this.isHttps,
    required this.threatSignals,
    required this.scannedAt,
  });
}
