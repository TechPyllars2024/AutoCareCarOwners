import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/chat_service.dart';
import '../models/startConversation.dart';
import 'chatScreen.dart';

class CarOwnerMessagesScreen extends StatefulWidget {
  const CarOwnerMessagesScreen({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerMessagesScreen> createState() => _CarOwnerMessagesScreenState();
}

class _CarOwnerMessagesScreenState extends State<CarOwnerMessagesScreen> {
  final ChatService _chatService = ChatService();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      body: _currentUserId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<StartConversationModel>>(
        stream: _chatService.getUserConversations(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading messages.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }
          final conversations = snapshot.data!;
          conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final isRead = conversation.isRead; // Assuming `isRead` is a boolean property in your model
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: conversation.shopProfilePhoto.isNotEmpty
                      ? NetworkImage(conversation.shopProfilePhoto)
                      : null,
                  child: conversation.shopProfilePhoto.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  conversation.shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  DateFormat.jm().format(conversation.lastMessageTime),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                onTap: () async {
                  await _chatService.markConversationAsRead(conversation.conversationId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        serviceProviderUid: conversation.receiverId,
                        conversationId: conversation.conversationId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
