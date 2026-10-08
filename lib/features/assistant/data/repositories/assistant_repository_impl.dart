import '../../../../core/security/tool_dispatcher.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../services/gemini_assistant_service.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final GeminiAssistantService _service;
  final SecurityToolDispatcher _dispatcher;
  final List<ChatMessage> _messages = [];

  AssistantRepositoryImpl({
    GeminiAssistantService? service,
    SecurityToolDispatcher? dispatcher,
  })  : _service = service ?? GeminiAssistantService(),
        _dispatcher = dispatcher ?? SecurityToolDispatcher() {
    _initializeWelcomeMessage();
  }

  void _initializeWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          id: 'INIT-001',
          sender: MessageSender.assistant,
          text:
              'CyberGuard AI Assistant is online, operating strictly through controlled security tools.\n\nI can analyze URLs, inspect APK files, audit QR payloads, and evaluate device security posture without executing untrusted code.',
          timestamp: DateTime.now(),
          structuredResponse: const AssistantStructuredResponse(
            riskLevel: AssistantRiskLevel.safe,
            riskScore: 0,
            riskSummary: 'Controlled Tool Dispatcher Armed',
            explanation:
                'All security operations run through registered forensic tools. Gemini acts strictly as an explanation engine—never executing code directly or inventing evidence.',
            recommendations: [
              'Tap "Scan URL" to analyze a suspicious link.',
              'Tap "Check Phone" to audit Android security posture.',
              'Tap "Scan File" to inspect an APK package without running it.',
              'Tap "Security Report" for an endpoint overview.'
            ],
            confidence: 0.99,
            webpageInspected: false,
          ),
        ),
      );
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String query,
    required List<ChatMessage> conversationHistory,
  }) async {
    // 1. Automatic Tool Intent Detection
    final lower = query.toLowerCase().trim();

    // URL Detection: e.g. "Check this URL https://example.com" or just a URL
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final match = urlRegex.firstMatch(query);
    if (match != null || lower.startsWith('http://') || lower.startsWith('https://')) {
      final url = match != null ? match.group(0)! : query.trim();
      return executeTool(
        toolName: 'analyze_url',
        arguments: {'url': url},
        userQuery: query,
      );
    }

    // Device Check Intent: e.g. "Check my phone", "Check device", "Audit posture"
    if (lower.contains('check my phone') ||
        lower.contains('check device') ||
        lower.contains('scan phone') ||
        lower.contains('device security')) {
      return executeTool(
        toolName: 'get_device_security_status',
        userQuery: query,
      );
    }

    // Installed Apps Check Intent
    if (lower.contains('installed apps') || lower.contains('audit apps')) {
      return executeTool(
        toolName: 'get_installed_apps',
        userQuery: query,
      );
    }

    // Security Report Intent
    if (lower.contains('show report') ||
        lower.contains('security report') ||
        lower.contains('generate report')) {
      return executeTool(
        toolName: 'generate_security_report',
        userQuery: query,
      );
    }

    // QR Scan Intent (guiding user to camera scanner or analyzing explicitly provided payload)
    if (lower.contains('scan qr') ||
        lower.contains('scan a qr') ||
        lower.contains('check qr') ||
        lower.contains('qr scanner') ||
        lower.contains('scan this qr')) {
      final qrMatch = RegExp(r'qr:\s*(https?://[^\s]+|[a-zA-Z0-9][-a-zA-Z0-9]*\.[a-zA-Z]{2,}[^\s]*)', caseSensitive: false).firstMatch(query);
      if (qrMatch != null) {
        final payload = qrMatch.group(1)!.trim();
        return executeTool(
          toolName: 'scan_qr_code',
          arguments: {'payload': payload},
          userQuery: query,
        );
      }

      // If no explicit payload string was pasted, guide the user to launch the real physical camera scanner
      final now = DateTime.now();
      final guideMessage = ChatMessage(
        id: 'AI-QR-GUIDE-${now.millisecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text:
            'To scan a physical QR code, open CyberGuard\'s live camera QR Sentinel. It uses your phone\'s physical camera locally to detect the code and inspect the extracted URL for quishing, brand impersonation, and malicious redirects before any connection is made.',
        timestamp: now,
        structuredResponse: const AssistantStructuredResponse(
          riskLevel: AssistantRiskLevel.safe,
          riskScore: 0,
          riskSummary: 'Launch Real Camera QR Scanner',
          explanation:
              'The AI Assistant operates through controlled tools and does not directly access or stream your camera. Physical QR scanning is handled securely on-device by QR Sentinel using Android CAMERA permission.',
          recommendations: [
            'Tap the QR Sentinel card on the Home or Protection tab',
            'Grant one-time Camera permission when prompted',
            'Position the QR code inside the viewfinder reticle',
            'Review the verified risk score before opening'
          ],
          confidence: 1.0,
          webpageInspected: false,
        ),
      );
      _messages.add(guideMessage);
      return guideMessage;
    }

    // File / APK Check Intent (when mentioned as text)
    if (lower.contains('check this apk') || lower.contains('check apk') || lower.contains('scan file')) {
      return executeTool(
        toolName: 'analyze_file',
        arguments: {'fileName': 'invoice_urgent.apk'},
        userQuery: query,
      );
    }

    // 2. Conversational / Advisory Mode (Gemini explains cyber hygiene)
    final aiResponse = await _service.askGeneralAssistant(
      userQuery: query,
      conversationHistory: conversationHistory,
    );
    _messages.add(aiResponse);
    return aiResponse;
  }

  @override
  Future<ChatMessage> executeTool({
    required String toolName,
    Map<String, dynamic> arguments = const {},
    required String userQuery,
  }) async {
    // 1. Dispatch through Security Tool Dispatcher
    final ToolExecutionResult toolResult = await _dispatcher.dispatch(
      toolName: toolName,
      arguments: arguments,
    );

    // 2. Explain strictly via Gemini / Local Explainer
    final AssistantStructuredResponse explanation = await _service.explainToolResult(
      toolResult: toolResult,
      userQuery: userQuery,
    );

    final now = DateTime.now();
    final message = ChatMessage(
      id: 'AI-TOOL-${now.millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: explanation.explanation,
      timestamp: now,
      structuredResponse: explanation,
    );

    _messages.add(message);
    return message;
  }

  @override
  Future<List<ChatMessage>> getConversationHistory() async {
    return List.unmodifiable(_messages);
  }

  @override
  Future<void> clearHistory() async {
    _messages.clear();
    _initializeWelcomeMessage();
  }
}
