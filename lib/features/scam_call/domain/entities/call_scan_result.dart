enum CallVerdict {
  spam,
  safe,
  unknown,
  fraud;

  String get label {
    switch (this) {
      case CallVerdict.spam:
        return 'SPAM';
      case CallVerdict.safe:
        return 'SAFE';
      case CallVerdict.unknown:
        return 'UNKNOWN';
      case CallVerdict.fraud:
        return 'FRAUD';
    }
  }
}

class CallScanResult {
  final String id;
  final String phoneNumber;
  final String formattedNumber;
  final String callerName;
  final String carrier;
  final String location;
  final CallVerdict verdict;
  final int riskScore; // 0 to 100
  final String callerCategory;
  final String recommendedAction;
  final int reportsCount;
  final List<String> threatSignals;
  final String explanation;
  final bool isBlocked;
  final DateTime timestamp;

  const CallScanResult({
    required this.id,
    required this.phoneNumber,
    required this.formattedNumber,
    required this.callerName,
    required this.carrier,
    required this.location,
    required this.verdict,
    required this.riskScore,
    required this.callerCategory,
    required this.recommendedAction,
    required this.reportsCount,
    required this.threatSignals,
    required this.explanation,
    this.isBlocked = false,
    required this.timestamp,
  });

  CallScanResult copyWith({
    String? id,
    String? phoneNumber,
    String? formattedNumber,
    String? callerName,
    String? carrier,
    String? location,
    CallVerdict? verdict,
    int? riskScore,
    String? callerCategory,
    String? recommendedAction,
    int? reportsCount,
    List<String>? threatSignals,
    String? explanation,
    bool? isBlocked,
    DateTime? timestamp,
  }) {
    return CallScanResult(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      formattedNumber: formattedNumber ?? this.formattedNumber,
      callerName: callerName ?? this.callerName,
      carrier: carrier ?? this.carrier,
      location: location ?? this.location,
      verdict: verdict ?? this.verdict,
      riskScore: riskScore ?? this.riskScore,
      callerCategory: callerCategory ?? this.callerCategory,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      reportsCount: reportsCount ?? this.reportsCount,
      threatSignals: threatSignals ?? this.threatSignals,
      explanation: explanation ?? this.explanation,
      isBlocked: isBlocked ?? this.isBlocked,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
