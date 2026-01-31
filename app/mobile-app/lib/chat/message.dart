import 'package:app/api.dart';
import 'package:app/chat/role.dart';
import 'package:app/chat/state.dart';

class Persona {
  final String? description;
  final String? userId;
  final Map<String, int> profileCategoryScores;

  const Persona({
    required this.description,
    required this.userId,
    required this.profileCategoryScores,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      description: json['description'] as String?,
      userId: json['user_id'] as String?,
      profileCategoryScores:
          (json['profile_category_scores'] as Map<String, dynamic>?)
                  ?.map((key, value) => MapEntry(key, value as int)) ??
              {},
    );
  }
}

class Message {
  final String message;
  final String? model;
  final bool conversationEnded;

  const Message({
    required this.message,
    required this.model,
    required this.conversationEnded,
  });

  static Message empty() => Message(
        message: '',
        model: null,
        conversationEnded: false,
      );

  factory Message.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'message': String message,
        'model': String? model,
        'conversation_ended': bool conversationEnded,
      } =>
        Message(
          message: message,
          model: model,
          conversationEnded: conversationEnded,
        ),
      _ => throw const FormatException('Failed to format message.'),
    };
  }
}

class Chat {
  final String content;
  final ChatRole role;
  final DateTime time;
  final bool displayToUser;
  final bool displayToAi;
  final bool conversationEnded;

  Chat({
    required this.content,
    required this.role,
    DateTime? time,
    this.displayToUser = true,
    this.displayToAi = true,
    this.conversationEnded = false,
  }) : time = time ?? DateTime.now();

  factory Chat.sent({
    required String message,
    bool displayToUser = true,
    displayToAi = true,
  }) =>
      Chat(
        content: message,
        role: ChatRole.user,
        displayToUser: displayToUser,
        displayToAi: displayToAi,
      );

  factory Chat.received({
    required String message,
    required bool conversationEnded,
  }) =>
      Chat(
        content: message,
        role: ChatRole.assistant,
        conversationEnded: conversationEnded,
      );

  factory Chat.opening({required String message}) =>
      Chat(content: message, role: ChatRole.assistant, displayToUser: false);

  static Future<List<Chat>> startup(ChatMode mode) async {
    final List<Chat> messages = [];
    final Message initialMsg = await getOpening(mode);
    messages.add(Chat.opening(message: initialMsg.message));
    final Message initialResponse = await getChatResponse(messages, true);
    messages.add(Chat.received(
      message: initialResponse.message,
      conversationEnded: initialResponse.conversationEnded,
    ));
    return messages;
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.toString().split('.').last,
      'content': content,
    };
  }
}
