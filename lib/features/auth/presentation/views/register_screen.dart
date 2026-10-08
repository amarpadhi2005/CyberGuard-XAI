import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToProtocols = true;
  double _passwordStrength = 0.0;
  String _strengthLabel = 'TOO WEAK';
  Color _strengthColor = CyberColors.riskCritical;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_calculatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    double score = 0;

    if (password.length >= 8) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.25;

    setState(() {
      _passwordStrength = score;
      if (score <= 0.25) {
        _strengthLabel = 'VULNERABLE';
        _strengthColor = CyberColors.riskCritical;
      } else if (score <= 0.5) {
        _strengthLabel = 'MODERATE';
        _strengthColor = CyberColors.riskWarning;
      } else if (score <= 0.75) {
        _strengthLabel = 'STRONG DEFENSE';
        _strengthColor = CyberColors.neonCyan;
      } else {
        _strengthLabel = 'MAXIMUM ENTROPY';
        _strengthColor = CyberColors.riskSafe;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToProtocols) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Security Defense Protocols to proceed.'),
          backgroundColor: CyberColors.riskCritical,
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final success = await auth.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
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
          'NEW AGENT ENROLLMENT',
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREDENTIAL CREATION',
                      style: GoogleFonts.rajdhani(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Establish identity for decentralized AI surveillance & protection',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: CyberColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error Display Banner
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

                    // Full Name Field
                    CyberTextField(
                      controller: _nameController,
                      label: 'OPERATIVE DISPLAY NAME',
                      hintText: 'Agent Alex Vance',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Operative display name is required.';
                        }
                        if (value.trim().length < 2) {
                          return 'Identifier must contain at least 2 characters.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    CyberTextField(
                      controller: _emailController,
                      label: 'COMMUNICATION ENDPOINT / EMAIL',
                      hintText: 'operative@cyberguard.xai',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid email structure.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CyberTextField(
                      controller: _passwordController,
                      label: 'SECURITY KEY / PASSWORD',
                      hintText: '••••••••••••',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }
                        if (value.length < 8) {
                          return 'Minimum 8 characters required for secure encryption.';
                        }
                        return null;
                      },
                    ),

                    // Dynamic Password Strength Meter
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ENTROPY: $_strengthLabel',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: _strengthColor,
                            ),
                          ),
                          Text(
                            '${(_passwordStrength * 100).toInt()}%',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: CyberColors.cardBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                          minHeight: 4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CyberTextField(
                      controller: _confirmPasswordController,
                      label: 'CONFIRM SECURITY KEY',
                      hintText: '••••••••••••',
                      prefixIcon: Icons.lock_reset,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleRegister(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password is required.';
                        }
                        if (value != _passwordController.text) {
                          return 'Security keys do not match.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Protocol Agreement Checkbox
                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreeToProtocols,
                            onChanged: (val) {
                              setState(() => _agreeToProtocols = val ?? false);
                            },
                            activeColor: CyberColors.neonCyan,
                            checkColor: Colors.black,
                            side: const BorderSide(
                              color: CyberColors.cardBorder,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I consent to automated threat analysis and local behavioral telemetry.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CyberColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Register Button
                    CyberButton(
                      text: 'ENROLL OPERATIVE ACCOUNT',
                      icon: Icons.shield,
                      isLoading: auth.isLoading,
                      onPressed: _handleRegister,
                    ),

                    const SizedBox(height: 20),

                    // Google Sign Up Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: CyberColors.cardBorder, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            'OR ENROLL WITH',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: CyberColors.textDark,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: CyberColors.cardBorder, thickness: 1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google Register Button
                    GlassmorphicContainer(
                      height: 50,
                      borderRadius: 12,
                      padding: EdgeInsets.zero,
                      backgroundColor: CyberColors.cardBg.withOpacity(0.8),
                      border: Border.all(
                        color: CyberColors.cardBorder,
                        width: 1.0,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: auth.isLoading ? null : _handleGoogleSignIn,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'G',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: const Color(0xFF4285F4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'REGISTER VIA GOOGLE',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: CyberColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Back to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already an active operative? ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: CyberColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'SIGN IN',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: CyberColors.neonCyan,
                              decoration: TextDecoration.underline,
                              decorationColor: CyberColors.neonCyan,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
