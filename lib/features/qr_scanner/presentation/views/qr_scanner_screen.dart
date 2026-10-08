import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../domain/entities/qr_camera_permission_state.dart';
import '../../domain/entities/qr_payload_info.dart';
import '../controllers/qr_scanner_controller.dart';
import '../widgets/qr_camera_viewfinder.dart';
import '../widgets/qr_security_result_sheet.dart';

class QrScannerScreen extends StatefulWidget {
  final bool autoCheckPermission;

  const QrScannerScreen({
    super.key,
    this.autoCheckPermission = true,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Initial permission check strictly upon entering QR scanner
    if (widget.autoCheckPermission) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<QrScannerController>().checkCameraPermission();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_scannerController.value.isRunning) {
        _scannerController.stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      final qrController = context.read<QrScannerController>();
      if (qrController.permissionState == QrCameraPermissionState.granted &&
          !qrController.isProcessingQr &&
          !_scannerController.value.isRunning &&
          !_scannerController.value.isStarting) {
        _scannerController.start();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_scannerController.value.isRunning) {
      _scannerController.stop();
    }
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcodeCapture(BarcodeCapture capture) {
    final qrController = context.read<QrScannerController>();
    if (qrController.isProcessingQr || qrController.isAnalyzing) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        // Pause camera scanning immediately upon detecting valid code
        _scannerController.stop();

        qrController.onBarcodeDetected(
          raw,
          onDetected: (payload) {
            _showDetectedPayloadModal(payload);
          },
        );
        break;
      }
    }
  }

  void _showDetectedPayloadModal(QrPayloadInfo payload) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (ctx) => QrPayloadDetectedSheet(
        payload: payload,
        onAnalyze: () async {
          Navigator.pop(ctx);
          _runSecurityAnalysis();
        },
        onScanAnother: () {
          Navigator.pop(ctx);
          _resumeScanner();
        },
        onCancel: () {
          Navigator.pop(ctx);
          _resumeScanner();
        },
      ),
    );
  }

  Future<void> _runSecurityAnalysis() async {
    final qrController = context.read<QrScannerController>();

    // Show analyzing progress overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(CyberColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Analyzing QR Destination...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Inspecting threat intelligence, lexical signatures & SSL reality',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final success = await qrController.analyzeDetectedPayload();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss progress dialog

    if (success && qrController.securityResult != null) {
      _showSecurityResultModal();
    } else {
      _showAnalysisError(qrController.analysisErrorMessage ?? 'Security analysis failed.');
    }
  }

  void _showSecurityResultModal() {
    final qrController = context.read<QrScannerController>();
    final result = qrController.securityResult;
    if (result == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (ctx) => QrSecurityResultSheet(
        result: result,
        onScanAnother: () {
          Navigator.pop(ctx);
          _resumeScanner();
        },
        onBack: () {
          Navigator.pop(ctx);
          _resumeScanner();
        },
      ),
    );
  }

  void _showAnalysisError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Analysis Notice',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: CyberColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: CyberColors.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resumeScanner();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resumeScanner() {
    final qrController = context.read<QrScannerController>();
    qrController.resumeScanning();
    if (!_scannerController.value.isRunning &&
        !_scannerController.value.isStarting) {
      _scannerController.start();
    }
  }

  Future<void> _restartCamera() async {
    try {
      if (_scannerController.value.isRunning) {
        await _scannerController.stop();
      }
      await _scannerController.start();
      setState(() {});
    } catch (e) {
      debugPrint('[QrScanner] Camera restart attempt notice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrController = context.watch<QrScannerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Core State-Driven View
          _buildBody(context, qrController),

          // 2. Fixed App Header (QR Security Scanner, Flash, Close)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      tooltip: 'Close Scanner',
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Header Title
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'QR SECURITY SCANNER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Physical Camera Viewfinder',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    // Flashlight Toggle Button (Requirement 16)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: qrController.isFlashOn
                              ? CyberColors.primary
                              : const Color(0xFF0F172A).withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          qrController.isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      tooltip: qrController.isFlashOn ? 'Flash ON' : 'Flash OFF',
                      onPressed: qrController.permissionState == QrCameraPermissionState.granted
                          ? () => qrController.toggleFlash(_scannerController)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, QrScannerController qrController) {
    switch (qrController.permissionState) {
      case QrCameraPermissionState.checking:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CyberColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Checking camera authorization...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        );

      case QrCameraPermissionState.promptExplanation:
        return _buildPermissionExplanationCard(
          context: context,
          onContinue: () => qrController.requestCameraPermission(),
          onCancel: () => Navigator.pop(context),
        );

      case QrCameraPermissionState.denied:
        return _buildPermissionDeniedCard(
          context: context,
          onTryAgain: () => qrController.requestCameraPermission(),
          onCancel: () => Navigator.pop(context),
        );

      case QrCameraPermissionState.permanentlyDenied:
        return _buildPermanentlyDeniedCard(
          context: context,
          onOpenSettings: () => qrController.openSettingsPage(),
          onCancel: () => Navigator.pop(context),
        );

      case QrCameraPermissionState.error:
        return _buildCameraErrorCard(
          context: context,
          errorMessage: qrController.cameraErrorMessage ?? 'Camera initialization failed.',
          onTryAgain: () => qrController.checkCameraPermission(),
          onBack: () => Navigator.pop(context),
        );

      case QrCameraPermissionState.granted:
        return Stack(
          fit: StackFit.expand,
          children: [
            // Live Physical Camera Preview
            MobileScanner(
              controller: _scannerController,
              onDetect: _handleBarcodeCapture,
              fit: BoxFit.cover,
              placeholderBuilder: (context) {
                return Container(
                  color: const Color(0xFF020617),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 44,
                          height: 44,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                CyberColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'INITIALIZING CAMERA SENSOR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Acquiring optical frame feed & focus lock...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error) {
                return Container(
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.videocam_off_rounded,
                            color: CyberColors.danger,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Camera Hardware Unavailable',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          error.errorDetails?.message ??
                              'Camera sensor initialization failed [${error.errorCode.name}].',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _restartCamera,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CyberColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('RETRY CAMERA'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Viewfinder reticle overlay & privacy disclaimer
            QrCameraViewfinder(
              isScanning: !qrController.isProcessingQr && !qrController.isAnalyzing,
            ),
          ],
        );
    }
  }

  /// State 2: Pre-permission explanation dialog (Requirement 2 & 3)
  Widget _buildPermissionExplanationCard({
    required BuildContext context,
    required VoidCallback onContinue,
    required VoidCallback onCancel,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: CyberColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Camera Access Required',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Camera access is required to scan QR codes and check their destinations for potential security threats.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: CyberColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'CANCEL',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: CyberColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// State 3: User denied permission (Requirement 3)
  Widget _buildPermissionDeniedCard({
    required BuildContext context,
    required VoidCallback onTryAgain,
    required VoidCallback onCancel,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                color: Color(0xFFDC2626),
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Camera Permission Required',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Camera permission is required to scan QR codes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: CyberColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'TRY AGAIN',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'CANCEL',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: CyberColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// State 4: Permanently denied permission (Requirement 3)
  Widget _buildPermanentlyDeniedCard({
    required BuildContext context,
    required VoidCallback onOpenSettings,
    required VoidCallback onCancel,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Color(0xFFD97706),
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Camera Permission Disabled',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Camera permission is disabled for CyberGuard. Please enable it in Android system settings to continue scanning.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: CyberColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  'OPEN APP SETTINGS',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'CANCEL',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: CyberColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hardware/Camera Error State (Requirement 17 & 18)
  Widget _buildCameraErrorCard({
    required BuildContext context,
    required String errorMessage,
    required VoidCallback onTryAgain,
    required VoidCallback onBack,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_outlined,
                color: Color(0xFF64748B),
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'CAMERA ERROR',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to access the camera. Another application may currently be using the camera or camera hardware is temporarily unavailable.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: CyberColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'TRY AGAIN',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBack,
              child: Text(
                'BACK',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: CyberColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
