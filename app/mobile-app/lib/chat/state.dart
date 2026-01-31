import 'package:app/chat/message.dart';
import 'package:app/api.dart';
import 'package:app/chat/role.dart';
import 'package:app/utils/analytics.dart';
import 'package:flutter/material.dart';

enum ChatMode { discover, onboarding }

class ChatState extends ChangeNotifier {
  /* Variables */
  ChatMode chatMode = ChatMode.discover; // in future can be onboarding

  bool submitting = false;
  bool loadingReply = false;
  bool loadingPersona = false;
  bool newProfileStatus = false;
  bool startingUp = true;

  List<Chat> chatList = [];
  late Persona currentPersona;
  String loadingMessage = 'Updating profile...';

  String get chatImageAsset => 'assets/ume_gradient.gif';
  bool get isTextFieldEnable =>
      textEditingController.text.isNotEmpty && !submitting;
  List<Chat> get displayChat =>
      chatList.where((chat) => chat.displayToUser).toList();
  List<Chat> get observedChat =>
      chatList.where((chat) => chat.displayToAi).toList();
  bool get isUserFirstMessage => displayChat.length == 1;
  Chat get lastAssistantMsg =>
      chatList.lastWhere((chat) => chat.role == ChatRole.assistant);
  bool submittableChat() =>
      chatList.length > 2 &&
      lastAssistantMsg.conversationEnded == true &&
      !loadingReply;

  /* Controllers */
  late final ScrollController scrollController = ScrollController();
  late final TextEditingController textEditingController =
      TextEditingController();
  late final FocusNode focusNode = FocusNode();

  /* Constructor */
  ChatState() {
    initialise();
  }

  void markAsChanged() {
    notifyListeners();
  }

  void emptyState() {
    chatList = [];
    loadingReply = true;
    loadingPersona = true;
    notifyListeners();
  }

  Future<void> initialise() async {
    emptyState();

    // jointly get chat history and persona
    final results = await Future.wait([
      Chat.startup(chatMode),
      getPersona(),
    ]);
    chatList = results[0] as List<Chat>;
    currentPersona = results[1] as Persona;

    loadingReply = false;
    loadingPersona = false;
    startingUp = false;
    notifyListeners();
  }

  bool allowedToSubmit() {
    return (isTextFieldEnable || !startingUp);
  }

  /* Intents */
  Future<void> onMessageSent([bool displayToUser = true]) async {
    // Block if message is empty, loading reply
    if (!allowedToSubmit()) return;
    logUserEvent('send_message');

    // Append user message and animate
    final Chat userMsg = Chat.sent(
      message: textEditingController.text,
      displayToUser: displayToUser,
    );
    chatList.add(userMsg);
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    textEditingController.text = '';
    notifyListeners();

    // Get response from AI
    loadingReply = true;
    notifyListeners();
    getChatResponse(observedChat, false).then((response) {
      final Chat receivedChat = Chat.received(
        message: response.message,
        conversationEnded: response.conversationEnded,
      );
      chatList.add(receivedChat);
      loadingReply = false;
      notifyListeners();
    });
  }

  void onFieldChanged(String term) {
    notifyListeners();
  }

  Future<void> submitChatHistory(context) async {
    logUserEvent('try_submit_chat');
    submitting = true;
    notifyListeners();

    // Submit chat history
    final List<Chat> submitChat = List.from(displayChat);
    await distilPersona(submitChat);

    // Reinitialize chat history
    loadingMessage = 'Loading new chat...';
    await initialise();
    newProfileStatus = true;
    submitting = false;
    notifyListeners();
  }

  Future<void> onContinueChat() async {
    logUserEvent('continue_chat');
    // Add continue message
    final Chat userMsg = Chat.sent(
      message: "Actually, I want to continue chatting.",
      displayToUser: false,
    );
    chatList.add(userMsg);
    // Get response from AI
    loadingReply = true;
    notifyListeners();
    getChatResponse(chatList, false).then((response) {
      final Chat receivedChat = Chat.received(
        message: response.message,
        conversationEnded: response.conversationEnded,
      );
      chatList.add(receivedChat);
      loadingReply = false;
      notifyListeners();
    });
  }
}
