import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/startConversation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createConversation(StartConversationModel conversation) async {
    await _firestore
        .collection('conversations')
        .doc(conversation.conversationId)
        .set(conversation.toMap());
  }

  Future<String> generateConversationId() async {
    return _firestore.collection('conversations').doc().id;
  }

  Future<StartConversationModel?> getExistingConversation(String senderId, String receiverId) async {
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return StartConversationModel.fromMap(querySnapshot.docs.first.data());
    }

    return null;
  }

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    try {
      final messageId = _firestore.collection('conversations').doc().id; // Generate unique ID for the message
      message.messageId = messageId;

      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Update the last message in the conversation document
      await _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .update({
        'lastMessage': message.messageText,
        'lastMessageTime': message.timestamp,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
      final numberOfMessages = messages.length;

      // Update the message count in the database
      _updateMessageCount(conversationId, numberOfMessages);

      return messages;
    });
  }

  Future<void> _updateMessageCount(String conversationId, int count) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'numberOfMessages': count});
    } catch (e) {
      print('Error updating message count: $e');
    }
  }

  Future<StartConversationModel> fetchStartConversationById(String conversationId) async {
    // Replace with your actual data fetching logic
    final startConversationData = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .get();

    if (startConversationData.exists) {
      return StartConversationModel.fromMap(startConversationData.data()!);
    } else {
      throw Exception('Conversation not found');
    }
  }

  // Fetch shop details by UID
  Future<Map<String, dynamic>> fetchProviderByUid(String uid) async {
    try {
      DocumentSnapshot providerSnapshot = await _firestore
          .collection('automotiveShops_profile')
          .doc(uid)
          .get();

      if (providerSnapshot.exists) {
        return providerSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching provider by UID $uid: $e');
      return {};
    }
  }
}
