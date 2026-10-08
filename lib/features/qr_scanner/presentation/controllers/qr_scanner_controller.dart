import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../scanner/data/repositories/url_scanner_repository_impl.dart';
import '../../../scanner/domain/entities/url_scan_result.dart';
import '../../../scanner/domain/repositories/url_scanner_repository.dart';
import '../../domain/entities/qr_camera_permission_state.dart';
import '../../domain/entities/qr_payload_info.dart';

class QrScannerController extends ChangeNotifier {
  final UrlScannerRepository _urlRepository;

  QrCameraPermissionState _permissionState = QrCameraPermissionState.checking;
  bool _isProcessingQr = false;
  bool _isAnalyzing = false;
  bool _isFlashOn = false;
  String? _cameraErrorMessage;
  String? _analysisErrorMessage;

  QrPayloadInfo? _detectedPayload;
  UrlScanResult? _securityResult;

  QrScannerController({UrlScannerRepository? urlRepository})
      : _urlRepository = urlRepository ?? UrlScannerRepositoryImpl();

  // Getters
  QrCameraPermissionState get permissionState => _permissionState;
  bool get isProcessingQr => _isProcessingQr;
  bool get isAnalyzing => _isAnalyzing;
  bool get isFlashOn => _isFlashOn;
  String? get cameraErrorMessage => _cameraErrorMessage;
  String? get analysisErrorMessage => _analysisErrorMessage;
  QrPayloadInfo? get detectedPayload => _detectedPayload;
  UrlScanResult? get securityResult => _securityResult;

  /// Inspects Android CAMERA permission status without automatically displaying a system dialog.
  Future<void> checkCameraPermission() async {
    _permissionState = QrCameraPermissionState.checking;
    _cameraErrorMessage = null;
    notifyListeners();

    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        _permissionState = QrCameraPermissionState.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _permissionState = QrCameraPermissionState.permanentlyDenied;
      } else {
        // Not granted yet; show in-app rationale explanation before calling system prompt
        _permissionState = QrCameraPermissionState.promptExplanation;
      }
    } catch (e) {
      _permissionState = QrCameraPermissionState.error;
      _cameraErrorMessage = 'Unable to check camera permission: $e';
    }

    notifyListeners();
  }

  /// Explicitly requests Android CAMERA permission following the user's consent on the explanation card.
  Future<void> requestCameraPermission() async {
    _cameraErrorMessage = null;

    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        _permissionState = QrCameraPermissionState.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _permissionState = QrCameraPermissionState.permanentlyDenied;
      } else {
        _permissionState = QrCameraPermissionState.denied;
      }
    } catch (e) {
      _permissionState = QrCameraPermissionState.error;
      _cameraErrorMessage = 'Permission request failed: $e';
    }

    notifyListeners();
  }

  /// Launches the official OS settings page so the user can re-enable permission if permanently denied.
  Future<void> openSettingsPage() async {
    await openAppSettings();
  }

  /// Sets an explicit camera hardware or initialization error (without fake security terminology).
  void setCameraError(String message) {
    _cameraErrorMessage = message;
    _permissionState = QrCameraPermissionState.error;
    notifyListeners();
  }

  /// Toggles flashlight torch safely on supported physical camera hardware.
  Future<void> toggleFlash(MobileScannerController cameraController) async {
    try {
      await cameraController.toggleTorch();
      _isFlashOn = !_isFlashOn;
      notifyListeners();
    } catch (_) {
      // Hardware without flash or busy torch
    }
  }

  /// Processes raw QR detection from the live camera feed with an immediate duplicate scan lock.
  void onBarcodeDetected(
    String rawCode, {
    required void Function(QrPayloadInfo payload) onDetected,
  }) {
    // Prevent duplicate scans across consecutive camera frames
    if (_isProcessingQr || _isAnalyzing) return;

    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) return;

    _isProcessingQr = true;
    _analysisErrorMessage = null;
    _securityResult = null;

    final payload = QrPayloadInfo.parse(trimmed);
    _detectedPayload = payload;
    notifyListeners();

    onDetected(payload);
  }

  /// Dispatches the detected URL to the existing CyberGuard URL security pipeline.
  /// Never executes or launches external links.
  Future<bool> analyzeDetectedPayload() async {
    final payload = _detectedPayload;
    if (payload == null) return false;

    // If payload is plain text or non-URL scheme, no URL forensic analysis is required
    if (!payload.isUrl || payload.originalUrl == null) {
      return true;
    }

    _isAnalyzing = true;
    _analysisErrorMessage = null;
    notifyListeners();

    try {
      // Reuses the exact existing URL forensic analysis pipeline (validation, lexical, risk engine, Gemini)
      final result = await _urlRepository.scanUrl(payload.originalUrl!);
      _securityResult = result;
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAnalyzing = false;
      _analysisErrorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Resets scan lock and state to allow capturing another QR code from the camera.
  void resumeScanning() {
    _isProcessingQr = false;
    _isAnalyzing = false;
    _detectedPayload = null;
    _securityResult = null;
    _analysisErrorMessage = null;
    notifyListeners();
  }

  /// Sets permission state deterministically for automated widget testing.
  @visibleForTesting
  void setPermissionStateForTest(QrCameraPermissionState state) {
    _permissionState = state;
    notifyListeners();
  }

  /// Complete reset on view disposal or exit.
  void reset() {
    _isProcessingQr = false;
    _isAnalyzing = false;
    _isFlashOn = false;
    _detectedPayload = null;
    _securityResult = null;
    _analysisErrorMessage = null;
    _cameraErrorMessage = null;
  }
}
