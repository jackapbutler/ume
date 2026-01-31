import 'package:flutter/material.dart';
import 'package:app/chat/state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Stack(
          children: [
            TextField(
              focusNode: context.read<ChatState>().focusNode,
              onChanged: context.read<ChatState>().onFieldChanged,
              controller: context.read<ChatState>().textEditingController,
              maxLines: null,
              minLines: 1,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16.0),
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            // custom suffix btn
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/send.svg",
                  colorFilter: ColorFilter.mode(
                    context.select<ChatState, bool>(
                            (value) => value.isTextFieldEnable)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondaryContainer,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: context.read<ChatState>().onMessageSent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
