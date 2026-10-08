import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../controllers/assistant_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/quick_prompts_row.dart';
import '../widgets/typing_indicator.dart';
import '../../../../core/widgets/cyber_pressable.dart';

class AssistantScreen extends StatefulWidget {
  final bool isEmbeddedInTab;
  const AssistantScreen({super.key, this.isEmbeddedInTab = false});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _inputController.text;
    if (text.trim().isEmpty) return;

    final controller = context.read<AssistantController>();
    controller.sendMessage(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _handleScanUrl() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_rounded, color: Color(0xFF0284C7), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Analyze URL Forensics',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the exact URL to inspect. CyberGuard analyzes host entropy, TLD risk, and threat databases without modifying your input.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: CyberColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'https://example-domain.com/path',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
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
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final url = textController.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(dialogCtx);
                context.read<AssistantController>().scanUrl(url);
                _scrollToBottom();
              }
            },
            child: Text(
              'Analyze URL',
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

  void _handleScanQr() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'QR Scanner & Quishing',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: CyberColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Direct launch camera scanner button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  'LAUNCH LIVE CAMERA SCANNER',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pushNamed(context, '/qr-scanner');
                },
              ),
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR PASTE RAW PAYLOAD',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: textController,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter decoded QR string or URL',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
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
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final payload = textController.text.trim();
              if (payload.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a QR payload or launch the camera.')),
                );
                return;
              }
              Navigator.pop(dialogCtx);
              context.read<AssistantController>().scanQr(payload);
              _scrollToBottom();
            },
            child: Text(
              'Inspect Text Payload',
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

  void _handleScanFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Static File & APK Inspection',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(sheetCtx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Zero-execution static analysis. Only parses manifest headers, signing hashes, and SHA-256 fingerprints in memory.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildAttachmentOption(
              icon: Icons.android_rounded,
              title: 'Inspect Suspicious APK Package',
              subtitle: 'Parses AndroidManifest, exported services, and debug flags without installation',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.read<AssistantController>().checkApk(
                  fileName: 'financial_trojan_sample.apk',
                );
                _scrollToBottom();
              },
            ),
            const SizedBox(height: 12),
            _buildAttachmentOption(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Inspect PDF Document Payload',
              subtitle: 'Detects embedded JavaScript, macro launch actions, and phishing links',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.read<AssistantController>().checkApk(
                  fileName: 'invoice_overdue_notice.pdf',
                );
                _scrollToBottom();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleCheckPhone() {
    context.read<AssistantController>().checkPhone();
    _scrollToBottom();
  }

  void _handleSecurityReport() {
    context.read<AssistantController>().showReport();
    _scrollToBottom();
  }

  void _toggleVoiceInput() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Listening for threat query...',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          backgroundColor: CyberColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
          });
          _sendMessage('Is it safe to click a delivery reschedule link from unknown sender?');
        }
      });
    }
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Clear Conversation Memory?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: CyberColors.textPrimary,
          ),
        ),
        content: Text(
          'All prior multi-turn forensic investigation context will be cleared from local storage.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: CyberColors.textSecondary,
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
              backgroundColor: CyberColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AssistantController>().clearHistory();
            },
            child: Text(
              'Clear History',
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
    return Scaffold(
      backgroundColor: CyberColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: !widget.isEmbeddedInTab,
        leading: widget.isEmbeddedInTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: CyberColors.textPrimary, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: CyberColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: CyberColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI SECURITY ASSISTANT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: CyberColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberColors.success,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Controlled Tools • Zero-Trust Engine',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: CyberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: CyberColors.textSecondary, size: 20),
            tooltip: 'Clear Chat History',
            onPressed: _confirmClearHistory,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Consumer<AssistantController>(
          builder: (context, controller, child) {
            final messages = controller.messages;

            if (controller.isThinking || controller.isTyping) {
              _scrollToBottom();
            }

            return Column(
              children: [
                // 1. Live Tool Status Banner (When active)
                if (controller.isThinking || controller.activeToolStatus.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.activeToolStatus.isNotEmpty
                                ? controller.activeToolStatus
                                : 'Evaluating security evidence via Risk Engine...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E40AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LIVE TOOL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Chat Messages Stream
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyState(controller)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          physics: const BouncingScrollPhysics(),
                          itemCount: messages.length +
                              (controller.isThinking ? 1 : 0) +
                              (controller.isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < messages.length) {
                              return ChatBubble(message: messages[index]);
                            }

                            if (controller.isThinking && index == messages.length) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
                                child: Row(
                                  children: [
                                    TypingIndicator(),
                                  ],
                                ),
                              );
                            }

                            if (controller.isTyping && controller.activeStreamingMessage != null) {
                              return ChatBubble(
                                message: controller.activeStreamingMessage!,
                                isStreaming: true,
                                streamedText: controller.typedExplanation,
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                ),

                // 3. Quick Actions Bar (Scan URL, Scan QR, Scan File, Check Phone, Security Report)
                QuickActionsBar(
                  onScanUrl: _handleScanUrl,
                  onScanQr: _handleScanQr,
                  onScanFile: _handleScanFile,
                  onCheckPhone: _handleCheckPhone,
                  onSecurityReport: _handleSecurityReport,
                ),

                // 4. Preset Quick Questions
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: QuickPromptsRow(
                    prompts: controller.presetQuestions,
                    onSelectPrompt: (prompt) => _sendMessage(prompt),
                  ),
                ),

                // 5. Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Plus / Quick Tools Button
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: CyberColors.primary, size: 24),
                        tooltip: 'Security Tools',
                        onPressed: _handleScanFile,
                      ),

                      // Input Text Field
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _inputController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: CyberColors.textPrimary,
                            ),
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Check URL, scan QR, analyze APK, or ask...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: CyberColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Voice Input Mic Button
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? CyberColors.danger : CyberColors.textSecondary,
                          size: 22,
                        ),
                        tooltip: 'Voice Input',
                        onPressed: _toggleVoiceInput,
                      ),

                      // Send Button
                      CyberPressable(
                        onTap: () => _sendMessage(),
                        semanticLabel: 'Send Question',
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: CyberColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(AssistantController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: CyberColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 32,
                color: CyberColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI SECURITY ASSISTANT',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: CyberColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How can I help protect your device?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gemini operates strictly as an explanation engine over verified evidence gathered by native security tools. No fabricated scores or fake quarantines.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.5,
                color: CyberColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildChipPrompt('Check this URL', () => _handleScanUrl()),
                _buildChipPrompt('Scan this QR', () => _handleScanQr()),
                _buildChipPrompt('Check this APK', () => _handleScanFile()),
                _buildChipPrompt('Check my phone', () => _handleCheckPhone()),
                _buildChipPrompt('Show report', () => _handleSecurityReport()),
                _buildChipPrompt('Why is this dangerous?', () => _sendMessage('Why is this dangerous?')),
                _buildChipPrompt('Explain this score', () => _sendMessage('Explain this score')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipPrompt(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CyberColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

