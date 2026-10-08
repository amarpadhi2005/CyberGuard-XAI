import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class ScanCheckItem {
  final String label;
  final String detail;
  bool isCompleted;
  bool isPassed;

  ScanCheckItem({
    required this.label,
    required this.detail,
    this.isCompleted = false,
    this.isPassed = true,
  });
}

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _progress = 0.05;
  String _currentStatus = 'Initializing Autonomous Security Engine...';
  Timer? _scanTimer;

  final List<ScanCheckItem> _checklist = [
    ScanCheckItem(
      label: 'Installed Applications',
      detail: '84 user packages verified clean',
    ),
    ScanCheckItem(
      label: 'Unknown Sources & Sideloads',
      detail: 'Zero rogue package installers detected',
    ),
    ScanCheckItem(
      label: 'Accessibility & Overlay Defense',
      detail: 'No screen tampering or clickjacking detected',
    ),
    ScanCheckItem(
      label: 'Network & Tunnel Integrity',
      detail: 'DNS encrypted • TLS 1.3 certified',
    ),
    ScanCheckItem(
      label: 'Root & Bootloader Integrity',
      detail: 'Hardware Keystore backed • Unmodified',
    ),
    ScanCheckItem(
      label: 'Developer Options & Mock Locations',
      detail: 'System debugging ports hardened',
    ),
    ScanCheckItem(
      label: 'AI Neural Heuristic Correlation',
      detail: 'Gemini 2.5 Flash threat models synchronized',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startSimulatedAiScan();
  }

  void _startSimulatedAiScan() {
    const totalTicks = 50;
    int tick = 0;

    _scanTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      tick++;
      final p = (tick / totalTicks).clamp(0.0, 1.0);

      setState(() {
        _progress = p;

        if (p < 0.15) {
          _currentStatus = 'Scanning Installed Applications & Packages...';
          _checklist[0].isCompleted = true;
        } else if (p < 0.30) {
          _currentStatus = 'Auditing Unknown APK Sources & Root Signatures...';
          _checklist[1].isCompleted = true;
        } else if (p < 0.45) {
          _currentStatus = 'Inspecting Accessibility Abuse & Overlays...';
          _checklist[2].isCompleted = true;
        } else if (p < 0.60) {
          _currentStatus = 'Scanning Network, Encrypted DNS & VPN Status...';
          _checklist[3].isCompleted = true;
        } else if (p < 0.75) {
          _currentStatus = 'Verifying Hardware Integrity & Keystore...';
          _checklist[4].isCompleted = true;
        } else if (p < 0.88) {
          _currentStatus = 'Checking Developer Options & Mock Location...';
          _checklist[5].isCompleted = true;
        } else if (p < 0.98) {
          _currentStatus = 'Running Gemini AI Heuristic Correlation...';
          _checklist[6].isCompleted = true;
        } else {
          _currentStatus = 'Generating Enterprise Security Score...';
        }
      });

      if (tick >= totalTicks) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/risk_report');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F8FC),
              Color(0xFFEFF6FF),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top Header
                Text(
                  'Autonomous Device Scan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zero-Trust Heuristic Inspection in Progress',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CyberColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // Center Scanning Radar with Shield
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Rotating Radar Sweep
                      AnimatedBuilder(
                        animation: _radarController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _radarController.value * 2 * pi,
                            child: CustomPaint(
                              size: const Size(220, 220),
                              painter: _RadarSweepPainter(),
                            ),
                          );
                        },
                      ),

                      // Outer Progress Circle
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 6.0,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF3B82F6),
                          ),
                        ),
                      ),

                      // Pulsing Center Glowing Shield
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: CyberColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.security_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Progress Percentage Indicator Pill
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C0F172A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            '${(_progress * 100).toInt()}% COMPLETE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.primaryDark,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Live Status Marquee Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CyberColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentStatus,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Live Checklist
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'TELEMETRY AUDIT PROGRESS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: CyberColors.textMuted,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _checklist.length,
                    itemBuilder: (context, index) {
                      final item = _checklist[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isCompleted
                                ? const Color(0xFFBBF7D0)
                                : const Color(0xFFF1F5F9),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isCompleted
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFE2E8F0),
                              ),
                              child: Center(
                                child: item.isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: item.isCompleted
                                          ? CyberColors.textPrimary
                                          : CyberColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    item.isCompleted
                                        ? item.detail
                                        : 'Awaiting inspection pass...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: item.isCompleted
                                          ? const Color(0xFF16A34A)
                                          : CyberColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarSweepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF3B82F6).withOpacity(0.0),
          const Color(0xFF38BDF8).withOpacity(0.35),
        ],
        stops: const [0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
