import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class ReportScamCard extends StatefulWidget {
  final Function({
    required String scamType,
    required String scammerContact,
    required String description,
  }) onGenerateReport;

  const ReportScamCard({
    super.key,
    required this.onGenerateReport,
  });

  @override
  State<ReportScamCard> createState() => _ReportScamCardState();
}

class _ReportScamCardState extends State<ReportScamCard> {
  final _scammerContactController = TextEditingController(
    text: '+1 (800) 492-9182 / https://secure-chase-update.com',
  );
  final _descriptionController = TextEditingController(
    text: 'Received fraudulent SMS followed by impersonation call demanding immediate OTP code confirmation.',
  );

  final List<String> _categories = [
    'Banking Wire Fraud',
    'Phishing Link / KYC',
    'Impersonation Call',
    'Extortion & Blackmail',
    'OTP & 2FA Theft',
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];
  }

  @override
  void dispose() {
    _scammerContactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CyberColors.riskCriticalBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: CyberColors.riskCritical,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'REPORT SCAM & GENERATE REPORT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: CyberColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Select Scam Category:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // Horizontal Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CyberColors.primarySoftBg
                            : CyberColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? CyberColors.primaryBlue
                              : CyberColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? CyberColors.primaryBlue : CyberColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Scammer Contact details input
          Text(
            'Scammer Handle / Phone / Domain:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _scammerContactController,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. +1-800-XXX-XXXX or deceptive URL',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: CyberColors.textSecondary.withOpacity(0.6)),
              filled: true,
              fillColor: CyberColors.surfaceSecondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.primaryBlue),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description field
          Text(
            'Incident Narrative / Details:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CyberColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Describe sequence of events (demands, fraudulent transfers, etc.)',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: CyberColors.textSecondary.withOpacity(0.6)),
              filled: true,
              fillColor: CyberColors.surfaceSecondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.primaryBlue),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dispatch Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onGenerateReport(
                  scamType: _selectedCategory,
                  scammerContact: _scammerContactController.text.trim(),
                  description: _descriptionController.text.trim(),
                );
              },
              icon: const Icon(Icons.security_update_warning_rounded, size: 18),
              label: Text(
                'Generate Incident Report & Log',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
