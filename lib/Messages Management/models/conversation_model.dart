class ConversationModel {
  final String conversationId; // Unique ID for the conversation
  final String shopName; // Name of the shop
  final String shopProfilePhoto; // URL of the shop's profile photo
  final List<String> participants; // List of user IDs involved in the conversation
  final String lastMessage; // Last message sent in the conversation
  final DateTime lastMessageTime; // Timestamp of the last message
  final String lastMessageSender; // User ID of the sender of the last message
  final Map<String, int> unreadCount; // Unread message count per user

  ConversationModel({
    required this.conversationId,
    required this.shopName,
    required this.shopProfilePhoto,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSender,
    required this.unreadCount,
  });

  // Convert ConversationModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'shopName': shopName,
      'shopProfilePhoto': shopProfilePhoto,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageSender': lastMessageSender,
      'unreadCount': unreadCount,
    };
  }

  // Create ConversationModel from a Firestore document
  factory ConversationModel.fromMap(Map<String, dynamic> doc, String id) {
    return ConversationModel(
      conversationId: id,
      shopName: doc['shopName'] ?? '',
      shopProfilePhoto: doc['shopProfilePhoto'] ?? '',
      participants: List<String>.from(doc['participants'] ?? []),
      lastMessage: doc['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(doc['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      lastMessageSender: doc['lastMessageSender'] ?? '',
      unreadCount: Map<String, int>.from(doc['unreadCount'] ?? {}),
    );
  }
}
