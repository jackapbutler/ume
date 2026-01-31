import 'package:app/chat/completeness.dart';
import 'package:app/chat/loading.dart';
import 'package:app/chat/message.dart';
import 'package:app/chat/state.dart';
import 'package:app/chat/action.dart';
import 'package:app/chat/bubble.dart';
import 'package:app/utils/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:app/chat/input.dart';

Map<String, String> suggestedMessages = {
  "Let's improve my profile":
      "I want to be asked more questions so that I can make my profile more more accurate, focus on any missing aspects.",
  "Advice on my matches":
      "I need advice on progressing my conversations and next steps with current matches. Ask me the current situation first and go from there.",
  "Plan a great date":
      "I want ideas for a fun date based on my match's interests. Ask who I am interested in first, out of the current matches.",
};

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatState chatState = context.watch<ChatState>();

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (!chatState.loadingPersona) {
                    chatState.newProfileStatus = false;
                    logUserEvent('view_profile_completeness');
                    chatState.markAsChanged();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CompletenessScores(
                          themes:
                              chatState.currentPersona.profileCategoryScores,
                          title: "Profile Completeness",
                        );
                      },
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Center(
                    child: chatState.loadingPersona
                        ? SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: CircularProgressIndicator(),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Profile Completeness',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (chatState.newProfileStatus)
                                Icon(Icons.auto_awesome, size: 20)
                                    .animate(
                                      onPlay: (controller) => controller.repeat(
                                        period: Duration(milliseconds: 1500),
                                      ),
                                    )
                                    .scale()
                                    .then() // Add reverse scale
                                    .scale(
                                      begin: Offset(1, 1),
                                      end: Offset(0, 0),
                                    ),
                            ],
                          ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    chatState.focusNode.unfocus();
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      logUserEvent('refresh_chat');
                      await chatState.initialise();
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Selector<ChatState, List<Chat>>(
                        selector: (context, controller) =>
                            controller.displayChat.reversed.toList(),
                        builder: (context, displayChat, child) {
                          final isLoading = context.select<ChatState, bool>(
                            (state) => state.loadingReply,
                          );
                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            padding:
                                const EdgeInsets.only(top: 12, bottom: 20) +
                                    const EdgeInsets.symmetric(horizontal: 12),
                            separatorBuilder: (_, __) => const SizedBox(
                              height: 12,
                            ),
                            controller: chatState.scrollController,
                            itemCount: displayChat.length + (isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Show loading dots at the top when starting up
                              if (index ==
                                  displayChat.length + (isLoading ? 1 : 0)) {
                                return const LoadingDots();
                              }

                              // Show loading dots for reply at the end
                              if (isLoading && index == 0) {
                                return const LoadingDots();
                              }

                              // Regular chat bubbles
                              return Bubble(
                                chat: displayChat[index - (isLoading ? 1 : 0)],
                                suggestedReplies: chatState.isUserFirstMessage
                                    ? suggestedMessages.keys.toList()
                                    : [],
                                onPressedReply: (String reply) {
                                  chatState.textEditingController.text =
                                      suggestedMessages[reply]!;
                                  chatState.chatList.add(
                                    Chat.sent(
                                      message: reply,
                                      displayToAi: false,
                                    ),
                                  );
                                  chatState.onMessageSent(false);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (!chatState.submitting) ...[
                if (chatState.submittableChat()) ...[
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ChatActionButtons(
                        onSubmit: () => chatState.submitChatHistory(context),
                        onContinue: () => chatState.onContinueChat(),
                      ).animate().slideY(duration: 500.ms),
                    ),
                  ),
                  const SizedBox(height: 4)
                ] else ...[
                  const ChatInputField(),
                ],
              ],
            ],
          ),
        ),
        LoadingOverlay(
          isLoading: chatState.submitting,
          message: chatState.loadingMessage,
        ),
      ],
    );
  }
}
