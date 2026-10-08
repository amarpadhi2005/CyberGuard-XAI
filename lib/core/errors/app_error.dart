import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppErrorType {
  rendering,
  network,
  api,
  ai,
  permission,
  validation,
  security,
  unknown,
}

class AppErrorInfo {
  final AppErrorType type;
  final String title;
  final String userMessage;
  final String? technicalDetails;
  final IconData icon;
  final Color primaryColor;
  final bool isSecurityThreat;

  const AppErrorInfo({
    required this.type,
    required this.title,
    required this.userMessage,
    this.technicalDetails,
    required this.icon,
    required this.primaryColor,
    this.isSecurityThreat = false,
  });

  /// Factory mapping an unknown exception or FlutterErrorDetails to an AppErrorInfo
  factory AppErrorInfo.fromException(dynamic error, [StackTrace? stackTrace]) {
    final errorString = error?.toString() ?? 'Unknown error';

    // 1. Flutter UI Rendering / Assertion Error
    if (error is FlutterErrorDetails ||
        errorString.contains('Failed assertion') ||
        errorString.contains('render') ||
        errorString.contains('RenderBox') ||
        errorString.contains('A borderRadius can only be given')) {
      return AppErrorInfo(
        type: AppErrorType.rendering,
        title: kDebugMode ? 'UI RENDERING ERROR' : 'Something went wrong',
        userMessage: kDebugMode
            ? 'A Flutter interface component failed to render.'
            : 'The interface could not be displayed correctly. Please try again.',
        technicalDetails: errorString,
        icon: Icons.dashboard_customize_outlined,
        primaryColor: const Color(0xFF64748B), // Neutral Slate
        isSecurityThreat: false,
      );
    }

    // 2. Network Exceptions
    if (error is SocketException ||
        errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup') ||
        errorString.contains('Connection refused') ||
        errorString.contains('NetworkImageLoadException')) {
      return AppErrorInfo(
        type: AppErrorType.network,
        title: 'Network Connection Error',
        userMessage: 'Unable to reach servers. Please check your internet connection.',
        technicalDetails: errorString,
        icon: Icons.wifi_off_rounded,
        primaryColor: const Color(0xFF0284C7), // Blue
        isSecurityThreat: false,
      );
    }

    // 3. Permission Exceptions
    if (errorString.contains('permission') ||
        errorString.contains('PermissionDenied') ||
        errorString.contains('CAMERA') ||
        errorString.contains('denied')) {
      return AppErrorInfo(
        type: AppErrorType.permission,
        title: 'Permission Required',
        userMessage: 'This operation requires permission to access hardware features.',
        technicalDetails: errorString,
        icon: Icons.lock_outline_rounded,
        primaryColor: const Color(0xFFF59E0B), // Orange/Amber
        isSecurityThreat: false,
      );
    }

    // 4. Gemini / AI Exceptions
    if (errorString.contains('Gemini') ||
        errorString.contains('generativelanguage') ||
        errorString.contains('quota') ||
        errorString.contains('RESOURCE_EXHAUSTED')) {
      return AppErrorInfo(
        type: AppErrorType.ai,
        title: 'AI Service Notice',
        userMessage: 'AI analysis could not complete. Relying on local rule-based security evaluation.',
        technicalDetails: errorString,
        icon: Icons.smart_toy_outlined,
        primaryColor: const Color(0xFF8B5CF6), // Purple
        isSecurityThreat: false,
      );
    }

    // 5. Backend / API Exceptions
    if (errorString.contains('HttpException') ||
        errorString.contains('status code: 5') ||
        errorString.contains('status code: 4')) {
      return AppErrorInfo(
        type: AppErrorType.api,
        title: 'Service Notice',
        userMessage: 'Security service unavailable. Local security tools remain operational.',
        technicalDetails: errorString,
        icon: Icons.cloud_off_rounded,
        primaryColor: const Color(0xFF6366F1), // Indigo
        isSecurityThreat: false,
      );
    }

    // 6. Security Threats (Only when explicitly raised by security tools)
    if (errorString.contains('SECURITY_THREAT_CONFIRMED') ||
        errorString.contains('CRITICAL_SECURITY_EVENT')) {
      return AppErrorInfo(
        type: AppErrorType.security,
        title: 'SECURITY ALERT',
        userMessage: 'Security check flagged active threat indicators.',
        technicalDetails: errorString,
        icon: Icons.gpp_bad_rounded,
        primaryColor: const Color(0xFFEF4444), // Red
        isSecurityThreat: true,
      );
    }

    // Default Unknown Application Error
    return AppErrorInfo(
      type: AppErrorType.unknown,
      title: kDebugMode ? 'APPLICATION ERROR' : 'Something went wrong',
      userMessage: kDebugMode
          ? 'An unhandled exception occurred in the application.'
          : 'An unexpected application state occurred. Please try again.',
      technicalDetails: errorString,
      icon: Icons.error_outline_rounded,
      primaryColor: const Color(0xFF64748B), // Neutral
      isSecurityThreat: false,
    );
  }
}
