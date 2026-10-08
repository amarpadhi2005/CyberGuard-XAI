enum NotificationThreatCategory {
  bankScam,
  lottery,
  fakeKyc,
  otpTheft,
  urgentPayment,
  clean;

  String get label {
    switch (this) {
      case NotificationThreatCategory.bankScam:
        return 'BANK SCAM';
      case NotificationThreatCategory.lottery:
        return 'LOTTERY FRAUD';
      case NotificationThreatCategory.fakeKyc:
        return 'FAKE KYC EXPIRATION';
      case NotificationThreatCategory.otpTheft:
        return 'OTP THEFT INTERCEPTION';
      case NotificationThreatCategory.urgentPayment:
        return 'URGENT PAYMENT SCAM';
      case NotificationThreatCategory.clean:
        return 'CLEAN NOTIFICATION';
    }
  }
}

enum NotificationSeverity {
  critical,
  high,
  medium,
  safe;

  String get label {
    switch (this) {
      case NotificationSeverity.critical:
        return 'CRITICAL THREAT';
      case NotificationSeverity.high:
        return 'HIGH RISK';
      case NotificationSeverity.medium:
        return 'MEDIUM SUSPICION';
      case NotificationSeverity.safe:
        return 'SAFE / AUTHENTIC';
    }
  }
}

enum NotificationUserAction {
  pending,
  markedSafe,
  reportedScam;

  String get label {
    switch (this) {
      case NotificationUserAction.pending:
        return 'PENDING REVIEW';
      case NotificationUserAction.markedSafe:
        return 'MARKED AS SAFE';
      case NotificationUserAction.reportedScam:
        return 'REPORTED SCAM';
    }
  }
}

class ProtectedNotification {
  final String id;
  final String title;
  final String body;
  final String appSource;
  final NotificationThreatCategory threatCategory;
  final NotificationSeverity severity;
  final bool isMalicious;
  final String explanation;
  final String recommendedAction;
  final double confidence;
  final NotificationUserAction userAction;
  final DateTime timestamp;

  const ProtectedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.appSource,
    required this.threatCategory,
    required this.severity,
    required this.isMalicious,
    required this.explanation,
    required this.recommendedAction,
    required this.confidence,
    this.userAction = NotificationUserAction.pending,
    required this.timestamp,
  });

  ProtectedNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? appSource,
    NotificationThreatCategory? threatCategory,
    NotificationSeverity? severity,
    bool? isMalicious,
    String? explanation,
    String? recommendedAction,
    double? confidence,
    NotificationUserAction? userAction,
    DateTime? timestamp,
  }) {
    return ProtectedNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      appSource: appSource ?? this.appSource,
      threatCategory: threatCategory ?? this.threatCategory,
      severity: severity ?? this.severity,
      isMalicious: isMalicious ?? this.isMalicious,
      explanation: explanation ?? this.explanation,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      confidence: confidence ?? this.confidence,
      userAction: userAction ?? this.userAction,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
