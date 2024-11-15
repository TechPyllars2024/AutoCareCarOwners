import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageId;
  String conversationId;
  String messageText;
  DateTime timestamp;
  bool isRead;
  String messageType;
  String senderId;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
    this.messageType = 'text',
    required this.senderId,
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
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      messageId: id,
      conversationId: data['conversationId'] ?? '',
      messageText: data['messageText'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      isRead: data['isRead'] ?? false,
    );
  }

  MessageModel copyWith({String? messageId}) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId,
      messageText: messageText,
      timestamp: timestamp,
      isRead: isRead,
      messageType: messageType,
      senderId: senderId,
    );
  }
}
