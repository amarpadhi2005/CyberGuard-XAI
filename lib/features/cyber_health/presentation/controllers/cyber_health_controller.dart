import 'package:flutter/foundation.dart';
import '../../domain/entities/cyber_health_score.dart';
import '../../domain/entities/score_factor_event.dart';
import '../../domain/repositories/cyber_health_repository.dart';
import '../../data/repositories/cyber_health_repository_impl.dart';

class CyberHealthController extends ChangeNotifier {
  final CyberHealthRepository _repository;

  CyberHealthScore? _healthScore;
  bool _isLoading = false;
  String? _errorMessage;

  CyberHealthController({CyberHealthRepository? repository})
      : _repository = repository ?? CyberHealthRepositoryImpl();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CyberHealthScore? get healthScore => _healthScore;

  int get score => _healthScore?.score ?? 880;
  int get maxScore => CyberHealthScore.maxScore;
  double get progress => _healthScore?.progressPercentage ?? 0.88;
  HealthTier get tier => _healthScore?.tier ?? HealthTier.excellent;
  bool get isShieldActive => _healthScore?.isShieldActive ?? true;
  List<ScoreFactorEvent> get history => _healthScore?.history ?? [];
  List<HealthSuggestion> get suggestions => _healthScore?.suggestions ?? [];

  /// Loads current Cyber Health Score from Cloud Firestore
  Future<void> loadScore(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthScore = await _repository.getHealthScore(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ==========================================
  // SCORE INCREASING ACTIONS (Reward Positive Hygiene)
  // ==========================================

  /// 1. User Scans Websites (+35 pts)
  Future<void> onScanWebsite({String? url, required String userId}) async {
    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.scanWebsite,
      pointsDelta: ScoreFactorType.scanWebsite.defaultDelta,
      title: 'Scanned Website Target',
      description: url != null
          ? 'Inspected "$url" before navigation.'
          : 'Zero-trust web pre-flight verification conducted.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// 2. Reports Scams (+30 pts)
  Future<void> onReportScam({String? incident, required String userId}) async {
    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.reportScam,
      pointsDelta: ScoreFactorType.reportScam.defaultDelta,
      title: 'Crowdsourced Threat Contribution',
      description: incident != null
          ? 'Reported: $incident'
          : 'Flagged suspicious payload to global collective defense.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// 3. Enables Protection (+75 pts)
  Future<void> onEnableProtection({required String userId}) async {
    if (_healthScore != null && _healthScore!.isShieldActive) return;

    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.enableProtection,
      pointsDelta: ScoreFactorType.enableProtection.defaultDelta,
      title: 'Active Protection Shield Restored',
      description: 'System runtime zero-trust sentinel enabled.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  // ==========================================
  // SCORE DECREASING ACTIONS (Penalize Risk Exposure)
  // ==========================================

  /// 4. High-Risk Links Opened (-100 pts)
  Future<void> onOpenHighRiskLink({String? url, required String userId}) async {
    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.openHighRiskLink,
      pointsDelta: ScoreFactorType.openHighRiskLink.defaultDelta,
      title: 'High-Risk Phishing Link Opened',
      description: url != null
          ? 'Engaged unverified target: $url'
          : 'User visited flagged malicious domain despite browser warning.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// 5. Protection Disabled (-150 pts)
  Future<void> onDisableProtection({required String userId}) async {
    if (_healthScore != null && !_healthScore!.isShieldActive) return;

    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.disableProtection,
      pointsDelta: ScoreFactorType.disableProtection.defaultDelta,
      title: 'Protection Shield Deactivated',
      description: 'Local telephony & web interceptors paused.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// 6. Suspicious Activity Detected (-60 pts)
  Future<void> onSuspiciousActivityDetected(
      {String? details, required String userId}) async {
    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.suspiciousActivityDetected,
      pointsDelta: ScoreFactorType.suspiciousActivityDetected.defaultDelta,
      title: 'Suspicious Telephony or IOC Detected',
      description: details ?? 'Anomalous network/SMS pattern flagged.',
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// Toggle protection shield (links to enable/disable)
  Future<void> toggleShield({required String userId}) async {
    if (isShieldActive) {
      await onDisableProtection(userId: userId);
    } else {
      await onEnableProtection(userId: userId);
    }
  }

  /// Records a threat detection event with custom title and penalty
  Future<void> recordThreatDetected({
    required String title,
    required String description,
    int penalty = -60,
    required String userId,
  }) async {
    final event = ScoreFactorEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      type: ScoreFactorType.suspiciousActivityDetected,
      pointsDelta: penalty,
      title: title,
      description: description,
      timestamp: DateTime.now(),
    );

    _healthScore = await _repository.applyFactor(event, userId);
    notifyListeners();
  }

  /// Resets to baseline default (880 / 1000)
  Future<void> resetToBaseline({required String userId}) async {
    _healthScore = await _repository.resetScore(userId);
    notifyListeners();
  }
}
