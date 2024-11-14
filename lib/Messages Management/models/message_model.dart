import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String messageId;
  String conversationId;
  String messageText;
  DateTime timestamp;
  bool isRead;
  String messageType;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
    this.messageType = 'text',
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
    };
  }

  // Create MessageModel from a Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map, String messageId) {
    return MessageModel(
      messageId: messageId,
      conversationId: map['conversationId'],
      messageText: map['messageText'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'],
      messageType: map['messageType'],
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
    );
  }
}
