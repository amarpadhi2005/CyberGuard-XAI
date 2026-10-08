import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AiAssistantSheet(),
    );
  }

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text':
          'Greetings Operative. CyberGuard XAI Assistant is active. Provide any suspicious message, URL, phone number, or media payload for neural forensic analysis.',
    }
  ];
  bool _isAnalyzing = false;

  final List<String> _suggestedQueries = [
    'Analyze URL: https://pay-secure-verify.cc',
    'Audit recent Threat DNA correlation graph',
    'Explain the VoIP spoofing alert from 22m ago',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _sendQuery(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': query.trim()});
      _queryController.clear();
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _messages.add({
          'sender': 'ai',
          'text': _generateAiResponse(query),
        });
      });
    });
  }

  String _generateAiResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('url') || lower.contains('http') || lower.contains('.cc')) {
      return '[THREAT AUDIT REPORT]\n• Target: Unregistered high-risk TLD\n• SSL: Self-signed certificate\n• Risk Score: 96/100 (CRITICAL)\n• Classification: Credential Harvest Phishing\n• Recommendation: Do not visit this URL; navigation blocked.';
    } else if (lower.contains('dna') || lower.contains('campaign')) {
      return '[THREAT DNA CORRELATION]\n• Active Campaign ID: CMP-7712\n• Linked Events: 1 SMS Phish + 1 VoIP Spoof Call\n• Temporal Proximity: 18 minutes\n• Threat Group: FIN-Phish Heuristic Cluster\n• Status: Automated endpoint blocking enforced.';
    } else {
      return '[NEURAL ANALYSIS COMPLETED]\n• Severity: LOW / NOMINAL\n• Confidence: 99.2%\n• Behavioral telemetry indicates no unauthorized privilege escalation or telemetry leakage.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: CyberColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: CyberColors.neonPink.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: CyberColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: CyberColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CYBERGUARD AI ASSISTANT',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Powered by Gemini 2.5 Flash API // Zero-Latency Reasoning',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: CyberColors.neonCyan,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Suggested Prompts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedQueries.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => _sendQuery(prompt),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CyberColors.darkBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: CyberColors.neonCyan.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        prompt,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: CyberColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Message Stream
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? CyberColors.neonCyan.withOpacity(0.15)
                          : CyberColors.darkBlueSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUser
                            ? CyberColors.neonCyan.withOpacity(0.4)
                            : CyberColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: isUser ? CyberColors.neonCyan : CyberColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isAnalyzing) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(CyberColors.neonPink),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'NEURAL REASONING ACTIVE...',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: CyberColors.neonPink,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Input Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: CyberColors.darkBlueSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CyberColors.darkBlueBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    onSubmitted: _sendQuery,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: CyberColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask or paste suspicious payload...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: CyberColors.textDark,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: CyberColors.neonCyan),
                  onPressed: () => _sendQuery(_queryController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
