import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cyberguard_xai/core/errors/app_error.dart';
import 'package:cyberguard_xai/core/widgets/cyber_error_boundary.dart';
import 'package:cyberguard_xai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cyberguard_xai/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cyberguard_xai/features/dashboard/presentation/views/tabs/account_tab_view.dart';

void main() {
  group('Task 18 — Material Shape & BorderRadius Assertion Regression Tests', () {
    testWidgets('AccountTabView renders successfully without Material shape/borderRadius conflict',
        (WidgetTester tester) async {
      // Build AccountTabView inside Provider scope
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>(
              create: (_) => AuthController(),
            ),
            ChangeNotifierProvider<DashboardController>(
              create: (_) => DashboardController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AccountTabView(),
            ),
          ),
        ),
      );

      // Allow widget tree to settle
      await tester.pumpAndSettle();

      // Verify that no assertion was thrown and the Account screen rendered
      expect(find.byType(AccountTabView), findsOneWidget);
      expect(find.text('Preferences & Security'), findsOneWidget);
      expect(find.text('Push Threat Notifications'), findsOneWidget);

      // Verify that the Material widget rendered without assertion
      expect(find.byType(Material), findsWidgets);
    });
  });

  group('Task 4 & 5 — Error Boundary Decoupling Tests', () {
    testWidgets('CyberErrorBoundary renders clean UI error and NEVER displays "PERIMETER ISOLATION ACTIVE"',
        (WidgetTester tester) async {
      const simulatedException =
          "'package:flutter/src/material/material.dart': Failed assertion: line 209 pos 15: '!(shape != null && borderRadius != null)'";

      await tester.pumpWidget(
        MaterialApp(
          home: CyberErrorBoundary(
            errorDetails: simulatedException,
            onRetry: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Must NOT display fake perimeter isolation or military/threat messaging
      expect(find.text('PERIMETER ISOLATION ACTIVE'), findsNothing);
      expect(find.textContaining('runtime shields'), findsNothing);
      expect(find.textContaining('perimeter breach'), findsNothing);
      expect(find.textContaining('RESTORE DEFENSE BASELINE'), findsNothing);

      // 2. Must display clean application error title
      expect(
        find.text('UI RENDERING ERROR'),
        findsOneWidget,
      );

      // 3. Must display action buttons: [ RETRY ] and [ REPORT ERROR ]
      expect(find.text('RETRY'), findsOneWidget);
      expect(find.text('REPORT ERROR'), findsOneWidget);
    });

    test('AppErrorInfo categorizes error types accurately', () {
      // Rendering Error
      final renderError = AppErrorInfo.fromException('Failed assertion: !(shape != null && borderRadius != null)');
      expect(renderError.type, equals(AppErrorType.rendering));
      expect(renderError.isSecurityThreat, isFalse);

      // Network Error
      final netError = AppErrorInfo.fromException('SocketException: Failed host lookup');
      expect(netError.type, equals(AppErrorType.network));
      expect(netError.isSecurityThreat, isFalse);

      // Permission Error
      final permError = AppErrorInfo.fromException('PermissionDeniedException: CAMERA');
      expect(permError.type, equals(AppErrorType.permission));
      expect(permError.isSecurityThreat, isFalse);

      // AI Error
      final aiError = AppErrorInfo.fromException('Gemini API quota exhausted');
      expect(aiError.type, equals(AppErrorType.ai));
      expect(aiError.isSecurityThreat, isFalse);

      // Security Threat (Only when explicitly confirmed)
      final secThreat = AppErrorInfo.fromException('CRITICAL_SECURITY_EVENT: Phishing confirmed');
      expect(secThreat.type, equals(AppErrorType.security));
      expect(secThreat.isSecurityThreat, isTrue);
    });
  });
}
