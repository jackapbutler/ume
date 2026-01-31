import 'package:app/chat/message.dart';
import 'package:app/chat/role.dart';
import 'package:app/chat/state.dart';
import 'package:app/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:provider/provider.dart';

class Bubble extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final Chat chat;
  final List<String>? suggestedReplies;
  final void Function(String)? onPressedReply;

  Bubble({
    super.key,
    this.margin,
    required this.chat,
    this.suggestedReplies,
    void Function(String)? onPressedReply,
  }) : onPressedReply = onPressedReply ?? ((String reply) {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlignmentOnType,
      children: [
        Row(
          mainAxisAlignment: alignmentOnType,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display avatar for assistant
            if (chat.role == ChatRole.assistant)
              CircleAvatar(
                backgroundImage:
                    AssetImage(context.read<ChatState>().chatImageAsset),
              ),
            // Chat bubble container
            Container(
              margin: margin ?? EdgeInsets.zero,
              child: PhysicalShape(
                clipper: clipperOnType,
                elevation: 3, // Increased shadow for depth
                color: chat.role == ChatRole.assistant
                    ? Color(0xFFE7E7ED)
                    : Theme.of(context).colorScheme.primary,
                shadowColor:
                    Theme.of(context).colorScheme.secondary, // Softer shadow
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: paddingOnType,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                    gradient: chat.role == ChatRole.assistant
                        ? LinearGradient(
                            colors: [Color(0xFFE7E7ED), Color(0xFFE0E0E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ), // Adding gradient background
                  ),
                  child: Column(
                    crossAxisAlignment: crossAlignmentOnType,
                    children: [
                      // Main content (chat message)
                      Text(
                        chat.content,
                        style: TextStyle(
                          color: textColorOnType,
                          fontSize: 14, // Larger font size for readability
                          fontWeight: FontWeight.w400, // Soft, readable text
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      // Date/time below the message
                      Text(
                        Formatter.formatDateTime(chat.time),
                        style: TextStyle(
                          color: textColorOnType.withAlpha(150), // Lighter text
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (suggestedReplies != null && suggestedReplies!.isNotEmpty)
          Align(
            alignment: chat.role == ChatRole.user
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: suggestedReplies!
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => onPressedReply!.call(reply),
                            child: Text(reply),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  // Determine the text color based on the role
  Color get textColorOnType {
    switch (chat.role) {
      case ChatRole.user:
        return Colors.white;
      case ChatRole.assistant:
        return const Color(0xFF333333); // Darker gray for assistant text
    }
  }

  // Custom clipper based on role
  CustomClipper<Path> get clipperOnType {
    switch (chat.role) {
      case ChatRole.user:
        return ChatBubbleClipper1(type: BubbleType.sendBubble);
      case ChatRole.assistant:
        return ChatBubbleClipper1(type: BubbleType.receiverBubble);
    }
  }

  // Cross alignment based on role
  CrossAxisAlignment get crossAlignmentOnType {
    switch (chat.role) {
      case ChatRole.user:
        return CrossAxisAlignment.end;
      case ChatRole.assistant:
        return CrossAxisAlignment.start;
    }
  }

  // Main alignment based on role
  MainAxisAlignment get alignmentOnType {
    switch (chat.role) {
      case ChatRole.assistant:
        return MainAxisAlignment.start;
      case ChatRole.user:
        return MainAxisAlignment.end;
    }
  }

  // Padding based on role
  EdgeInsets get paddingOnType {
    switch (chat.role) {
      case ChatRole.user:
        return const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 24);
      case ChatRole.assistant:
        return const EdgeInsets.only(top: 10, bottom: 10, left: 24, right: 14);
    }
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _dotCount = StepTween(begin: 3, end: 6).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(context.read<ChatState>().chatImageAsset),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE7E7ED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedBuilder(
            animation: _dotCount,
            builder: (context, child) {
              String dots = '.' * (_dotCount.value % 4);
              return Text(
                dots,
                style: const TextStyle(color: Color(0xFF333333)),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
