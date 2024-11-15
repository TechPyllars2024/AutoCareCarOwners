import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({required this.message, required this.isMe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: isMe ? const Offset(-10, 0) : const Offset(10, 0), // Adjust the offset as needed
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.orange.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message.messageText,
            style: TextStyle(color: isMe ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}