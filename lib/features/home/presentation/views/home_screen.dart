import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CyberColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberColors.cardBorder, width: 1),
        ),
        title: Text(
          'TERMINATE SESSION?',
          style: GoogleFonts.rajdhani(
            color: CyberColors.riskCritical,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Disconnecting will deactivate foreground AI defense telemetry until re-authentication.',
          style: GoogleFonts.inter(
            color: CyberColors.textMuted,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.rajdhani(
                color: CyberColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.riskCritical,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'LOGOUT',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final auth = context.read<AuthController>();
      await auth.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    final displayName = user?.displayName ?? 'Cyber Operative';
    final email = user?.email ?? 'operative@cyberguard.xai';
    final score = user?.securityScore ?? 85;
    final shieldActive = user?.shieldActive ?? true;

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: CyberColors.cardBg.withOpacity(0.5),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CyberColors.neonCyan.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.shield,
                color: CyberColors.neonCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CYBERGUARD XAI',
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Terminate Session / Logout',
            icon: const Icon(
              Icons.logout_rounded,
              color: CyberColors.riskCritical,
            ),
            onPressed: () => _handleLogout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Status Card
              GlassmorphicContainer(
                borderRadius: 18,
                padding: const EdgeInsets.all(20),
                backgroundColor: CyberColors.cardBg.withOpacity(0.75),
                border: Border.all(
                  color: CyberColors.neonCyan.withOpacity(0.4),
                  width: 1.2,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: CyberColors.cardBorder,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                              style: GoogleFonts.rajdhani(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: CyberColors.neonCyan,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: CyberColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (shieldActive ? CyberColors.riskSafe : CyberColors.riskCritical)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: shieldActive ? CyberColors.riskSafe : CyberColors.riskCritical,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  shieldActive ? 'SHIELD ON' : 'DISABLED',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: shieldActive ? CyberColors.riskSafe : CyberColors.riskCritical,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CyberColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                size: 14,
                                color: CyberColors.neonCyan,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'UID: ${user?.uid.substring(0, 10) ?? "GUEST"}...',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: CyberColors.textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Threat Defense Matrix
              Text(
                'NEURAL DEFENSE SCORE',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: CyberColors.neonCyan,
                ),
              ),
              const SizedBox(height: 10),

              GlassmorphicContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(18),
                backgroundColor: CyberColors.cardBg.withOpacity(0.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$score / 100',
                          style: GoogleFonts.rajdhani(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: score >= 80
                                ? CyberColors.riskSafe
                                : (score >= 50
                                    ? CyberColors.riskWarning
                                    : CyberColors.riskCritical),
                          ),
                        ),
                        Text(
                          score >= 80
                              ? 'OPTIMAL PROTECTION POSTURE'
                              : 'VULNERABILITIES DETECTED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                            color: CyberColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      score >= 80 ? Icons.security : Icons.warning_amber_rounded,
                      size: 48,
                      color: score >= 80 ? CyberColors.riskSafe : CyberColors.riskWarning,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Subsystem Status Grid
              Text(
                'ACTIVE SURVEILLANCE MODULES',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildModuleCard(
                icon: Icons.link,
                title: 'URL & Phishing Inspector',
                status: 'MONITORING',
                color: CyberColors.neonCyan,
              ),
              const SizedBox(height: 10),
              _buildModuleCard(
                icon: Icons.face_retouching_natural,
                title: 'Deepfake Media Radar',
                status: 'READY (PROTOTYPE)',
                color: CyberColors.neonPink,
              ),
              const SizedBox(height: 10),
              _buildModuleCard(
                icon: Icons.hub,
                title: 'Threat DNA Correlation Engine',
                status: 'CONNECTED',
                color: CyberColors.cyberPurple,
              ),
              const SizedBox(height: 10),
              _buildModuleCard(
                icon: Icons.notifications_active_outlined,
                title: 'FCM Security Dispatcher',
                status: 'LISTENING',
                color: CyberColors.riskSafe,
              ),

              const SizedBox(height: 32),

              // Disconnect Action
              CyberButton(
                text: 'LOGOUT SESSION',
                icon: Icons.power_settings_new,
                variant: CyberButtonVariant.danger,
                onPressed: () => _handleLogout(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CyberColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberColors.cardBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CyberColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.rajdhani(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
