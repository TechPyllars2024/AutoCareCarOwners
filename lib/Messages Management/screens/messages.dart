import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../services/chat_service.dart';
import '../models/startConversation_model.dart';
import 'chatScreen.dart';

class CarOwnerMessagesScreen extends StatefulWidget {
  const CarOwnerMessagesScreen({super.key, this.child});
  final Widget? child;

  @override
  State<CarOwnerMessagesScreen> createState() => _CarOwnerMessagesScreenState();
}

class _CarOwnerMessagesScreenState extends State<CarOwnerMessagesScreen> {
  final ChatService _chatService = ChatService();
  String? _currentUserId;
  final Logger logger = Logger();

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

  Stream<DocumentSnapshot> _listenToShopDetails(String senderId, String receiverId, String currentUserId) {
    // Determine which ID represents the shop
    String shopId = senderId == currentUserId ? receiverId : senderId;

    // Listen to shop details based on the identified shopId
    return FirebaseFirestore.instance
        .collection('automotiveShops_profile')
        .doc(shopId)
        .snapshots();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
      body: _currentUserId!.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
          : StreamBuilder<List<StartConversationModel>>(
              stream: _chatService.getUserConversations(_currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange)));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages.'));
                }
                final conversations = snapshot.data!
                    .where(
                        (conversation) => conversation.lastMessage.isNotEmpty)
                    .toList();
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No conversations yet.'));
                }
                conversations.sort(
                    (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final isRead = conversation.isRead;
                    return StreamBuilder<DocumentSnapshot>(
                      stream: _listenToShopDetails(conversation.receiverId, conversation.senderId, _currentUserId!),
                      builder: (context, shopSnapshot) {
                        if (shopSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(conversation.shopName),
                            subtitle: Text(conversation.lastMessage),
                          );
                        }
                        if (shopSnapshot.hasError) {
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(conversation.shopName),
                            subtitle: Text(conversation.lastMessage),
                          );
                        }
                        if (shopSnapshot.hasData) {
                          var shopData =
                              shopSnapshot.data!.data() as Map<String, dynamic>;
                          String updatedShopName =
                              shopData['shopName'] ?? conversation.shopName;
                          String updatedShopProfile =
                              shopData['profileImage'] ??
                                  conversation.shopProfilePhoto;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: updatedShopProfile.isNotEmpty
                                  ? NetworkImage(updatedShopProfile)
                                  : null,
                              child: updatedShopProfile.isEmpty
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              updatedShopName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              DateFormat.jm()
                                  .format(conversation.lastMessageTime),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                            onTap: () async {
                              await _chatService.markConversationAsRead(
                                  conversation.conversationId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    serviceProviderUid: conversation.senderId == _currentUserId
                                        ? conversation.receiverId
                                        : conversation.senderId,
                                    conversationId: conversation.conversationId,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return const Center(
                            child: Text('No shop details found.'));
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
