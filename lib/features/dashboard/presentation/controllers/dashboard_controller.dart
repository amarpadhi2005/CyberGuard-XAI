import 'dart:async';
import 'package:flutter/foundation.dart';

enum ThreatSeverity { critical, high, medium, safe }

class SecurityAlert {
  final String id;
  final String title;
  final String description;
  final ThreatSeverity severity;
  final String timestamp;
  final String vector;
  final String actionTaken;

  const SecurityAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.vector,
    required this.actionTaken,
  });
}

class ActivityItem {
  final String id;
  final String title;
  final String details;
  final String timestamp;
  final String category;
  final bool isSecure;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.details,
    required this.timestamp,
    required this.category,
    required this.isSecure,
  });
}

class DashboardController extends ChangeNotifier {
  int _currentTabIndex = 0;
  int _cyberScore = 880; // Scaled to 1000
  bool _isShieldActive = true;

  // Sub-scores (out of 1000)
  final int _identityScore = 980;
  final int _networkScore = 910;
  final int _deviceScore = 940;

  // Today's metrics
  final int _threatsBlockedToday = 18;
  final int _activeBreaches = 0;
  final int _urlsInspected = 14892;
  final double _interceptionRate = 99.9;
  final int _aiLatencyMs = 38;

  // Scanning state
  bool _isScanning = false;
  double _scanProgress = 0.0;
  String _scanStatusText = 'IDLE';
  int _scannedItemsCount = 0;
  int _scanThreatsDetected = 0;
  Timer? _scanTimer;

  // Alerts
  final List<SecurityAlert> _alerts = [
    const SecurityAlert(
      id: 'ALT-9821',
      title: 'Zero-Day Phishing URL Intercepted',
      description: 'Domain masquerading as bank verification payload defanged before browser render.',
      severity: ThreatSeverity.critical,
      timestamp: '4m ago',
      vector: 'Web Shield',
      actionTaken: 'Access Blocked',
    ),
    const SecurityAlert(
      id: 'ALT-9820',
      title: 'Synthetic Voice Clone Attempt Blocked',
      description: 'Caller ID VoIP spoofing with 89% AI speech synthesis probability flagged.',
      severity: ThreatSeverity.high,
      timestamp: '22m ago',
      vector: 'Voice Sentinel',
      actionTaken: 'Call Silenced & Tagged',
    ),
    const SecurityAlert(
      id: 'ALT-9819',
      title: 'Malicious QR Payment Redirect',
      description: 'Dynamic URI payload contained unauthorized intent redirection to external APK.',
      severity: ThreatSeverity.medium,
      timestamp: '1h ago',
      vector: 'QR Scanner',
      actionTaken: 'Payload Blocked',
    ),
    const SecurityAlert(
      id: 'ALT-9818',
      title: 'AI Threat DNA Definitions Updated',
      description: 'Neural model weights synchronized with global CyberGuard intelligence cloud.',
      severity: ThreatSeverity.safe,
      timestamp: '3h ago',
      vector: 'Cloud Engine',
      actionTaken: 'Synced (v2.4.1)',
    ),
  ];

  // Activities
  final List<ActivityItem> _activities = [
    const ActivityItem(
      id: 'ACT-101',
      title: 'Deepfake Biometric Verification',
      details: 'Video call frames audited. Facial landmarks 99.4% authentic.',
      timestamp: '14:48',
      category: 'VISION AI',
      isSecure: true,
    ),
    const ActivityItem(
      id: 'ACT-102',
      title: 'SMS Scam Pattern Neutralized',
      details: 'Suspicious lottery payout notification isolated into sandbox.',
      timestamp: '13:12',
      category: 'SMS SENTINEL',
      isSecure: true,
    ),
    const ActivityItem(
      id: 'ACT-103',
      title: 'Public Wi-Fi DNS Tunneling Audit',
      details: 'Airport Wi-Fi checked. Enforced DNS-over-HTTPS encryption.',
      timestamp: '11:25',
      category: 'NETWORK',
      isSecure: true,
    ),
    const ActivityItem(
      id: 'ACT-104',
      title: 'Background Process Memory Audit',
      details: '142 running processes checked for code injection hooks.',
      timestamp: '09:05',
      category: 'DEVICE',
      isSecure: true,
    ),
  ];

  // Getters
  int get currentTabIndex => _currentTabIndex;
  int get cyberScore => _cyberScore;
  bool get isShieldActive => _isShieldActive;
  int get identityScore => _identityScore;
  int get networkScore => _networkScore;
  int get deviceScore => _deviceScore;
  int get threatsBlockedToday => _threatsBlockedToday;
  int get activeBreaches => _activeBreaches;
  int get urlsInspected => _urlsInspected;
  double get interceptionRate => _interceptionRate;
  int get aiLatencyMs => _aiLatencyMs;

  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  String get scanStatusText => _scanStatusText;
  int get scannedItemsCount => _scannedItemsCount;
  int get scanThreatsDetected => _scanThreatsDetected;

  List<SecurityAlert> get alerts => List.unmodifiable(_alerts);
  List<ActivityItem> get activities => List.unmodifiable(_activities);

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleProtectionShield() {
    _isShieldActive = !_isShieldActive;
    _cyberScore = _isShieldActive ? 880 : 620;
    notifyListeners();
  }

  void acknowledgeAlert(String id) {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// Start an animated multi-phase Quick Security Scan
  void startQuickScan({VoidCallback? onComplete}) {
    if (_isScanning) return;

    _isScanning = true;
    _scanProgress = 0.0;
    _scannedItemsCount = 0;
    _scanThreatsDetected = 0;
    _scanStatusText = 'INITIALIZING ZERO-TRUST SCAN...';
    notifyListeners();

    final phases = [
      'AUDITING RUNTIME PROCESS MEMORY...',
      'INSPECTING NETWORK SOCKETS & DNS...',
      'ANALYZING RECENT SMS & URL PAYLOADS...',
      'VERIFYING CRYPTOGRAPHIC STORAGE KEYS...',
      'EVALUATING DEEPFAKE DETECTION SIGNATURES...',
      'CORRELATING THREAT DNA EVENTS...',
      'SYSTEM DEFENSE INTEGRITY VERIFIED',
    ];

    int step = 0;
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      step++;
      _scanProgress = (step / (phases.length * 2)).clamp(0.0, 1.0);
      _scannedItemsCount += 142;

      int phaseIndex = (step / 2).floor().clamp(0, phases.length - 1);
      _scanStatusText = phases[phaseIndex];

      if (_scanProgress >= 1.0) {
        timer.cancel();
        _isScanning = false;
        _scanStatusText = 'SCAN COMPLETE: ZERO THREATS DETECTED';
        _cyberScore = 950;
        notifyListeners();
        onComplete?.call();
      } else {
        notifyListeners();
      }
    });
  }

  void cancelScan() {
    _scanTimer?.cancel();
    _isScanning = false;
    _scanProgress = 0.0;
    _scanStatusText = 'SCAN ABORTED';
    notifyListeners();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}
