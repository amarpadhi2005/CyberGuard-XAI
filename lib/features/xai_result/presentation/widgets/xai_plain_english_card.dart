import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/xai_result_model.dart';

class XaiPlainEnglishCard extends StatelessWidget {
  final XaiResultModel result;

  const XaiPlainEnglishCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CyberColors.cardBorder,
          width: 1.0,
        ),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.softBlueBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_alt_rounded,
                        color: CyberColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PLAIN-ENGLISH EXPLANATION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberColors.softBlueBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CyberColors.softBlueBorder, width: 1.0),
                ),
                child: Text(
                  'SIMPLE & CLEAR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 1. What is this?
          _buildInfoBlock(
            icon: Icons.lightbulb_outline_rounded,
            title: 'WHAT IS THIS?',
            content: result.plainEnglishSummary,
            accentColor: CyberColors.primary,
          ),

          const SizedBox(height: 12),

          // 2. How it works
          _buildInfoBlock(
            icon: Icons.alt_route_rounded,
            title: 'HOW DOES THIS TRICK PEOPLE?',
            content: result.howItWorks,
            accentColor: CyberColors.danger,
          ),

          const SizedBox(height: 12),

          // 3. Real-world Analogy
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CyberColors.softBlueBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CyberColors.softBlueBorder,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: CyberColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REAL-WORLD ANALOGY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: CyberColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.realWorldAnalogy,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: CyberColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({
    required IconData icon,
    required String title,
    required String content,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CyberColors.cardBgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.cardBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: CyberColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
