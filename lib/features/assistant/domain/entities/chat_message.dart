import '../../../../core/security/central_risk_engine.dart';

enum MessageSender { user, assistant, system }

enum AssistantRiskLevel {
  safe,
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case AssistantRiskLevel.safe:
        return 'LOW';
      case AssistantRiskLevel.low:
        return 'LOW-MODERATE';
      case AssistantRiskLevel.medium:
        return 'MEDIUM';
      case AssistantRiskLevel.high:
        return 'HIGH';
      case AssistantRiskLevel.critical:
        return 'CRITICAL';
    }
  }

  static AssistantRiskLevel fromScore(int score) {
    if (score >= 80) return AssistantRiskLevel.critical;
    if (score >= 60) return AssistantRiskLevel.high;
    if (score >= 40) return AssistantRiskLevel.medium;
    if (score >= 20) return AssistantRiskLevel.low;
    return AssistantRiskLevel.safe;
  }
}

class AssistantStructuredResponse {
  final AssistantRiskLevel riskLevel;
  final int riskScore; // 0 to 100
  final String riskSummary;
  final String explanation;
  final List<String> recommendations;
  final double confidence; // 0.0 to 1.0 (e.g. 0.98 = 98%)
  final List<SecurityIndicator> indicators;
  final bool webpageInspected;
  final String? toolName;
  final List<String> timelineSteps;
  final String? defangedTarget;

  const AssistantStructuredResponse({
    required this.riskLevel,
    this.riskScore = 0,
    required this.riskSummary,
    required this.explanation,
    required this.recommendations,
    required this.confidence,
    this.indicators = const [],
    this.webpageInspected = false,
    this.toolName,
    this.timelineSteps = const [],
    this.defangedTarget,
  });

  String get formattedConfidence => '${(confidence * 100).toInt()}%';
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final AssistantStructuredResponse? structuredResponse;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.structuredResponse,
    this.isTyping = false,
  });

  bool get hasToolExecution =>
      structuredResponse?.toolName != null &&
      structuredResponse!.timelineSteps.isNotEmpty;

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    DateTime? timestamp,
    AssistantStructuredResponse? structuredResponse,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      structuredResponse: structuredResponse ?? this.structuredResponse,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
