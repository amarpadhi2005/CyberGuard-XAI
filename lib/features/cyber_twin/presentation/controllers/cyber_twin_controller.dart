import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cyber_twin_state.dart';
import '../../domain/entities/threat_dna_campaign.dart';
import '../../domain/repositories/cyber_twin_repository.dart';
import '../../data/repositories/cyber_twin_repository_impl.dart';

class CyberTwinController extends ChangeNotifier {
  final CyberTwinRepository _repository;

  CyberTwinState? _state;
  bool _isLoading = false;
  int _simulationStage = 3; // Default to full 3-stage coordinated attack for instant demonstration
  bool _isAutoSimulating = false;
  Timer? _demoTimer;

  CyberTwinController({CyberTwinRepository? repository})
      : _repository = repository ?? CyberTwinRepositoryImpl();

  // Getters
  bool get isLoading => _isLoading;
  bool get isAutoSimulating => _isAutoSimulating;
  int get simulationStage => _simulationStage;
  CyberTwinState? get state => _state;
  ThreatDnaCampaign? get campaign => _state?.activeCampaign;
  bool get isCoordinatedScamDetected =>
      _state?.isCoordinatedScamDetected ?? false;
  String get alertMessage =>
      _state?.alertMessage ?? 'Possible coordinated scam activity detected.';

  Future<void> loadCorrelation(String userId) async {
    _isLoading = true;
    notifyListeners();

    _state = await _repository.evaluateThreatCorrelation(
      userId: userId,
      timeWindowHours: _state?.timeWindowHours ?? 24,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setTimeWindow(int hours, String userId) async {
    _isLoading = true;
    notifyListeners();

    _state = await _repository.evaluateThreatCorrelation(
      userId: userId,
      timeWindowHours: hours,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sets simulation stage (1 = Notification, 2 = URL Scanned, 3 = Scam Call Received)
  Future<void> setSimulationStage(int stage, String userId) async {
    _simulationStage = stage.clamp(1, 3);
    final campaign = await _repository.simulateCampaignStage(
      stageIndex: _simulationStage,
      userId: userId,
    );

    final isDetected = _simulationStage >= 2;
    final baseState = _state ?? CyberTwinState(lastCorrelationCheck: DateTime.now());
    _state = baseState.copyWith(
      activeCampaign: campaign,
      isCoordinatedScamDetected: isDetected,
      alertMessage: isDetected
          ? 'Possible coordinated scam activity detected.'
          : 'Monitoring initial alert. No multi-vector convergence yet.',
      status: isDetected
          ? CyberTwinStatus.alertElevated
          : CyberTwinStatus.activeGuardian,
    );

    notifyListeners();
  }

  /// Automated live hackathon presentation mode (animates 1 -> 2 -> 3)
  void startHackathonLiveDemo(String userId) {
    if (_isAutoSimulating) return;

    _isAutoSimulating = true;
    _simulationStage = 1;
    setSimulationStage(1, userId);
    notifyListeners();

    _demoTimer?.cancel();
    _demoTimer = Timer(const Duration(milliseconds: 1400), () {
      _simulationStage = 2;
      setSimulationStage(2, userId);
      notifyListeners();

      _demoTimer = Timer(const Duration(milliseconds: 1800), () {
        _simulationStage = 3;
        setSimulationStage(3, userId);
        _isAutoSimulating = false;
        notifyListeners();
      });
    });
  }

  Future<void> acknowledgeCampaign(String userId) async {
    if (campaign != null) {
      await _repository.acknowledgeCampaign(campaign!.campaignId, userId);
    }
    final baseState = _state ?? CyberTwinState(lastCorrelationCheck: DateTime.now());
    _state = baseState.copyWith(
      isCoordinatedScamDetected: false,
      alertMessage: 'Campaign mitigated. Defense baseline restored.',
      status: CyberTwinStatus.activeGuardian,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }
}
