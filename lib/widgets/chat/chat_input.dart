import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachmentPressed;
  final VoidCallback? onMicPressed;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendPressed,
    required this.onAttachmentPressed,
    this.onMicPressed,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6EB715), // Green background like in image
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Plus button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: widget.onAttachmentPressed,
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFF6EB715),
                  size: 24,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => widget.onSendPressed(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Microphone button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: widget.onMicPressed ?? () {
                  // Default microphone action
                  print('Microphone button pressed');
                },
                icon: const Icon(
                  Icons.mic,
                  color: Color(0xFF6EB715),
                  size: 24,
                ),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}