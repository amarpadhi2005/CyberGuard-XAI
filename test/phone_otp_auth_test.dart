import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cyberguard_xai/features/auth/data/services/auth_service.dart';
import 'package:cyberguard_xai/features/auth/domain/entities/user_entity.dart';
import 'package:cyberguard_xai/features/auth/domain/repositories/auth_repository.dart';
import 'package:cyberguard_xai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cyberguard_xai/features/auth/presentation/views/login_screen.dart';

class MockPhoneAuthRepository implements AuthRepository {
  bool shouldFailSend = false;
  bool shouldFailVerify = false;
  String? lastPhoneNumberSent;
  String? lastCodeVerified;
  int sendCallCount = 0;

  @override
  Stream<UserEntity?> get authStateChanges => const Stream.empty();

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> getSavedCredentials() async {
    return {'rememberMe': false, 'email': '', 'password': ''};
  }

  @override
  Future<void> setRememberMe({
    required bool rememberMe,
    String? email,
    String? password,
  }) async {}

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<void> setOnboardingCompleted() async {}

  @override
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    void Function(UserEntity user)? onAutoVerified,
    int? forceResendingToken,
  }) async {
    sendCallCount++;
    lastPhoneNumberSent = phoneNumber;
    if (shouldFailSend) {
      onError('Unable to dispatch OTP. Test simulated failure.');
    } else {
      onCodeSent('test_verification_id_999', 12345);
    }
  }

  @override
  Future<UserEntity> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    lastCodeVerified = smsCode;
    if (shouldFailVerify || smsCode != '654321') {
      throw Exception('Invalid verification code. Please check the 6-digit OTP in your SMS.');
    }

    return UserEntity(
      uid: 'PHONE-TEST-UID',
      email: '$phoneNumber@sms.cyberguard.ai',
      displayName: 'Verified Operative',
      photoUrl: null,
      securityScore: 92,
      shieldActive: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Part 1: Phone E.164 Normalization & Validation Tests', () {
    test('Normalizes 10-digit Indian phone number to E.164 format with +91', () {
      expect(AuthService.normalizePhoneNumber('9876543210'), equals('+919876543210'));
      expect(AuthService.normalizePhoneNumber(' 98765 43210 '), equals('+919876543210'));
      expect(AuthService.normalizePhoneNumber('(987) 654-3210'), equals('+919876543210'));
    });

    test('Preserves already prefixed international numbers', () {
      expect(AuthService.normalizePhoneNumber('+919876543210'), equals('+919876543210'));
      expect(AuthService.normalizePhoneNumber('+15550192834'), equals('+15550192834'));
      expect(AuthService.normalizePhoneNumber('+44 7911 123456'), equals('+447911123456'));
    });

    test('Rejects invalid or incomplete phone numbers', () {
      expect(() => AuthService.normalizePhoneNumber(''), throwsException);
      expect(() => AuthService.normalizePhoneNumber('123'), throwsException);
      expect(() => AuthService.normalizePhoneNumber('abc'), throwsException);
    });
  });

  group('Part 1: AuthController Real Phone OTP State Flow Tests', () {
    late MockPhoneAuthRepository mockRepo;
    late AuthController controller;

    setUp(() {
      mockRepo = MockPhoneAuthRepository();
      controller = AuthController(authRepository: mockRepo);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial Phone OTP state is clean and ready', () {
      expect(controller.otpSent, isFalse);
      expect(controller.isSendingOtp, isFalse);
      expect(controller.isVerifyingOtp, isFalse);
      expect(controller.resendCountdown, equals(0));
      expect(controller.canResend, isTrue);
      expect(controller.activePhoneNumber, isEmpty);
    });

    test('sendPhoneOtp successfully transitions to otpSent and starts countdown', () async {
      final success = await controller.sendPhoneOtp('9876543210');

      expect(success, isTrue);
      expect(controller.otpSent, isTrue);
      expect(controller.isSendingOtp, isFalse);
      expect(controller.activePhoneNumber, equals('+919876543210'));
      expect(mockRepo.lastPhoneNumberSent, equals('+919876543210'));
      expect(controller.resendCountdown, equals(60));
      expect(controller.canResend, isFalse);
    });

    test('sendPhoneOtp handles failure without faking success', () async {
      mockRepo.shouldFailSend = true;
      final success = await controller.sendPhoneOtp('9876543210');

      expect(success, isFalse);
      expect(controller.otpSent, isFalse);
      expect(controller.isSendingOtp, isFalse);
      expect(controller.errorMessage, contains('Unable to dispatch OTP'));
    });

    test('verifyPhoneOtp fails with invalid code and protects session', () async {
      await controller.sendPhoneOtp('9876543210');

      final success = await controller.verifyPhoneOtp('000000'); // incorrect code
      expect(success, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, contains('Invalid verification code'));
    });

    test('verifyPhoneOtp succeeds with valid code and establishes session', () async {
      await controller.sendPhoneOtp('9876543210');

      final success = await controller.verifyPhoneOtp('654321');
      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.uid, equals('PHONE-TEST-UID'));
      expect(controller.errorMessage, isNull);
    });

    test('resetOtpFlow resets state and allows changing number', () async {
      await controller.sendPhoneOtp('9876543210');
      expect(controller.otpSent, isTrue);

      controller.resetOtpFlow();
      expect(controller.otpSent, isFalse);
      expect(controller.activePhoneNumber, isEmpty);
      expect(controller.resendCountdown, equals(0));
    });
  });

  group('Part 1: LoginScreen Phone Tab UI Integration Tests', () {
    testWidgets('Renders Phone OTP tab with send button and switches to verification form',
        (tester) async {
      final mockRepo = MockPhoneAuthRepository();
      final authController = AuthController(authRepository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthController>.value(
            value: authController,
            child: const LoginScreen(),
          ),
        ),
      );

      // Verify phone number field and Send Verification Code button exist
      expect(find.text('Mobile Phone Number'), findsOneWidget);
      expect(find.text('Send Verification Code'), findsOneWidget);
      expect(find.text('Verify & Enter'), findsNothing);

      // Enter phone number
      await tester.enterText(find.byType(TextFormField).first, '9876543210');
      await tester.pumpAndSettle();

      // Tap Send Verification Code
      await tester.tap(find.text('Send Verification Code'));
      await tester.pumpAndSettle();

      // Verify UI has transitioned to OTP entry state
      expect(find.text('6-Digit Verification Code'), findsOneWidget);
      expect(find.text('Verify & Enter'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.textContaining('OTP sent to +919876543210'), findsOneWidget);

      authController.dispose();
    });
  });
}
