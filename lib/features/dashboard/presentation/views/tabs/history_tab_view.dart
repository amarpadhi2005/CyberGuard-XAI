import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/cyber_colors.dart';
import '../../../../threat_history/presentation/controllers/threat_history_controller.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';

class HistoryTabView extends StatefulWidget {
  const HistoryTabView({super.key});

  @override
  State<HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends State<HistoryTabView> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<ThreatHistoryController>().loadHistory(userId);
    });
  }

  void _showAuditEmailDialog(BuildContext context) {
    final senderCtrl = TextEditingController(text: 'urgent-billing@apple-support-verify.com');
    final subjectCtrl = TextEditingController(text: 'Immediate Account Suspension Warning #9921');
    final bodyCtrl = TextEditingController(
      text: 'Your cloud account was accessed from Russia. Click here immediately to verify credentials or your storage will be deleted in 2 hours.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mark_email_unread_rounded, color: CyberColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              'Audit Inbound Email',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sender Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: senderCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Subject Line',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: subjectCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Email Body',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final auth = context.read<AuthController>();
              final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
              await context.read<ThreatHistoryController>().analyzeEmail(
                    userId: userId,
                    sender: senderCtrl.text,
                    subject: subjectCtrl.text,
                    body: bodyCtrl.text,
                  );
            },
            child: Text(
              'Analyze with AI',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final allThreats = [
      _ThreatRecord(
        id: 'TH-9021',
        title: 'Zero-Day Banking Phishing Domain Intercepted',
        vector: 'Web Shield',
        timestamp: '4m ago',
        severity: ThreatSeverity.critical,
        status: 'Access Blocked',
        category: 'Phishing',
        details: 'Typosquatted domain mimicking Chase online banking with TLS spoof certificate.',
      ),
      _ThreatRecord(
        id: 'TH-9020',
        title: 'AI Synthetic Voice Clone Spoof Silenced',
        vector: 'Voice Sentinel',
        timestamp: '22m ago',
        severity: ThreatSeverity.high,
        status: 'Call Terminated',
        category: 'Calls',
        details: 'VoIP caller with 91% synthetic speech variance matching extortion scripts.',
      ),
      _ThreatRecord(
        id: 'TH-9019',
        title: 'Malicious QR Payment Redirect Neutralized',
        vector: 'QR Sentinel',
        timestamp: '1h ago',
        severity: ThreatSeverity.medium,
        status: 'Intent Defanged',
        category: 'QR Codes',
        details: 'Embedded APK download link disguised as parking payment meter code.',
      ),
      _ThreatRecord(
        id: 'TH-9018',
        title: 'Rogue App Background Accessibility Abuse Blocked',
        vector: 'App Auditor',
        timestamp: '3h ago',
        severity: ThreatSeverity.high,
        status: 'Permission Revoked',
        category: 'Apps',
        details: 'Flashlight utility requested foreground screen scraping accessibility privilege.',
      ),
      _ThreatRecord(
        id: 'TH-9017',
        title: 'Smishing SMS with Malicious Banking APK Link',
        vector: 'Notification Guard',
        timestamp: 'Yesterday',
        severity: ThreatSeverity.critical,
        status: 'Alert Pushed',
        category: 'Phishing',
        details: 'Fake postal parcel alert containing sideloading Trojan dropper.',
      ),
      _ThreatRecord(
        id: 'TH-9016',
        title: 'Unsecured Public Wi-Fi DNS Hijack Prevention',
        vector: 'Network Armor',
        timestamp: '2 days ago',
        severity: ThreatSeverity.safe,
        status: 'DoH Tunnel Forced',
        category: 'Network',
        details: 'Forced DNS-over-HTTPS encryption when rogue AP spoofed gateway router.',
      ),
    ];

    final filteredThreats = _selectedFilter == 'All'
        ? allThreats
        : allThreats.where((t) => t.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Threat History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: CyberColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_unread_rounded, color: CyberColors.primary),
            tooltip: 'Audit Inbound Email',
            onPressed: () => _showAuditEmailDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All', allThreats.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('Phishing', 2),
                    const SizedBox(width: 8),
                    _buildFilterChip('Calls', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('QR Codes', 1),
                    const SizedBox(width: 8),
                    _buildFilterChip('Apps', 1),
                  ],
                ),
              ),
            ),

            // Threat Feed List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredThreats.length,
                itemBuilder: (context, index) {
                  final record = filteredThreats[index];
                  return _buildThreatCard(record);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CyberColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : CyberColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : CyberColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatCard(_ThreatRecord record) {
    Color severityColor;
    switch (record.severity) {
      case ThreatSeverity.critical:
        severityColor = CyberColors.danger;
        break;
      case ThreatSeverity.high:
        severityColor = const Color(0xFFF97316);
        break;
      case ThreatSeverity.medium:
        severityColor = CyberColors.warning;
        break;
      case ThreatSeverity.safe:
        severityColor = CyberColors.success;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: severityColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      record.severity.name.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                record.timestamp,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CyberColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            record.details,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.4,
              color: CyberColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.vector,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CyberColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreatRecord {
  final String id;
  final String title;
  final String vector;
  final String timestamp;
  final ThreatSeverity severity;
  final String status;
  final String category;
  final String details;

  _ThreatRecord({
    required this.id,
    required this.title,
    required this.vector,
    required this.timestamp,
    required this.severity,
    required this.status,
    required this.category,
    required this.details,
  });
}
