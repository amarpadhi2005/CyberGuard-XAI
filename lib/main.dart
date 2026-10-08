import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/theme/cyber_colors.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/views/splash_screen.dart';
import 'features/auth/presentation/views/onboarding_screen.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/auth/presentation/views/register_screen.dart';
import 'features/auth/presentation/views/forgot_password_screen.dart';
import 'features/auth/presentation/views/permissions_screen.dart';
import 'features/scanner/presentation/views/device_scan_screen.dart';
import 'features/scanner/presentation/views/risk_report_screen.dart';
import 'features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'features/dashboard/presentation/views/dashboard_view.dart';

import 'features/scanner/presentation/controllers/url_scanner_controller.dart';
import 'features/scanner/presentation/views/url_scanner_screen.dart';
import 'features/qr_scanner/presentation/controllers/qr_scanner_controller.dart';
import 'features/qr_scanner/presentation/views/qr_scanner_screen.dart';
import 'features/assistant/presentation/controllers/assistant_controller.dart';
import 'features/assistant/presentation/views/assistant_screen.dart';
import 'features/notifications/presentation/controllers/notification_protection_controller.dart';
import 'features/notifications/presentation/views/notification_protection_screen.dart';
import 'features/scam_call/presentation/controllers/scam_call_controller.dart';
import 'features/scam_call/presentation/views/scam_call_screen.dart';
import 'features/threat_history/presentation/controllers/threat_history_controller.dart';
import 'features/threat_history/presentation/views/threat_history_screen.dart';
import 'features/cyber_health/presentation/controllers/cyber_health_controller.dart';
import 'features/cyber_health/presentation/views/cyber_health_screen.dart';
import 'features/xai_result/presentation/views/xai_result_screen.dart';
import 'features/cyber_twin/presentation/controllers/cyber_twin_controller.dart';
import 'features/cyber_twin/presentation/views/cyber_twin_screen.dart';
import 'features/emergency_sos/presentation/controllers/emergency_sos_controller.dart';
import 'features/emergency_sos/presentation/views/emergency_sos_screen.dart';
import 'features/demo_mode/presentation/controllers/demo_mode_controller.dart';
import 'features/demo_mode/presentation/views/demo_mode_screen.dart';
import 'package:flutter/foundation.dart';
import 'core/theme/cyber_page_transitions.dart';
import 'core/widgets/cyber_error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Framework UI rendering errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('CyberGuard Framework Error: ${details.exceptionAsString()}');
  };

  // Catch unhandled asynchronous & platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('CyberGuard Unhandled Asynchronous/Platform Error: $error');
    return true; // handled
  };

  // Safe ErrorWidget builder separating UI rendering errors from security alerts
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CyberErrorBoundary(errorDetails: details);
  };

  // Initialize Firebase Core
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized with native config');
  } catch (e) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCyberGuardMockApiKeyForOffline123',
          appId: '1:1234567890:android:abcdef123456',
          messagingSenderId: '1234567890',
          projectId: 'cyberguard-xai',
          storageBucket: 'cyberguard-xai.appspot.com',
        ),
      );
      debugPrint('Firebase initialized successfully with fallback options');
    } catch (e2) {
      debugPrint('Firebase.initializeApp warning: $e2');
    }
  }

  // Initialize Supabase Client
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://pjwjlndchmoynweipzcl.supabase.co',
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqd2psbmRjaG1veW53ZWlwemNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA5MzIwNzAsImV4cCI6MjEwNjUwODA3MH0.LSOPWLPSyMcc5_rMneNQbK5aRChZCaAXdci-Hx65XKU',
      ),
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase.initialize warning: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (_) => DashboardController(),
        ),
        ChangeNotifierProvider<UrlScannerController>(
          create: (_) => UrlScannerController(),
        ),
        ChangeNotifierProvider<QrScannerController>(
          create: (_) => QrScannerController(),
        ),
        ChangeNotifierProvider<AssistantController>(
          create: (_) => AssistantController(),
        ),
        ChangeNotifierProvider<NotificationProtectionController>(
          create: (_) => NotificationProtectionController(),
        ),
        ChangeNotifierProvider<ScamCallController>(
          create: (_) => ScamCallController(),
        ),
        ChangeNotifierProvider<ThreatHistoryController>(
          create: (_) => ThreatHistoryController(),
        ),
        ChangeNotifierProvider<CyberHealthController>(
          create: (_) => CyberHealthController(),
        ),
        ChangeNotifierProvider<CyberTwinController>(
          create: (_) => CyberTwinController(),
        ),
        ChangeNotifierProvider<EmergencySosController>(
          create: (_) => EmergencySosController(),
        ),
        ChangeNotifierProvider<DemoModeController>(
          create: (_) => DemoModeController(),
        ),
      ],
      child: const CyberGuardApp(),
    ),
  );
}

class CyberGuardApp extends StatelessWidget {
  const CyberGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberGuard XAI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: CyberColors.background,
        primaryColor: CyberColors.primary,
        colorScheme: const ColorScheme.light(
          primary: CyberColors.primary,
          secondary: CyberColors.secondary,
          surface: Colors.white,
          error: CyberColors.danger,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: CyberColors.textPrimary,
          displayColor: CyberColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: CyberColors.textPrimary),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: CyberColors.textPrimary,
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CyberPageTransitionsBuilder(),
            TargetPlatform.iOS: CyberPageTransitionsBuilder(),
            TargetPlatform.windows: CyberPageTransitionsBuilder(),
            TargetPlatform.macOS: CyberPageTransitionsBuilder(),
            TargetPlatform.linux: CyberPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/device_scan': (context) => const DeviceScanScreen(),
        '/risk_report': (context) => const RiskReportScreen(),
        '/home': (context) => const DashboardView(),
        '/dashboard': (context) => const DashboardView(),
        '/url-scanner': (context) => const UrlScannerScreen(),
        '/qr-scanner': (context) => const QrScannerScreen(),
        '/assistant': (context) => const AssistantScreen(),
        '/notifications': (context) => const NotificationProtectionScreen(),
        '/scam-call': (context) => const ScamCallScreen(),
        '/threat-history': (context) => const ThreatHistoryScreen(),
        '/cyber-health': (context) => const CyberHealthScreen(),
        '/xai-result': (context) => const XaiResultScreen(),
        '/cyber-twin': (context) => const CyberTwinScreen(),
        '/emergency-sos': (context) => const EmergencySosScreen(),
        '/demo-mode': (context) => const DemoModeScreen(),
      },
    );
  }
}
