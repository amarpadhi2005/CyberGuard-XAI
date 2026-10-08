import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _authService.getUserProfile(firebaseUser.uid);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _authService.currentFirebaseUser;
      if (firebaseUser != null) {
        return await _authService.getUserProfile(firebaseUser.uid);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    return await _authService.loginWithEmailAndPassword(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<Map<String, dynamic>> getSavedCredentials() async {
    return await _authService.getSavedCredentials();
  }

  @override
  Future<void> setRememberMe({
    required bool rememberMe,
    String? email,
    String? password,
  }) async {
    await _authService.setRememberMe(
      rememberMe: rememberMe,
      email: email,
      password: password,
    );
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return await _authService.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _authService.setOnboardingCompleted();
  }

  @override
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(UserEntity user)? onAutoVerified,
    int? forceResendingToken,
  }) async {
    await _authService.sendPhoneOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
      forceResendingToken: forceResendingToken,
    );
  }

  @override
  Future<UserEntity> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    return await _authService.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      phoneNumber: phoneNumber,
    );
  }
}
