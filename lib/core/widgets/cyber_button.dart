import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_colors.dart';
import 'cyber_pressable.dart';

enum CyberButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final CyberButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;

  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = CyberButtonVariant.primary,
    this.height = 52.0,
    this.width,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Decoration decoration;
    Color textColor = Colors.white;

    switch (variant) {
      case CyberButtonVariant.primary:
        decoration = BoxDecoration(
          color: disabled ? const Color(0xFFCBD5E1) : CyberColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: disabled
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x1F2563EB),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        );
        textColor = Colors.white;
        break;

      case CyberButtonVariant.secondary:
        decoration = BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: const Color(0xFFBFDBFE),
            width: 1.2,
          ),
        );
        textColor = const Color(0xFF1D4ED8);
        break;

      case CyberButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: CyberColors.cardBorder,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        );
        textColor = CyberColors.textPrimary;
        break;

      case CyberButtonVariant.danger:
        decoration = BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: const Color(0xFFFECACA),
            width: 1.2,
          ),
        );
        textColor = CyberColors.danger;
        break;
    }

    final buttonWidget = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: decoration,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );

    return CyberPressable(
      onTap: disabled ? null : onPressed,
      semanticLabel: text,
      child: buttonWidget,
    );
  }
}
