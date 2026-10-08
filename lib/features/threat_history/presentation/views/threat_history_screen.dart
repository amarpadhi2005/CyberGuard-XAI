import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../../../core/widgets/cyber_button.dart';
import '../../../../core/widgets/cyber_loading_indicator.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/threat_history_controller.dart';
import '../widgets/threat_filter_bar.dart';
import '../widgets/threat_history_card.dart';
import '../widgets/threat_timeline_node.dart';

class ThreatHistoryScreen extends StatefulWidget {
  const ThreatHistoryScreen({super.key});

  @override
  State<ThreatHistoryScreen> createState() => _ThreatHistoryScreenState();
}

class _ThreatHistoryScreenState extends State<ThreatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
      context.read<ThreatHistoryController>().loadHistory(userId);
    });
  }

  void _showEmailScanDialog(BuildContext context) {
    final subjectCtrl = TextEditingController(
        text: 'Urgent Wire Transfer Authorization (CEO Executive Request)');
    final senderCtrl = TextEditingController(text: 'ceo@executive-internal-corp.net');
    final bodyCtrl = TextEditingController(
        text:
            'Please execute an immediate confidential wire transfer of \$42,500 to vendor account #882910. I am currently in a board meeting and cannot take calls.');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: CyberColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CyberColors.borderSubtle, width: 1.0),
              boxShadow: const [CyberColors.cardShadow],
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: CyberColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.mark_email_unread_rounded,
                                color: CyberColors.primaryBlue, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'AUDIT EMAIL SCAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 18),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analyze an inbound email with Gemini AI and record to Firestore threat history.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Sender
                  Text('SENDER',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textSecondary)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: senderCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CyberColors.surfaceSecondary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subject
                  Text('SUBJECT',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textSecondary)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: subjectCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CyberColors.surfaceSecondary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Body
                  Text('EMAIL BODY',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textSecondary)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CyberColors.surfaceSecondary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: CyberColors.primaryBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Consumer<ThreatHistoryController>(
                    builder: (context, controller, child) {
                      return CyberButton(
                        text: 'ANALYZE & RECORD EMAIL',
                        icon: Icons.shield,
                        isLoading: controller.isEmailAnalyzing,
                        onPressed: () async {
                          final auth = context.read<AuthController>();
                          final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

                          final item = await controller.analyzeEmail(
                            subject: subjectCtrl.text.trim(),
                            sender: senderCtrl.text.trim(),
                            body: bodyCtrl.text.trim(),
                            userId: userId,
                          );

                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                            if (item != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Recorded email threat (${item.severity.label}): ${item.threatType}'),
                                  backgroundColor: CyberColors.textPrimary,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      subjectCtrl.dispose();
      senderCtrl.dispose();
      bodyCtrl.dispose();
    });
  }

  void _showClearAllConfirmation(BuildContext context) {
    final auth = context.read<AuthController>();
    final controller = context.read<ThreatHistoryController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberColors.borderSubtle, width: 1),
        ),
        title: Text(
          'PURGE ENTIRE THREAT HISTORY?',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.criticalDanger,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          'This will permanently delete all scan records from Cloud Firestore for your account.',
          style: GoogleFonts.plusJakartaSans(
            color: CyberColors.textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.plusJakartaSans(
                color: CyberColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CyberColors.criticalDanger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.clearAll(userId);
            },
            child: Text(
              'CLEAR ALL',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<ThreatHistoryController>();
    final userId = auth.currentUser?.uid ?? 'DEMO_USER_001';
    final timelineGroups = controller.timelineGroups;

    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: CyberColors.borderSubtle, height: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: CyberColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_edu_rounded,
                color: CyberColors.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              'THREAT HISTORY INTELLIGENCE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Scan Inbound Email Action
          IconButton(
            icon: const Icon(Icons.add_moderator_outlined,
                color: CyberColors.primaryBlue, size: 22),
            tooltip: 'Audit Inbound Email',
            onPressed: () => _showEmailScanDialog(context),
          ),
          // More Menu: Reseed / Clear All
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: CyberColors.textSecondary, size: 20),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: CyberColors.borderSubtle),
            ),
            onSelected: (val) {
              if (val == 'reseed') {
                controller.reseedDemo(userId);
              } else if (val == 'clear') {
                _showClearAllConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reseed',
                child: Row(
                  children: [
                    const Icon(Icons.restore_rounded,
                        color: CyberColors.primaryBlue, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'RESTORE BENCHMARKS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep_rounded,
                        color: CyberColors.criticalDanger, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'PURGE ALL SCANS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CyberColors.criticalDanger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: CyberColors.primaryBlue,
          backgroundColor: Colors.white,
          onRefresh: () => controller.loadHistory(userId),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Controls & Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Metric HUD
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: CyberColors.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: CyberColors.borderSubtle,
                            width: 1,
                          ),
                          boxShadow: const [CyberColors.cardShadow],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              label: 'TOTAL AUDITED',
                              value: '${controller.totalScans}',
                              color: CyberColors.textPrimary,
                            ),
                            Container(
                                width: 1, height: 26, color: CyberColors.borderSubtle),
                            _buildStatColumn(
                              label: 'CRITICAL THREATS',
                              value: '${controller.criticalThreatsCount}',
                              color: CyberColors.criticalDanger,
                            ),
                            Container(
                                width: 1, height: 26, color: CyberColors.borderSubtle),
                            _buildStatColumn(
                              label: 'SAFE SCANS',
                              value: '${controller.safeScansCount}',
                              color: CyberColors.success,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filter & Search Bar
                      ThreatFilterBar(
                        searchQuery: controller.searchQuery,
                        onSearchChanged: controller.setSearchQuery,
                        selectedCategory: controller.selectedCategory,
                        onCategoryChanged: controller.setCategoryFilter,
                        selectedSeverity: controller.selectedSeverity,
                        onSeverityChanged: controller.setSeverityFilter,
                        onResetFilters: controller.resetFilters,
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Timeline List or Loading / Empty states
              if (controller.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CyberLoadingIndicator(
                      statusText: 'FETCHING CLOUD FIRESTORE AUDIT LOGS...',
                    ),
                  ),
                )
              else if (timelineGroups.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: CyberColors.borderSubtle,
                                width: 1.0,
                              ),
                              boxShadow: const [CyberColors.cardShadow],
                            ),
                            child: const Icon(
                              Icons.manage_search_rounded,
                              size: 40,
                              color: CyberColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'NO MATCHING THREAT SCANS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.searchQuery.isNotEmpty ||
                                    controller.selectedCategory != null ||
                                    controller.selectedSeverity != null
                                ? 'No scans matched your search query or filters.'
                                : 'No scans logged in Cloud Firestore yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: CyberColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (controller.searchQuery.isNotEmpty ||
                              controller.selectedCategory != null ||
                              controller.selectedSeverity != null)
                            CyberButton(
                              text: 'RESET ALL FILTERS',
                              icon: Icons.filter_alt_off_rounded,
                              variant: CyberButtonVariant.outline,
                              height: 38,
                              onPressed: controller.resetFilters,
                            )
                          else
                            CyberButton(
                              text: 'LOAD BENCHMARK AUDITS',
                              icon: Icons.restore_rounded,
                              variant: CyberButtonVariant.primary,
                              height: 38,
                              onPressed: () => controller.reseedDemo(userId),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final keys = timelineGroups.keys.toList();
                        final groupTitle = keys[index];
                        final itemsInGroup = timelineGroups[groupTitle]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ThreatTimelineHeader(
                              title: groupTitle,
                              count: itemsInGroup.length,
                            ),
                            ...itemsInGroup.map((item) {
                              return ThreatHistoryCard(
                                item: item,
                                onDelete: () =>
                                    controller.deleteItem(item.id, userId),
                              );
                            }),
                          ],
                        );
                      },
                      childCount: timelineGroups.keys.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: CyberColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
