import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  String _savedEmail = '';
  String _savedPassword = '';
  bool _isOnboardingCompleted = false;
  bool _isInitialized = false;

  // Phone OTP States
  String? _verificationId;
  int? _resendToken;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;
  String _activePhoneNumber = '';

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl();

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading || _isSendingOtp || _isVerifyingOtp;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isInitialized => _isInitialized;

  // Phone OTP Getters
  bool get otpSent => _otpSent;
  bool get isSendingOtp => _isSendingOtp;
  bool get isVerifyingOtp => _isVerifyingOtp;
  int get resendCountdown => _resendCountdown;
  bool get canResend => _resendCountdown <= 0 && !_isSendingOtp && !_isVerifyingOtp;
  String get activePhoneNumber => _activePhoneNumber;

  /// Initialize application authentication state & stored credentials
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check Onboarding status
      _isOnboardingCompleted = await _authRepository.isOnboardingCompleted();

      // 2. Load stored credentials (Remember Me)
      final credentials = await _authRepository.getSavedCredentials();
      _rememberMe = credentials['rememberMe'] as bool? ?? false;
      if (_rememberMe) {
        _savedEmail = credentials['email'] as String? ?? '';
        _savedPassword = credentials['password'] as String? ?? '';
      }

      // 3. Check existing Firebase session and load profile
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Toggle Remember Me selection
  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Mark onboarding flow completed
  Future<void> completeOnboarding() async {
    await _authRepository.setOnboardingCompleted();
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  /// Authenticate with email & password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
        rememberMe: _rememberMe,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Register new operative account
  Future<bool> register(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Sign In with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Dispatch password recovery email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Terminate active operative session
  Future<void> logout() async {
    _setLoading(true);
    _cancelResendTimer();
    _resetOtpState();
    try {
      await _authRepository.logout();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  /// Dispatch real OTP to phone number
  Future<bool> sendPhoneOtp(String rawPhone) async {
    _isSendingOtp = true;
    _clearError();
    notifyListeners();

    final completer = Completer<bool>();

    try {
      final normalized = AuthService.normalizePhoneNumber(rawPhone);
      _activePhoneNumber = normalized;

      await _authRepository.sendPhoneOtp(
        phoneNumber: normalized,
        forceResendingToken: _resendToken,
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _otpSent = true;
          _isSendingOtp = false;
          _clearError();
          _startResendCountdown(60);
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (error) {
          _isSendingOtp = false;
          _setError(error);
          notifyListeners();
          if (!completer.isCompleted) completer.complete(false);
        },
        onAutoVerified: (user) {
          _currentUser = user;
          _isOnboardingCompleted = true;
          _isSendingOtp = false;
          _otpSent = false;
          _cancelResendTimer();
          _clearError();
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (e) {
      _isSendingOtp = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  /// Resend OTP with cooldown guard
  Future<bool> resendPhoneOtp() async {
    if (!canResend) {
      _setError('Please wait for the cooldown timer before requesting another OTP.');
      return false;
    }
    if (_activePhoneNumber.isEmpty) {
      _setError('Phone number unavailable. Please re-enter your phone number.');
      return false;
    }
    return sendPhoneOtp(_activePhoneNumber);
  }

  /// Verify real OTP code with backend
  Future<bool> verifyPhoneOtp(String smsCode) async {
    final cleanCode = smsCode.trim();
    if (cleanCode.length < 6) {
      _setError('Please enter the full 6-digit verification code.');
      return false;
    }

    if (_verificationId == null) {
      _setError('Verification session missing. Please request a new OTP code.');
      return false;
    }

    _isVerifyingOtp = true;
    _clearError();
    notifyListeners();

    try {
      final user = await _authRepository.verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: cleanCode,
        phoneNumber: _activePhoneNumber,
      );

      _currentUser = user;
      _isOnboardingCompleted = true;
      _isVerifyingOtp = false;
      _otpSent = false;
      _cancelResendTimer();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _isVerifyingOtp = false;
      _setError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  /// Reset OTP state so operative can enter a different phone number
  void resetOtpFlow() {
    _resetOtpState();
    _clearError();
    notifyListeners();
  }

  void _resetOtpState() {
    _otpSent = false;
    _verificationId = null;
    _resendToken = null;
    _isSendingOtp = false;
    _isVerifyingOtp = false;
    _activePhoneNumber = '';
    _cancelResendTimer();
  }

  void _startResendCountdown(int seconds) {
    _cancelResendTimer();
    _resendCountdown = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        _resendCountdown--;
        notifyListeners();
      } else {
        _resendCountdown = 0;
        timer.cancel();
        _resendTimer = null;
        notifyListeners();
      }
    });
  }

  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _resendCountdown = 0;
  }

  @override
  void dispose() {
    _cancelResendTimer();
    super.dispose();
  }

  /// Instant Guest / Demo Mode Authentication
  void signInWithDemoMode() {
    _currentUser = UserEntity(
      uid: 'DEMO_AGENT_007',
      email: 'agent@cyberguard.ai',
      displayName: 'Lead Cyber Officer',
      securityScore: 92,
      shieldActive: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    _isOnboardingCompleted = true;
    _clearError();
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
