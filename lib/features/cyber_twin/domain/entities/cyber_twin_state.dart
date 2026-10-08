import 'threat_dna_campaign.dart';

enum CyberTwinStatus {
  activeGuardian,
  correlatingThreats,
  alertElevated,
}

class CyberTwinState {
  final String guardianName;
  final CyberTwinStatus status;
  final double neuralSyncLevel;
  final int timeWindowHours;
  final ThreatDnaCampaign? activeCampaign;
  final bool isCoordinatedScamDetected;
  final String alertMessage;
  final DateTime lastCorrelationCheck;

  const CyberTwinState({
    this.guardianName = 'CYBER TWIN // AEGIS-X',
    this.status = CyberTwinStatus.alertElevated,
    this.neuralSyncLevel = 0.988,
    this.timeWindowHours = 24,
    this.activeCampaign,
    this.isCoordinatedScamDetected = true,
    this.alertMessage = 'Possible coordinated scam activity detected.',
    required this.lastCorrelationCheck,
  });

  CyberTwinState copyWith({
    String? guardianName,
    CyberTwinStatus? status,
    double? neuralSyncLevel,
    int? timeWindowHours,
    ThreatDnaCampaign? activeCampaign,
    bool? isCoordinatedScamDetected,
    String? alertMessage,
    DateTime? lastCorrelationCheck,
  }) {
    return CyberTwinState(
      guardianName: guardianName ?? this.guardianName,
      status: status ?? this.status,
      neuralSyncLevel: neuralSyncLevel ?? this.neuralSyncLevel,
      timeWindowHours: timeWindowHours ?? this.timeWindowHours,
      activeCampaign: activeCampaign ?? this.activeCampaign,
      isCoordinatedScamDetected:
          isCoordinatedScamDetected ?? this.isCoordinatedScamDetected,
      alertMessage: alertMessage ?? this.alertMessage,
      lastCorrelationCheck: lastCorrelationCheck ?? this.lastCorrelationCheck,
    );
  }
}
