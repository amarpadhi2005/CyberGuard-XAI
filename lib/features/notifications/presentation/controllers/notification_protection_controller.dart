import 'package:flutter/foundation.dart';
import '../../domain/entities/protected_notification.dart';
import '../../domain/repositories/notification_protection_repository.dart';
import '../../data/repositories/notification_protection_repository_impl.dart';

class NotificationProtectionController extends ChangeNotifier {
  final NotificationProtectionRepository _repository;

  bool _isAnalyzing = false;
  bool _protectionEnabled = true;
  ProtectedNotification? _activeWarningNotification;
  List<ProtectedNotification> _history = [];
  String? _errorMessage;

  // Predefined realistic test scenarios for the 5 target categories + safe benchmark
  final List<Map<String, String>> _simulationScenarios = [
    {
      'name': 'Fake KYC Expiration',
      'title': 'SBI Banking Alert',
      'body':
          'URGENT: Your bank account KYC has expired. Your account will be permanently frozen in 4 hours. Update KYC here: http://sbi-kyc-verify.top',
      'appSource': 'SMS / Messages',
      'category': 'FAKE_KYC',
    },
    {
      'name': 'OTP Theft Interception',
      'title': 'Google Verification',
      'body':
          'Your Google Security Code is 819-204. An agent is on call to verify your identity. Do not share unless requested by agent.',
      'appSource': 'SMS / Messages',
      'category': 'OTP_THEFT',
    },
    {
      'name': 'Bank Charge Scam',
      'title': 'Chase Bank Fraud Alert',
      'body':
          'Your debit card was charged \$1,492.30 at Walmart. If not you, call our 24/7 fraud helpline at +1-800-492-9182 immediately.',
      'appSource': 'SMS / Messages',
      'category': 'BANK_SCAMS',
    },
    {
      'name': 'Lottery Prize Fraud',
      'title': 'UK Tech Lottery Prize',
      'body':
          'Congratulations! Your mobile ID won £750,000 in the 2026 Tech Draw. Claim code: UK7892. Click to deposit processing fee: http://uk-lottery-claim.xyz',
      'appSource': 'WhatsApp',
      'category': 'LOTTERY',
    },
    {
      'name': 'Urgent Payment / CEO Fraud',
      'title': 'From: CEO David Vance',
      'body':
          'URGENT: I am in an executive board meeting and need you to purchase 5 x \$200 Apple Gift Cards immediately and send the codes here.',
      'appSource': 'Telegram',
      'category': 'URGENT_PAYMENT',
    },
    {
      'name': 'Legitimate Package Delivery',
      'title': 'Amazon Logistics',
      'body':
          'Your package with tracking #94001000 has been safely delivered to your front porch.',
      'appSource': 'Amazon App',
      'category': 'CLEAN',
    },
  ];

  NotificationProtectionController({
    NotificationProtectionRepository? repository,
  }) : _repository = repository ?? NotificationProtectionRepositoryImpl();

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  bool get protectionEnabled => _protectionEnabled;
  ProtectedNotification? get activeWarningNotification => _activeWarningNotification;
  List<ProtectedNotification> get history => List.unmodifiable(_history);
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get simulationScenarios => List.unmodifiable(_simulationScenarios);

  void toggleProtection(bool val) {
    _protectionEnabled = val;
    notifyListeners();
  }

  void dismissActiveWarning() {
    _activeWarningNotification = null;
    notifyListeners();
  }

  Future<void> loadHistory(String userId) async {
    _history = await _repository.getNotificationHistory(userId);
    notifyListeners();
  }

  /// Simulates receiving an incoming notification, runs Gemini analysis, saves to Firestore
  Future<ProtectedNotification> simulateIncomingNotification({
    required String title,
    required String body,
    required String appSource,
    required String userId,
  }) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analyzed = await _repository.analyzeNotification(
        title: title,
        body: body,
        appSource: appSource,
      );

      // Save analysis telemetry to Firestore
      await _repository.saveNotificationResult(analyzed, userId);

      _isAnalyzing = false;

      // If threat detected, display warning popup
      if (analyzed.isMalicious && _protectionEnabled) {
        _activeWarningNotification = analyzed;
      }

      // Reload local history
      _history = await _repository.getNotificationHistory(userId);
      notifyListeners();

      return analyzed;
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  /// User Action: Mark notification as Safe
  Future<void> markAsSafe({
    required ProtectedNotification notification,
    required String userId,
  }) async {
    await _repository.updateNotificationUserAction(
      notification.id,
      userId,
      NotificationUserAction.markedSafe,
    );
    _activeWarningNotification = null;
    _history = await _repository.getNotificationHistory(userId);
    notifyListeners();
  }

  /// User Action: Report Scam & Quarantine
  Future<void> reportScam({
    required ProtectedNotification notification,
    required String userId,
  }) async {
    await _repository.updateNotificationUserAction(
      notification.id,
      userId,
      NotificationUserAction.reportedScam,
    );
    _activeWarningNotification = null;
    _history = await _repository.getNotificationHistory(userId);
    notifyListeners();
  }

  /*
   * =========================================================================
   * TODO: ANDROID NATIVE NOTIFICATION INTEGRATION
   * =========================================================================
   * In a production physical Android environment:
   * 1. The native NotificationListenerService is defined in:
   *    `android/app/src/main/java/com/cyberguard/xai/services/notification/CyberNotificationListener.kt`
   *
   * 2. To bridge live status-bar notifications into Flutter:
   *    a) Register a Flutter MethodChannel / EventChannel in MainActivity:
   *       `val channel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.cyberguard.xai/live_notifications")`
   *    b) On `onNotificationPosted(sbn)`, dispatch the extracted `title`, `text`, and `packageName`
   *       through the EventChannel sink.
   *    c) In this controller, listen to `EventChannel("com.cyberguard.xai/live_notifications").receiveBroadcastStream()`
   *       and forward the event directly into `simulateIncomingNotification(...)`!
   * =========================================================================
   */
}
