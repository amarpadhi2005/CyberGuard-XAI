import 'package:flutter/foundation.dart';
import '../../domain/entities/call_scan_result.dart';
import '../../domain/repositories/scam_call_repository.dart';
import '../../data/repositories/scam_call_repository_impl.dart';

class ScamCallController extends ChangeNotifier {
  final ScamCallRepository _repository;

  bool _isAnalyzing = false;
  bool _isIncomingCallActive = false;
  CallScanResult? _currentScan;
  List<CallScanResult> _history = [];
  String? _errorMessage;

  // Predefined demo numbers covering all 4 verdicts
  final List<Map<String, String>> _demoPresets = [
    {
      'label': 'FRAUD (IRS/Bank)',
      'number': '+1 (800) 492-9182',
      'verdict': 'FRAUD',
    },
    {
      'label': 'SPAM (Robocall)',
      'number': '+1 (888) 203-9128',
      'verdict': 'SPAM',
    },
    {
      'label': 'SAFE (Apple Care)',
      'number': '+1 (800) 275-2273',
      'verdict': 'SAFE',
    },
    {
      'label': 'UNKNOWN (Private)',
      'number': '+1 (312) 555-0199',
      'verdict': 'UNKNOWN',
    },
  ];

  ScamCallController({ScamCallRepository? repository})
      : _repository = repository ?? ScamCallRepositoryImpl();

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  bool get isIncomingCallActive => _isIncomingCallActive;
  CallScanResult? get currentScan => _currentScan;
  List<CallScanResult> get history => List.unmodifiable(_history);
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get demoPresets => List.unmodifiable(_demoPresets);

  Future<void> loadHistory(String userId) async {
    _history = await _repository.getScanHistory(userId);
    notifyListeners();
  }

  /// Evaluates phone number and saves scan record to Firestore
  Future<CallScanResult?> analyzeNumber(String rawNumber, String userId) async {
    final trimmed = rawNumber.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Please input a valid phone number.';
      notifyListeners();
      return null;
    }

    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.analyzePhoneNumber(trimmed);
      await _repository.saveCallScan(result, userId);

      _currentScan = result;
      _history = await _repository.getScanHistory(userId);
      _isAnalyzing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Triggers full-screen simulated incoming call overlay
  Future<void> simulateIncomingCall(String rawNumber, String userId) async {
    final result = await analyzeNumber(rawNumber, userId);
    if (result != null) {
      _isIncomingCallActive = true;
      notifyListeners();
    }
  }

  void dismissIncomingCall() {
    _isIncomingCallActive = false;
    notifyListeners();
  }

  /// Blocks number in Firestore
  Future<void> blockNumber(String phoneNumber, String userId) async {
    await _repository.blockPhoneNumber(phoneNumber, userId);
    if (_currentScan != null && _currentScan!.phoneNumber == phoneNumber) {
      _currentScan = _currentScan!.copyWith(isBlocked: true);
    }
    _history = await _repository.getScanHistory(userId);
    notifyListeners();
  }

  void clearCurrentScan() {
    _currentScan = null;
    _errorMessage = null;
    notifyListeners();
  }
}
