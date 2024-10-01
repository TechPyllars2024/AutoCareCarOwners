import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatServices.dart';

class CarOwnerMessagesScreen extends StatefulWidget {
  const CarOwnerMessagesScreen({super.key});

  @override
  _CarOwnerMessagesScreenState createState() => _CarOwnerMessagesScreenState();
}

class _CarOwnerMessagesScreenState extends State<CarOwnerMessagesScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser!; // Get current logged-in user
  }

  // Stream to fetch the list of registered users from Firestore
  Stream<QuerySnapshot> getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  // Create or get a chat room ID between the current user and the selected user
  String getChatRoomId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1\_$userId2'
        : '$userId2\_$userId1'; // Ensures a consistent chat room ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsersStream(), // Fetch registered users from Firestore
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              String userId = users[index].id;
              String userName = user['name'] ?? 'Unknown';
              String userImage = user['imageUrl'] ??
                  'https://via.placeholder.com/150'; // Default image if null

              // Don't show the current user in the list
              if (userId == currentUser.uid) {
                return Container(); // Skip displaying the current user
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                  radius: 30,
                ),
                title: Text(
                  userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: Text(
                  'Tap to chat',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {
                  // Generate or fetch the chat room between the current user and this user
                  String chatRoomId = getChatRoomId(currentUser.uid, userId);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRoomId,
                        userName: userName,
                        userImage: userImage,
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

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String userImage;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.userName,
    required this.userImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser!; // Get the current user
  }

  // Send a message to Firestore
  void _sendMessage(String messageText) {
    if (messageText.isNotEmpty) {
      _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
    ),
    title: Row(
    children: [
    CircleAvatar(
    backgroundImage: NetworkImage(widget.userImage),
    radius: 20,
    ),
    const SizedBox(width: 10),
    Text(
    widget.userName,
    style: const TextStyle(
    color: Colors.black, fontWeight: FontWeight.bold),
    ),
    ],
    ),
    ),
    body: Column(
    children: [
    // StreamBuilder to show messages from Firestore for the current chat room
    Expanded(
    child: StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
    }
    var messages = snapshot.data!.docs;
    return ListView.builder(
    reverse: true,
    itemCount: messages.length,
    itemBuilder: (context, index) {
    var chat = messages[index].data() as Map<String, dynamic>;
    bool isSentByMe = chat['senderId'] == currentUser.uid;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              chat['message'],
              style: TextStyle(
                color: isSentByMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              chat['timestamp'] != null
                  ? (chat['timestamp'] as Timestamp)
                  .toDate()
                  .toLocal()
                  .toString()
                  : 'Sending...',
              style: TextStyle(
                fontSize: 10,
                color: isSentByMe ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
    },
    );
    },
    ),
    ),
      // Chat input area
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blueAccent),
              onPressed: () {
                _sendMessage(_controller.text.trim());
              },
            ),
          ],
        ),
      ),
    ],
    ),
    );
  }
}

