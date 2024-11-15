import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../models/message_model.dart';
import '../models/startConversation.dart';
import '../services/chat_service.dart';
import '../widgets/messageBubble.dart';

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
  final Logger logger = Logger();

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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final message = MessageModel(
        messageId: '',
        conversationId: widget.conversationId,
        messageText: _messageController.text.trim(),
        timestamp: DateTime.now(),
        isRead: false,
        senderId: _senderId,
      );
      _chatService.sendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(color: Colors.white),
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
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              );
            } else {
              return const Text('No provider data found');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Handle call action
            },
          ),
        ],
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

                if (snapshot.hasError) {
                  print('Error fetching messages: ${snapshot.error}');
                  return const Center(child: Text('Error loading messages.'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print('No messages found.');
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;
                print('Messages fetched: ${messages.length}');
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(message: message, isMe: message.senderId == _senderId);
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
