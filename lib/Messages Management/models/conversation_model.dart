class ConversationModel {
  String conversationId;
  String shopName;
  String shopProfilePhoto;
  String lastMessage;
  DateTime lastMessageTime;
  Map<String, int> unreadCount;
  String senderUid;
  String receiverUid;
  int numberOfMessages;

  ConversationModel({
    required this.conversationId,
    required this.shopName,
    required this.shopProfilePhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.senderUid,
    required this.receiverUid,
    required this.numberOfMessages,
  });

  // Convert ConversationModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'shopName': shopName,
      'shopProfilePhoto': shopProfilePhoto,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'numberOfMessages': numberOfMessages,
    };
  }

  // Create ConversationModel from a Firestore document
  factory ConversationModel.fromMap(Map<String, dynamic> doc, String id) {
    return ConversationModel(
      conversationId: id,
      shopName: doc['shopName'] ?? '',
      shopProfilePhoto: doc['shopProfilePhoto'] ?? '',
      lastMessage: doc['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(doc['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      unreadCount: Map<String, int>.from(doc['unreadCount'] ?? {}),
      senderUid: doc['senderUid'] ?? '',
      receiverUid: doc['receiverUid'] ?? '',
      numberOfMessages: doc['numberOfMessages'] ?? 0,
    );
  }
}
