import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailDispatched = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.sendPasswordReset(_emailController.text);

    if (success && mounted) {
      setState(() => _emailDispatched = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: CyberColors.neonCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CREDENTIAL RECOVERY',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: CyberColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<AuthController>(
          builder: (context, auth, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: _emailDispatched
                  ? _buildSuccessView(context)
                  : _buildRequestForm(context, auth),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, AuthController auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CyberColors.cardBg,
                border: Border.all(
                  color: CyberColors.neonPink.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CyberColors.neonPink.withOpacity(0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 42,
                color: CyberColors.neonPink,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'KEY RESET PROTOCOL',
            style: GoogleFonts.rajdhani(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Specify your registered operative address. A cryptographic one-time authentication link will be transmitted to recover terminal access.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: CyberColors.textMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Error Banner if present
          if (auth.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CyberColors.riskCritical.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CyberColors.riskCritical.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: CyberColors.riskCritical,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      auth.errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: CyberColors.riskCritical,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: CyberColors.riskCritical,
                    onPressed: auth.clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Email Field
          CyberTextField(
            controller: _emailController,
            label: 'OPERATIVE EMAIL ENDPOINT',
            hintText: 'agent@cyberguard.xai',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handlePasswordReset(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Registered operative email is required.';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value.trim())) {
                return 'Enter a valid email structure.';
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // Reset Action Button
          CyberButton(
            text: 'DISPATCH RESET LINK',
            icon: Icons.send_rounded,
            isLoading: auth.isLoading,
            onPressed: _handlePasswordReset,
          ),

          const SizedBox(height: 20),

          // Back to Login Button
          CyberButton(
            text: 'ABORT RECOVERY / BACK',
            variant: CyberButtonVariant.outline,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),

        GlassmorphicContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(28.0),
          backgroundColor: CyberColors.cardBg.withOpacity(0.85),
          border: Border.all(
            color: CyberColors.riskSafe.withOpacity(0.6),
            width: 1.5,
          ),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberColors.riskSafe.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: CyberColors.riskSafe,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'DISPATCH CONFIRMED',
                style: GoogleFonts.rajdhani(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: CyberColors.riskSafe,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A secure reset link has been dispatched to:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: CyberColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _emailController.text,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.neonCyan,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Follow the link in your email to re-establish your cryptographic credentials. Check your spam quarantine if unreceived within 3 minutes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: CyberColors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        CyberButton(
          text: 'PROCEED TO LOGIN',
          icon: Icons.login,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
