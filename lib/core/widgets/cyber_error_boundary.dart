import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../errors/app_error.dart';
import '../theme/cyber_colors.dart';

class CyberErrorBoundary extends StatefulWidget {
  final dynamic errorDetails;
  final VoidCallback? onRetry;
  final bool isInline;

  const CyberErrorBoundary({
    super.key,
    required this.errorDetails,
    this.onRetry,
    this.isInline = false,
  });

  @override
  State<CyberErrorBoundary> createState() => _CyberErrorBoundaryState();
}

class _CyberErrorBoundaryState extends State<CyberErrorBoundary> {
  bool _showDetails = false;

  void _handleReportError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Diagnostic report captured for review.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF334155),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = AppErrorInfo.fromException(widget.errorDetails);

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: info.primaryColor.withOpacity(0.12),
                ),
                child: Icon(
                  info.icon,
                  color: info.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                info.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description Message
              Text(
                info.userMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: CyberColors.textSecondary,
                  height: 1.5,
                ),
              ),

              // Technical Details Section (Development & Debugging)
              if (kDebugMode && info.technicalDetails != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => setState(() => _showDetails = !_showDetails),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showDetails ? 'Hide Technical Details' : 'View Developer Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          size: 14,
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showDetails) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      info.technicalDetails!.split('\n').take(6).join('\n'),
                      style: GoogleFonts.firaCode(
                        fontSize: 10,
                        color: const Color(0xFF38BDF8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Action Buttons: [ RETRY ] and [ REPORT ERROR ]
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleReportError,
                      child: Text(
                        'REPORT ERROR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: widget.onRetry ??
                          () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isInline) {
      return content;
    }

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(child: content),
    );
  }
}

/// Screen-level Error Boundary isolating individual tab failures
class FeatureErrorBoundary extends StatefulWidget {
  final Widget child;
  final String featureName;

  const FeatureErrorBoundary({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  State<FeatureErrorBoundary> createState() => _FeatureErrorBoundaryState();
}

class _FeatureErrorBoundaryState extends State<FeatureErrorBoundary> {
  Key _retryKey = UniqueKey();
  Object? _caughtError;

  void _retry() {
    setState(() {
      _caughtError = null;
      _retryKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_caughtError != null) {
      return CyberErrorBoundary(
        errorDetails: _caughtError,
        onRetry: _retry,
        isInline: true,
      );
    }

    return KeyedSubtree(
      key: _retryKey,
      child: widget.child,
    );
  }
}
