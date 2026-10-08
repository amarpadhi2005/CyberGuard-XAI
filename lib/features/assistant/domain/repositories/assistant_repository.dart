import '../entities/chat_message.dart';

abstract class AssistantRepository {
  /// Sends user inquiry to assistant and receives structured cybersecurity response
  Future<ChatMessage> sendMessage({
    required String query,
    required List<ChatMessage> conversationHistory,
  });

  /// Executes a registered security tool through the Tool Dispatcher and explains verified evidence
  Future<ChatMessage> executeTool({
    required String toolName,
    Map<String, dynamic> arguments = const {},
    required String userQuery,
  });

  /// Loads persisted conversation history
  Future<List<ChatMessage>> getConversationHistory();

  /// Clears stored chat history
  Future<void> clearHistory();
}
