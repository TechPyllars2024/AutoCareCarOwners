import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageDetailScreen extends StatefulWidget {
  final String chatId;

  const MessageDetailScreen({super.key, required this.chatId});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with chat image
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Chat', // Replace with actual chat name
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
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
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isSentByMe = messageData['senderId'] == _auth.currentUser!.uid;

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
                          crossAxisAlignment: isSentByMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData['message'],
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              (messageData['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString(),
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      var currentUser = _auth.currentUser;
      var timestamp = Timestamp.now();

      // Save the message to Firestore
      _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
        'senderId': currentUser!.uid,
        'message': text,
        'timestamp': timestamp,
      });

      // Update the last message and timestamp in the chat document
      _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'lastUpdated': timestamp,
      });

      _controller.clear();
    }
  }
}
