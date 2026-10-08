import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../cyber_health/presentation/controllers/cyber_health_controller.dart';
import '../../../threat_history/domain/entities/threat_history_item.dart';
import '../../../threat_history/presentation/controllers/threat_history_controller.dart';
import '../../../xai_result/domain/entities/xai_result_model.dart';
import '../../domain/entities/demo_simulation_scenario.dart';

class DemoModeController extends ChangeNotifier {
  final List<DemoSimulationScenario> _scenarios =
      DemoSimulationScenario.getAllScenarios();

  DemoSimulationScenario? _activeScenario;
  int _currentStepIndex = 0;
  bool _isSimulating = false;
  String _statusMessage = '';

  // Getters
  List<DemoSimulationScenario> get scenarios => _scenarios;
  DemoSimulationScenario? get activeScenario => _activeScenario;
  int get currentStepIndex => _currentStepIndex;
  bool get isSimulating => _isSimulating;
  String get statusMessage => _statusMessage;

  /// Executes full simulated attack and AI analysis workflow
  Future<XaiResultModel?> executeSimulation({
    required BuildContext context,
    required DemoSimulationScenario scenario,
    required String userId,
  }) async {
    if (_isSimulating) return null;

    _isSimulating = true;
    _activeScenario = scenario;
    _currentStepIndex = 0;
    _statusMessage = scenario.simulationSteps.first;
    notifyListeners();

    try {
      // Step-by-step telemetry execution with micro-delays for demonstration
      for (int i = 0; i < scenario.simulationSteps.length; i++) {
        _currentStepIndex = i;
        _statusMessage = scenario.simulationSteps[i];
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 700));
      }

      // 1. Build and record Threat History item
      final threatItem = ThreatHistoryItem(
        id: 'SIM-${scenario.id.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
        title: scenario.simulatedTarget,
        category: scenario.category,
        threatType: scenario.threatType,
        riskScore: scenario.riskScore,
        severity: ThreatSeverity.fromRiskScore(scenario.riskScore),
        reason: '[SIMULATION PROBE] ${scenario.reason}',
        recommendedAction: scenario.recommendedAction,
        source: 'Gemini 2.5 Flash / Demo Engine',
        timestamp: DateTime.now(),
        metadata: {
          'is_simulation': true,
          'scenario_id': scenario.id,
          'simulated_at': DateTime.now().toIso8601String(),
        },
      );

      if (context.mounted) {
        await context
            .read<ThreatHistoryController>()
            .recordThreatItem(threatItem, userId);
      }

      // 2. Adjust Cyber Health Score (-60 or -100 penalty for high-risk threat)
      if (context.mounted) {
        await context.read<CyberHealthController>().recordThreatDetected(
              title: '[SIMULATION] ${scenario.title}',
              description: scenario.reason,
              penalty: scenario.healthScorePenalty,
              userId: userId,
            );
      }

      _isSimulating = false;
      notifyListeners();

      return scenario.xaiModel;
    } catch (e) {
      debugPrint('Error executing demo simulation: $e');
      _isSimulating = false;
      notifyListeners();
      return null;
    }
  }

  void cancelSimulation() {
    _isSimulating = false;
    _activeScenario = null;
    _currentStepIndex = 0;
    notifyListeners();
  }
}
