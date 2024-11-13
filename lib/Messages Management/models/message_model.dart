class MessageModel {
  final String messageId; // Unique ID for the message
  final String conversationId; // ID of the conversation this message belongs to
  final String shopName; // Name of the shop
  final String shopProfilePhoto; // URL of the shop's profile photo
  final String senderId; // ID of the sender
  final String receiverId; // ID of the receiver
  final String messageText; // Content of the message
  final DateTime timestamp; // When the message was sent
  final bool isRead; // Whether the message has been read

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.shopName,
    required this.shopProfilePhoto,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
  });

  // Convert MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'shopName': shopName,
      'shopProfilePhoto': shopProfilePhoto,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Create MessageModel from a Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> doc, String id) {
    return MessageModel(
      messageId: id,
      conversationId: doc['conversationId'] ?? '',
      shopName: doc['shopName'] ?? '',
      shopProfilePhoto: doc['shopProfilePhoto'] ?? '',
      senderId: doc['senderId'] ?? '',
      receiverId: doc['receiverId'] ?? '',
      messageText: doc['messageText'] ?? '',
      timestamp: DateTime.parse(doc['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: doc['isRead'] ?? false,
    );
  }
}
