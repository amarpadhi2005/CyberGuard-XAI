import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/url_scan_result.dart';
import '../../domain/repositories/url_scanner_repository.dart';
import '../../data/repositories/url_scanner_repository_impl.dart';
import '../../data/services/url_forensic_utils.dart';

class UrlScannerController extends ChangeNotifier {
  final UrlScannerRepository _repository;

  UrlScanResult? _currentResult;
  bool _isScanning = false;
  String? _errorMessage;
  String _scanPhase = 'STANDBY';
  List<UrlScanResult> _history = [];
  DateTime? _lastScanTime;

  UrlScannerController({UrlScannerRepository? repository})
      : _repository = repository ?? UrlScannerRepositoryImpl() {
    _loadHistory();
  }

  // Getters
  UrlScanResult? get currentResult => _currentResult;
  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  String get scanPhase => _scanPhase;
  List<UrlScanResult> get history => List.unmodifiable(_history);

  Future<void> _loadHistory() async {
    _history = await _repository.getRecentScans();
    notifyListeners();
  }

  Future<bool> scanUrl(String inputUrl, {bool isQuickTest = false}) async {
    final trimmed = inputUrl.trim();

    // 1. Client-Side Input Validation
    try {
      UrlForensicUtils.validateRawInput(trimmed);
    } on UrlValidationException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Invalid URL format. Please provide a valid web address.';
      notifyListeners();
      return false;
    }

    // 2. Client-Side Rate Limiting (Prevent accidental rapid multi-taps)
    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!).inMilliseconds < 800) {
      _errorMessage = 'Scan rate limit reached. Please wait a moment before trying again.';
      notifyListeners();
      return false;
    }
    _lastScanTime = now;

    _isScanning = true;
    _errorMessage = null;
    _currentResult = null;
    _scanPhase = 'NORMALIZING & EXTRACTING LEXICAL SIGNATURES...';
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _scanPhase = 'TRANSMITTING TARGET TO THREAT INTELLIGENCE CORE...';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 350));
      _scanPhase = 'EVALUATING BRAND IMPERSONATION & TYPOSQUATTING...';
      notifyListeners();

      // Execute forensic scan using the single source of truth
      final result = await _repository.scanUrl(trimmed, isQuickTest: isQuickTest);

      await Future.delayed(const Duration(milliseconds: 250));
      _scanPhase = 'SYNTHESIZING VERIFIED EVIDENCE & DEFANGING...';
      notifyListeners();

      _currentResult = result;
      _history = await _repository.getRecentScans();
      _isScanning = false;
      _scanPhase = 'ANALYSIS COMPLETE';
      notifyListeners();
      return true;
    } on UrlValidationException catch (e) {
      _errorMessage = e.message;
      _isScanning = false;
      _scanPhase = 'SCAN FAILED';
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage = 'Network connection unavailable. Please check your internet connection.';
      _isScanning = false;
      _scanPhase = 'SCAN FAILED';
      notifyListeners();
      return false;
    } on TimeoutException {
      _errorMessage = 'Threat analysis timed out. Please try again.';
      _isScanning = false;
      _scanPhase = 'SCAN FAILED';
      notifyListeners();
      return false;
    } catch (e) {
      final cleanMsg = e.toString().replaceAll('Exception: ', '').trim();
      _errorMessage = cleanMsg.isNotEmpty
          ? cleanMsg
          : 'Unable to complete threat analysis. Please try again.';
      _isScanning = false;
      _scanPhase = 'SCAN FAILED';
      notifyListeners();
      return false;
    }
  }

  void clearResult() {
    _currentResult = null;
    _errorMessage = null;
    _scanPhase = 'STANDBY';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
