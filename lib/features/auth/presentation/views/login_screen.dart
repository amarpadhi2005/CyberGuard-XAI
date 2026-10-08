import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.rememberMe) {
        setState(() {
          _rememberMe = true;
          _emailController.text = auth.savedEmail;
          _passwordController.text = auth.savedPassword;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onLoginSuccess() {
    Navigator.pushReplacementNamed(context, '/permissions');
  }

  Future<void> _handleEmailLogin() async {
    if (!_emailFormKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    auth.toggleRememberMe(_rememberMe);

    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _onLoginSuccess();
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (e.g. +91 98765 43210)'),
        ),
      );
      return;
    }
    final auth = context.read<AuthController>();
    final success = await auth.sendPhoneOtp(phone);
    if (!mounted) return;
    if (success) {
      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Security OTP code dispatched to ${auth.activePhoneNumber}'),
          backgroundColor: CyberColors.primaryDark,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Unable to dispatch OTP. Please check phone number or network.'),
          backgroundColor: CyberColors.danger,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit OTP code')),
      );
      return;
    }
    final auth = context.read<AuthController>();
    final success = await auth.verifyPhoneOtp(code);
    if (!mounted) return;
    if (success) {
      _onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Verification failed. Please check the code and try again.'),
          backgroundColor: CyberColors.danger,
        ),
      );
    }
  }

  Future<void> _handleResendOtp() async {
    final auth = context.read<AuthController>();
    final success = await auth.resendPhoneOtp();
    if (!mounted) return;
    if (success) {
      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New verification code dispatched to ${auth.activePhoneNumber}'),
          backgroundColor: CyberColors.primaryDark,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Unable to resend OTP.'),
          backgroundColor: CyberColors.danger,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      _onLoginSuccess();
    }
  }

  void _handleDemoSignIn() {
    final auth = context.read<AuthController>();
    auth.signInWithDemoMode();
    _onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Large CyberGuard Shield Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: CyberColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: CyberColors.primary.withOpacity(0.32),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Welcome Heading & Brand
                Text(
                  'CyberGuard XAI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: CyberColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Protect your digital life with AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CyberColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                // Error Banner if present
                if (auth.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: CyberColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: auth.clearError,
                          child: const Icon(
                            Icons.close_rounded,
                            color: CyberColors.danger,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Main Authentication Card
                GlassmorphicContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(22),
                  backgroundColor: Colors.white,
                  border: Border.all(
                    color: CyberColors.cardBorder,
                    width: 1.2,
                  ),
                  boxShadow: CyberColors.cardShadow,
                  child: Column(
                    children: [
                      // Modern Pill Tab Bar
                      Container(
                        height: 46,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F0F172A),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: CyberColors.primaryDark,
                          unselectedLabelColor: CyberColors.textSecondary,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Phone (OTP)'),
                            Tab(text: 'Email & Password'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Tab View contents
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // TAB 1: PHONE OTP AUTHENTICATION
                            Form(
                              key: _phoneFormKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (auth.otpSent) ...[
                                    // Dispatched notification banner with change button
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.mark_email_read_outlined,
                                            size: 18,
                                            color: CyberColors.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'OTP sent to ${auth.activePhoneNumber}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: CyberColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              auth.resetOtpFlow();
                                              _otpController.clear();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                'Change',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: CyberColors.primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CyberTextField(
                                      controller: _otpController,
                                      label: '6-Digit Verification Code',
                                      hintText: '• • • • • •',
                                      prefixIcon: Icons.lock_clock_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 14),
                                    CyberButton(
                                      text: 'Verify & Enter',
                                      isLoading: auth.isVerifyingOtp,
                                      onPressed: _handleVerifyOtp,
                                      icon: Icons.check_circle_outline_rounded,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (auth.resendCountdown > 0) ...[
                                          const Icon(
                                            Icons.timer_outlined,
                                            size: 14,
                                            color: CyberColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Resend code in ${auth.resendCountdown}s',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: CyberColors.textSecondary,
                                            ),
                                          ),
                                        ] else ...[
                                          TextButton(
                                            onPressed: auth.canResend
                                                ? _handleResendOtp
                                                : null,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Resend Verification Code',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: CyberColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ] else ...[
                                    CyberTextField(
                                      controller: _phoneController,
                                      label: 'Mobile Phone Number',
                                      hintText: '+91 98765 43210',
                                      prefixIcon: Icons.phone_android_rounded,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Enter your phone number with country code. A real one-time passcode (OTP) will be dispatched to authenticate your device.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: CyberColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 18),
                                    CyberButton(
                                      text: 'Send Verification Code',
                                      isLoading: auth.isSendingOtp,
                                      onPressed: _handleSendOtp,
                                      icon: Icons.sms_outlined,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // TAB 2: EMAIL & PASSWORD AUTHENTICATION
                            Form(
                              key: _emailFormKey,
                              child: Column(
                                children: [
                                  CyberTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hintText: 'operative@cyberguard.xai',
                                    prefixIcon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  CyberTextField(
                                    controller: _passwordController,
                                    label: 'Security Key / Password',
                                    hintText: '••••••••••••',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    validator: (val) {
                                      if (val == null || val.length < 6) {
                                        return 'Minimum 6 characters required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: CyberColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  _rememberMe = val ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember Me',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: CyberColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/forgot-password');
                                        },
                                        child: Text(
                                          'Forgot key?',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: CyberColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  CyberButton(
                                    text: 'Secure Sign In',
                                    isLoading: auth.isLoading,
                                    onPressed: _handleEmailLogin,
                                    icon: Icons.fingerprint_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'OR SIGN IN WITH',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CyberColors.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Google Sign-In Button
                      InkWell(
                        onTap: auth.isLoading ? null : _handleGoogleSignIn,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
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
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: const Color(0xFF4285F4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CyberColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Instant Demo Access Button
                      InkWell(
                        onTap: _handleDemoSignIn,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: CyberColors.primaryDark,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Explore in Demo / Guest Mode',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: CyberColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an enterprise account? ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: CyberColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Enroll Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
