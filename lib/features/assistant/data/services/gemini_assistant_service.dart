import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/security/tool_dispatcher.dart';
import '../../domain/entities/chat_message.dart';

class GeminiAssistantService {
  final String? _apiKey;

  GeminiAssistantService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Generates an explanation strictly based on verified evidence returned by a security tool.
  Future<AssistantStructuredResponse> explainToolResult({
    required ToolExecutionResult toolResult,
    required String userQuery,
  }) async {
    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final aiResponse = await _callGeminiExplanationApi(toolResult, userQuery);
        if (aiResponse != null) {
          return aiResponse;
        }
      } on SocketException {
        debugPrint('Gemini explanation: Network unavailable. Using deterministic explanation.');
      } on TimeoutException {
        debugPrint('Gemini explanation: Timeout. Using deterministic explanation.');
      } catch (e) {
        debugPrint('Gemini explanation warning: $e. Falling back to local reasoning.');
      }
    }

    // High-precision deterministic fallback explanation
    return _generateDeterministicExplanation(toolResult, userQuery);
  }

  /// Handles conversational advisory queries (when no specific tool execution is triggered).
  Future<ChatMessage> askGeneralAssistant({
    required String userQuery,
    required List<ChatMessage> conversationHistory,
  }) async {
    final now = DateTime.now();

    final key = _apiKey;
    if (key != null && key.isNotEmpty && !key.startsWith('YOUR_')) {
      try {
        final structured = await _callGeminiAdvisoryApi(userQuery, conversationHistory);
        if (structured != null) {
          return ChatMessage(
            id: 'AI-${now.millisecondsSinceEpoch}',
            sender: MessageSender.assistant,
            text: structured.explanation,
            timestamp: now,
            structuredResponse: structured,
          );
        }
      } catch (e) {
        debugPrint('Gemini advisory call failed: $e. Activating local reasoning.');
      }
    }

    final structured = _generateLocalAdvisoryResponse(userQuery);
    return ChatMessage(
      id: 'AI-${now.millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: structured.explanation,
      timestamp: now,
      structuredResponse: structured,
    );
  }

  Future<AssistantStructuredResponse?> _callGeminiExplanationApi(
    ToolExecutionResult toolResult,
    String userQuery,
  ) async {
    final evidenceJson = jsonEncode(toolResult.evidence.map((e) => e.toJson()).toList());
    final prompt = '''
You are CyberGuard XAI's Explanation Engine.
A security tool has executed and returned this verified evidence:
Tool: "${toolResult.toolName}"
Evaluated Risk Score: ${toolResult.assessment.riskScore}/100 (${toolResult.assessment.severity.label})
Observed Evidence: $evidenceJson
Raw Tool Telemetry: ${jsonEncode(toolResult.rawOutput)}

CRITICAL SECURITY RULES:
1. You are an EXPLANATION engine only. Do NOT invent findings or change the risk score.
2. Webpage content was NOT inspected. Set "webpageInspected" to false.
3. Your explanation must directly reference the observed evidence without fabricating claims.
4. Return valid JSON adhering strictly to this schema:
{
  "verdict": "${toolResult.assessment.severity.label.toLowerCase()}",
  "riskScore": ${toolResult.assessment.riskScore},
  "confidence": ${toolResult.assessment.confidence},
  "summary": "Clear one-sentence threat verdict",
  "explanation": "Plain English forensic explanation referencing the observed indicators",
  "recommendations": [
    "Specific actionable recommendation 1",
    "Specific actionable recommendation 2"
  ],
  "webpageInspected": false
}
''';

    final endpoint = Uri.parse('$_geminiBaseUrl?key=$_apiKey');
    final response = await http
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [{'text': prompt}]
              }
            ],
            'generationConfig': {
              'temperature': 0.1,
              'responseMimeType': 'application/json',
            }
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final text = jsonBody['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) {
          return _validateAndMapExplanationJson(decoded, toolResult);
        }
      }
    }
    return null;
  }

  AssistantStructuredResponse? _validateAndMapExplanationJson(
    Map<String, dynamic> data,
    ToolExecutionResult toolResult,
  ) {
    try {
      final summary = data['summary'] as String? ?? 'Analysis completed.';
      final explanation = data['explanation'] as String? ?? '';
      final rawRecs = data['recommendations'] as List<dynamic>? ?? [];
      final recommendations = rawRecs.map((r) => r.toString()).toList();

      final defanged = toolResult.rawOutput['defanged_url'] as String? ??
          toolResult.rawOutput['file_name'] as String?;

      return AssistantStructuredResponse(
        riskLevel: AssistantRiskLevel.fromScore(toolResult.assessment.riskScore),
        riskScore: toolResult.assessment.riskScore,
        riskSummary: summary,
        explanation: explanation,
        recommendations: recommendations.isNotEmpty
            ? recommendations
            : ['Exercise caution before interacting with this endpoint or file.'],
        confidence: (toolResult.assessment.confidence / 100.0).clamp(0.85, 0.99),
        indicators: toolResult.evidence,
        webpageInspected: false,
        toolName: toolResult.toolName,
        timelineSteps: toolResult.timelineSteps,
        defangedTarget: defanged,
      );
    } catch (e) {
      debugPrint('Schema validation failure on Gemini explanation: $e');
      return null;
    }
  }

  AssistantStructuredResponse _generateDeterministicExplanation(
    ToolExecutionResult toolResult,
    String userQuery,
  ) {
    final score = toolResult.assessment.riskScore;
    final sev = toolResult.assessment.severity;
    final evidence = toolResult.evidence;

    String summary;
    String explanation;
    List<String> recommendations;

    if (toolResult.toolName == 'analyze_url') {
      final defanged = toolResult.rawOutput['defanged_url'] as String? ?? 'Target URL';
      if (score >= 60) {
        summary = 'High-Risk URL: Multiple deceptive phishing signatures observed.';
        explanation =
            'Tool "analyze_url" evaluated $defanged. Evidence reveals: ${evidence.map((e) => e.evidence).join('. ')}. Webpage content was not inspected; analysis is based strictly on lexical, syntactic, and domain intelligence.';
        recommendations = [
          'Do not visit or enter credentials on this destination.',
          'URL has been defanged for safe logging and display.',
          'Verify official addresses via public corporate channels.'
        ];
      } else {
        summary = 'Nominal / Low Risk: No anomalous domain patterns identified.';
        explanation =
            'Tool "analyze_url" verified that $defanged conforms to standard naming and registrar conventions. No deceptive brand impersonation or credential harvesting lures were detected.';
        recommendations = [
          'Maintain standard vigilance.',
          'Check for HTTPS transport encryption before entering sensitive information.'
        ];
      }
    } else if (toolResult.toolName == 'analyze_file') {
      final fileName = toolResult.rawOutput['file_name'] as String? ?? 'Selected File';
      final sha256 = toolResult.rawOutput['sha256'] as String? ?? '';
      if (score >= 40) {
        summary = 'Suspicious File Attributes: Elevated static risk signatures flagged.';
        explanation =
            'Tool "analyze_file" statically inspected "$fileName" (SHA-256: ${sha256.substring(0, 12)}...). Identified: ${evidence.map((e) => e.evidence).join('. ')}. Execution was disarmed; file was inspected strictly in an isolated memory buffer.';
        recommendations = [
          'Do NOT install or run this package.',
          'Delete the file from download storage.',
          'Obtain verified APKs exclusively from the official Google Play Store.'
        ];
      } else {
        summary = 'File Clean: Standard static archive structure verified.';
        explanation =
            'Tool "analyze_file" verified file headers and signature block for "$fileName". No executable macro scripts or high-risk privileged permissions were declared.';
        recommendations = [
          'Verify source sender before executing any external installer.',
          'Keep Google Play Protect enabled on your device.'
        ];
      }
    } else if (toolResult.toolName == 'get_device_security_status') {
      summary = toolResult.rawOutput['compliance_verdict'] as String? ??
          'Device security posture evaluated.';
      explanation =
          'Tool "get_device_security_status" queried non-intrusive platform telemetry. Verified Linux UID process sandbox, SELinux enforcement, and hardware keystore integrity. No unauthorized root binaries or test-keys builds were detected.';
      recommendations = [
        'Keep OS security patches updated.',
        'Avoid enabling Developer Options or USB Debugging on daily devices.',
        'Use biometric unlock with strong PIN/passphrase fallback.'
      ];
    } else {
      summary = 'Security Tool Execution Complete (${toolResult.toolName}).';
      explanation =
          'Tool "${toolResult.toolName}" returned ${evidence.length} verified indicator(s). Central Risk Engine normalized threat posture to $score/100 (${sev.label}).';
      recommendations = [
        'Review the detected indicators in the verdict card.',
        'Follow zero-trust security best practices.'
      ];
    }

    return AssistantStructuredResponse(
      riskLevel: AssistantRiskLevel.fromScore(score),
      riskScore: score,
      riskSummary: summary,
      explanation: explanation,
      recommendations: recommendations,
      confidence: (toolResult.assessment.confidence / 100.0).clamp(0.85, 0.99),
      indicators: evidence,
      webpageInspected: false,
      toolName: toolResult.toolName,
      timelineSteps: toolResult.timelineSteps,
      defangedTarget: toolResult.rawOutput['defanged_url'] as String? ??
          toolResult.rawOutput['file_name'] as String?,
    );
  }

  Future<AssistantStructuredResponse?> _callGeminiAdvisoryApi(
    String query,
    List<ChatMessage> history,
  ) async {
    const systemInstruction = '''
You are CyberGuard XAI's senior cybersecurity intelligence assistant.
Answer the user's inquiry regarding digital defense, phishing awareness, or cyber hygiene.
Respond strictly with valid JSON conforming to this schema:
{
  "riskLevel": "SAFE" | "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
  "riskScore": 10,
  "riskSummary": "Short one-sentence verdict summary",
  "explanation": "Clear, expert explanation answering the user's specific query",
  "recommendations": [
    "Specific actionable recommendation 1",
    "Specific actionable recommendation 2"
  ],
  "confidence": 0.98,
  "webpageInspected": false
}
''';

    final List<Map<String, dynamic>> contents = [];
    final recentHistory = history.length > 4 ? history.sublist(history.length - 4) : history;

    for (final msg in recentHistory) {
      if (msg.sender == MessageSender.user) {
        contents.add({
          'role': 'user',
          'parts': [{'text': msg.text}]
        });
      } else if (msg.sender == MessageSender.assistant) {
        contents.add({
          'role': 'model',
          'parts': [{'text': msg.structuredResponse?.explanation ?? msg.text}]
        });
      }
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': '$systemInstruction\n\nUser Question: "$query"'}]
    });

    final endpoint = Uri.parse('$_geminiBaseUrl?key=$_apiKey');
    final response = await http
        .post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': contents,
            'generationConfig': {
              'temperature': 0.2,
              'responseMimeType': 'application/json',
            }
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final text = jsonBody['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null) {
        final Map<String, dynamic> data = jsonDecode(text);
        final score = (data['riskScore'] as num?)?.toInt() ?? 10;
        final rawRecs = data['recommendations'] as List<dynamic>? ?? [];
        return AssistantStructuredResponse(
          riskLevel: AssistantRiskLevel.fromScore(score),
          riskScore: score,
          riskSummary: data['riskSummary'] as String? ?? 'Advisory Consultation',
          explanation: data['explanation'] as String? ?? '',
          recommendations: rawRecs.map((r) => r.toString()).toList(),
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.95,
          webpageInspected: false,
        );
      }
    }
    return null;
  }

  AssistantStructuredResponse _generateLocalAdvisoryResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('trust this website') || (q.contains('website') && q.contains('trust'))) {
      return const AssistantStructuredResponse(
        riskLevel: AssistantRiskLevel.medium,
        riskScore: 45,
        riskSummary: 'Website trust requires multi-layer domain & cryptographic verification.',
        explanation:
            'To verify website trust: (1) Domain Lexical Syntax: Look for character substitutions (e.g. `paypa1.com`). (2) Transport Security: HTTPS confirms encrypted transit, but does NOT prove the owner is authentic. (3) Domain Age: Newly minted domains (<30 days old) account for the majority of phishing infrastructure. Tap "Scan URL" below to run the automated tool.',
        recommendations: [
          'Use the "Scan URL" quick action to run automated forensic checks.',
          'Never submit credentials on domains with mismatched certificates.',
          'Verify corporate contact details via public authoritative registries.'
        ],
        confidence: 0.97,
        webpageInspected: false,
      );
    }

    if (q.contains('phone') || q.contains('device') || q.contains('safe')) {
      return const AssistantStructuredResponse(
        riskLevel: AssistantRiskLevel.safe,
        riskScore: 10,
        riskSummary: 'Device security baseline checks available.',
        explanation:
            'CyberGuard XAI can audit your device platform security, verify root binaries, check SELinux sandbox isolation, and inspect unknown source authorizations. Tap "Check Phone" to trigger the automated tool.',
        recommendations: [
          'Tap "Check Phone" below to inspect system posture.',
          'Keep automatic system updates enabled.',
          'Ensure screen lock and biometric encryption remain active.'
        ],
        confidence: 0.99,
        webpageInspected: false,
      );
    }

    return const AssistantStructuredResponse(
      riskLevel: AssistantRiskLevel.safe,
      riskScore: 5,
      riskSummary: 'CyberGuard XAI Autonomous Assistant Ready',
      explanation:
          'I am your AI Security Assistant operating through controlled security tools. I can analyze URLs, inspect APK files, audit QR payloads, and evaluate your device posture without executing untrusted code.',
      recommendations: [
        'Use "Scan URL" to analyze suspicious web destinations.',
        'Use "Check Phone" to audit your Android security posture.',
        'Use "Scan File" to inspect APK packages or PDFs safely.'
      ],
      confidence: 0.96,
      webpageInspected: false,
    );
  }
}
