import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../data/repositories/assistant_repository_impl.dart';

class AssistantController extends ChangeNotifier {
  final AssistantRepository _repository;

  List<ChatMessage> _messages = [];
  bool _isThinking = false;
  String? _errorMessage;
  String _activeToolStatus = '';

  // Streaming typewriter animation state
  bool _isTyping = false;
  String _typedExplanation = '';
  ChatMessage? _activeStreamingMessage;

  final List<String> _quickActionPrompts = [
    'Check this URL',
    'Scan this QR',
    'Check this APK',
    'Check my phone',
    'Show report',
    'Why is this dangerous?',
    'Explain this score',
  ];

  bool enableTypewriter = true;

  AssistantController({
    AssistantRepository? repository,
    this.enableTypewriter = true,
  }) : _repository = repository ?? AssistantRepositoryImpl() {
    _loadHistory();
  }

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isThinking => _isThinking;
  bool get isTyping => _isTyping;
  String get activeToolStatus => _activeToolStatus;
  String get typedExplanation => _typedExplanation;
  ChatMessage? get activeStreamingMessage => _activeStreamingMessage;
  String? get errorMessage => _errorMessage;
  List<String> get presetQuestions => List.unmodifiable(_quickActionPrompts);

  Future<void> _loadHistory() async {
    final history = await _repository.getConversationHistory();
    if (_messages.isEmpty) {
      _messages = List.from(history);
    } else {
      final existingIds = _messages.map((m) => m.id).toSet();
      final toAdd = history.where((m) => !existingIds.contains(m.id)).toList();
      _messages.insertAll(0, toAdd);
    }
    notifyListeners();
  }

  /// Sends a user message, performs intent routing, or invokes the tool dispatcher.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: 'USR-${now.millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: trimmed,
      timestamp: now,
    );

    _messages.add(userMessage);
    _isThinking = true;
    _errorMessage = null;
    _activeToolStatus = 'Routing query to Security Tool Dispatcher...';
    notifyListeners();

    try {
      final aiResponse = await _repository.sendMessage(
        query: trimmed,
        conversationHistory: _messages,
      );

      _isThinking = false;
      _activeToolStatus = '';
      notifyListeners();

      // Trigger typewriter streaming animation for explanation
      await _streamTypewriterEffect(aiResponse);
    } catch (e) {
      _isThinking = false;
      _activeToolStatus = '';
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Explicitly dispatches a registered security tool.
  Future<void> triggerTool({
    required String toolName,
    Map<String, dynamic> arguments = const {},
    required String userPrompt,
  }) async {
    final now = DateTime.now();
    final userMessage = ChatMessage(
      id: 'USR-${now.millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: userPrompt,
      timestamp: now,
    );

    _messages.add(userMessage);
    _isThinking = true;
    _errorMessage = null;
    _activeToolStatus = 'Dispatching tool "$toolName"...';
    notifyListeners();

    try {
      final aiResponse = await _repository.executeTool(
        toolName: toolName,
        arguments: arguments,
        userQuery: userPrompt,
      );

      _isThinking = false;
      _activeToolStatus = '';
      notifyListeners();

      await _streamTypewriterEffect(aiResponse);
    } catch (e) {
      _isThinking = false;
      _activeToolStatus = '';
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Quick Action Triggers
  Future<void> scanUrl(String url) async {
    await triggerTool(
      toolName: 'analyze_url',
      arguments: {'url': url},
      userPrompt: 'Check this URL: $url',
    );
  }

  Future<void> checkPhone() async {
    await triggerTool(
      toolName: 'get_device_security_status',
      userPrompt: 'Check my phone security posture',
    );
  }

  Future<void> checkApk({Uint8List? bytes, String fileName = 'suspicious_app.apk'}) async {
    await triggerTool(
      toolName: 'analyze_file',
      arguments: {'bytes': bytes, 'fileName': fileName},
      userPrompt: 'Check this APK package: $fileName',
    );
  }

  Future<void> showReport() async {
    await triggerTool(
      toolName: 'generate_security_report',
      userPrompt: 'Show security audit report',
    );
  }

  Future<void> scanQr(String payload) async {
    await triggerTool(
      toolName: 'scan_qr_code',
      arguments: {'payload': payload},
      userPrompt: 'Scan this QR code payload',
    );
  }

  Future<void> _streamTypewriterEffect(ChatMessage response) async {
    final fullExplanation = response.structuredResponse?.explanation ?? response.text;
    if (!enableTypewriter || fullExplanation.isEmpty) {
      _messages.add(response);
      notifyListeners();
      return;
    }

    _isTyping = true;
    _activeStreamingMessage = response;
    _typedExplanation = '';
    notifyListeners();

    final step = fullExplanation.length > 250 ? 6 : 3;
    for (int i = 0; i < fullExplanation.length; i += step) {
      if (!_isTyping) break;
      final end = (i + step < fullExplanation.length) ? i + step : fullExplanation.length;
      _typedExplanation = fullExplanation.substring(0, end);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 10));
    }

    if (!_isTyping) return;

    _isTyping = false;
    _activeStreamingMessage = null;
    _typedExplanation = '';
    _messages.add(response);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _isTyping = false;
    _isThinking = false;
    _activeStreamingMessage = null;
    _typedExplanation = '';
    await _repository.clearHistory();
    _messages = await _repository.getConversationHistory();
    _errorMessage = null;
    notifyListeners();
  }
}
