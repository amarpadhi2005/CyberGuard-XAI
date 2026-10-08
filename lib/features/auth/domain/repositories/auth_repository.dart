import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream to listen to real-time auth changes
  Stream<UserEntity?> get authStateChanges;

  /// Get current user profile
  Future<UserEntity?> getCurrentUser();

  /// Log in with email and password
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Register new operative account
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in using Google OAuth
  Future<UserEntity> signInWithGoogle();

  /// Request password recovery token
  Future<void> sendPasswordResetEmail(String email);

  /// Terminate active session
  Future<void> logout();

  /// Get cached credentials for Remember Me
  Future<Map<String, dynamic>> getSavedCredentials();

  /// Set Remember Me flag and credentials
  Future<void> setRememberMe({
    required bool rememberMe,
    String? email,
    String? password,
  });

  /// Check if onboarding walkthrough was completed
  Future<bool> isOnboardingCompleted();

  /// Mark onboarding walkthrough completed
  Future<void> setOnboardingCompleted();

  /// Dispatch real OTP to phone number using backend authentication
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(UserEntity user)? onAutoVerified,
    int? forceResendingToken,
  });

  /// Verify real OTP with backend authentication and establish session
  Future<UserEntity> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  });
}
