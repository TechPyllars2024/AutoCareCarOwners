import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageId;
  String conversationId;
  String messageText;
  DateTime timestamp;
  bool isRead;
  String messageType;
  String senderId;
  String? imageUrl;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
    this.messageType = 'text',
    required this.senderId,
    this.imageUrl,
  });

  // Convert MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'messageType': messageType,
      'senderId': senderId,
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      messageId: id,
      conversationId: data['conversationId'] ?? '',
      messageText: data['messageText'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      isRead: data['isRead'] ?? false,
      messageType: data['messageType'] ?? 'text',
      senderId: data['senderId'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  MessageModel copyWith({String? messageId, String? imageUrl, String? messageType}) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId,
      messageText: messageText,
      timestamp: timestamp,
      isRead: isRead,
      messageType: messageType ?? this.messageType,
      senderId: senderId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
