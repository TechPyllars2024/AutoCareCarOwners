import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';
import '../models/startConversation.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String serviceProviderUid;
  final String conversationId;

  const ChatScreen({super.key, this.child, required this.serviceProviderUid, required this.conversationId});

  final Widget? child;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  late Future<Map<String, dynamic>> _providerData;
  late Future<StartConversationModel> _conversationData;
  String _senderId = '';
  String _shopName = 'Loading...';
  String _shopProfilePhoto = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _providerData = ChatService().fetchProviderByUid(widget.serviceProviderUid);
    _conversationData = _chatService.fetchStartConversationById(widget.conversationId);
  }

  // Fetch the current user's UID (senderId)
  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _senderId = user.uid;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = MessageModel(
        messageId: '',
        conversationId: widget.conversationId,
        messageText: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isRead: false,
      );
      _chatService.sendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _providerData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error loading provider');
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              _shopName = data['shopName'] ?? 'Unknown Shop';
              _shopProfilePhoto = data['profileImage'] ?? '';

              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _shopProfilePhoto.isNotEmpty
                        ? NetworkImage(_shopProfilePhoto)
                        : null,
                    child: _shopProfilePhoto.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _shopName,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              );
            } else {
              return const Text('No provider data found');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.messageId == _senderId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.messageText,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
