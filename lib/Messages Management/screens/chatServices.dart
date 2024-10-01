import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a message
  Future<void> sendMessage(String chatRoomId, String messageText) async {
    if (messageText.isNotEmpty) {
      final currentUser = _auth.currentUser;
      final messageData = {
        'senderId': currentUser?.uid,
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'isSentByMe': true,
      };

      // Add message to Firestore under the chatRoomId
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
    }
  }

  // Method to get the message stream for a chat room
  Stream<QuerySnapshot> getMessageStream(String chatRoomId) {
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
