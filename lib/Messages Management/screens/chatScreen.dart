import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../models/startConversation_model.dart';
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
  File? _pickedImage;
  String? _conversationId;
  String _currentUserId = '';
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _providerData = ChatService().fetchProviderByUid(widget.serviceProviderUid);
    _conversationData = _chatService.fetchStartConversationById(widget.conversationId);
    _initializeConversation();
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

  Future<void> _initializeConversation() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
    }

    if (widget.conversationId != null) {
      setState(() {
        _conversationId = widget.conversationId;
      });
    } else {
      final conversationId = await _chatService.initializeConversation(_currentUserId, widget.serviceProviderUid);
      setState(() {
        _conversationId = conversationId;
      });
    }
  }

  Future<void> _sendMessage({File? imageFile}) async {
    if (_messageController.text.trim().isNotEmpty || imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      final message = MessageModel(
        messageId: '',
        conversationId: widget.conversationId,
        messageText: _messageController.text.trim(),
        timestamp: DateTime.now(),
        senderId: _senderId,
      );
      await _chatService.sendMessage(message, imageFile: imageFile);
      _messageController.clear();
      setState(() {
        _pickedImage = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
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
                  return const Center(child: Text('Error loading messages.'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Welcome!\nWe're ready to assist with\nwhatever your car needs.",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 20, color: Colors.black)));
                }

                final messages = snapshot.data!;
                final allImageUrls = messages
                    .where((message) => message.imageUrl != null && message.imageUrl!.isNotEmpty)
                    .map((message) => message.imageUrl!)
                    .toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final previousMessage = index < messages.length - 1 ? messages[index + 1] : null;
                    final isNewDay = previousMessage == null || !isSameDay(message.timestamp, previousMessage.timestamp);

                    return Column(
                      children: [
                        if (isNewDay)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              DateFormat('MMMM d, yyyy').format(message.timestamp),
                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ),
                        MessageBubble(message: message, isMe: message.senderId == _senderId, allImageUrls: allImageUrls),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_pickedImage != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image Container
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.file(
                      _pickedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Loading Overlay
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  // Close Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.all(8.0), // Adjust for padding inside the container
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade900,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _pickedImage = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image, color: Colors.orange.shade900),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.orange.shade900),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.orange.shade900),
                        onPressed: () {
                          if (_pickedImage != null || _messageController.text.trim().isNotEmpty) {
                            _sendMessage(imageFile: _pickedImage); // Send message or image
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
