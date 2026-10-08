import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_pressable.dart';
import '../controllers/auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      title: 'REAL-TIME AI THREAT ENGINE',
      subtitle:
          'Heuristic and deep neural models inspect phishing URLs, scam calls, malicious QR codes, and SMS payloads in real-time.',
      badgeText: 'LAYER 1: HEURISTIC MONITOR',
      icon: Icons.shield_rounded,
      accentColor: CyberColors.neonCyan,
    ),
    OnboardingItem(
      title: 'DEEPFAKE & SYNTHETIC MEDIA RADAR',
      subtitle:
          'Frame-by-frame neural vision and facial anomaly detection expose AI-synthesized impersonation and manipulated video calls.',
      badgeText: 'LAYER 2: BIOMETRIC SHIELD',
      icon: Icons.remove_red_eye_outlined,
      accentColor: CyberColors.neonPink,
    ),
    OnboardingItem(
      title: 'AUTONOMOUS THREAT DNA',
      subtitle:
          'Multi-channel event correlation links suspicious calls, phishing links, and unauthorized transactions into unified threat campaigns.',
      badgeText: 'LAYER 3: CAMPAIGN GRAPH',
      icon: Icons.hub_outlined,
      accentColor: CyberColors.cyberPurple,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final controller = context.read<AuthController>();
    await controller.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _slides.length - 1;
    final currentItem = _slides[_currentIndex];

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Dynamic Background Glow that shifts with slide accent
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              top: -80,
              left: _currentIndex == 1 ? -40 : -100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      currentItem.accentColor.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Top Bar: Skip Button
            Positioned(
              top: 12,
              right: 20,
              child: CyberPressable(
                semanticLabel: 'Skip Onboarding',
                onTap: _completeOnboarding,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    'SKIP PROTOCOL',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: CyberColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // Page View with Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 120,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // Glassmorphic Animated Icon Emblem
                            GlassmorphicContainer(
                              width: 136,
                              height: 136,
                              borderRadius: 24,
                              padding: EdgeInsets.zero,
                              backgroundColor: CyberColors.cardBg.withOpacity(0.6),
                              border: Border.all(
                                color: item.accentColor.withOpacity(0.7),
                                width: 1.5,
                              ),
                              child: Center(
                                child: Icon(
                                  item.icon,
                                  size: 62,
                                  color: item.accentColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Cyber Layer Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: item.accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: item.accentColor.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                item.badgeText,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                  color: item.accentColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Slide Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.8,
                                color: CyberColors.textPrimary,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Slide Subtitle
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                                color: CyberColors.textMuted,
                                height: 1.55,
                              ),
                            ),

                            const SizedBox(height: 140), // Spacer for bottom controls
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Bottom Navigation & Controls
            Positioned(
              bottom: 28,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Page Indicators with spring width animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 28 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: _currentIndex == index
                              ? currentItem.accentColor
                              : CyberColors.cardBorder,
                          boxShadow: _currentIndex == index
                              ? [
                                  BoxShadow(
                                    color: currentItem.accentColor.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tactile Cyber Action Button
                  CyberPressable(
                    semanticLabel: isLastPage
                        ? 'Initialize Defense Shield'
                        : 'Next Onboarding Step',
                    child: CyberButton(
                      text: isLastPage
                          ? 'INITIALIZE DEFENSE SHIELD'
                          : 'NEXT PROTOCOL',
                      icon: isLastPage ? Icons.lock_open : Icons.arrow_forward,
                      onPressed: () {
                        if (isLastPage) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
  });
}
