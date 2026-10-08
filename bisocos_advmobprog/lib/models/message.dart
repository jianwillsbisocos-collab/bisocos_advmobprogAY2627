import 'package:cloud_firestore/cloud_firestore.dart';

/// Message status enum for tracking delivery and read status
enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sending,
  });

  /// Convert Message to Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
    };
  }

  /// Create Message from Firestore document
  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(map['status'] as String?),
    );
  }

  /// Parse status string to enum
  static MessageStatus _parseStatus(String? statusStr) {
    return MessageStatus.values.firstWhere(
      (status) => status.name == statusStr,
      orElse: () => MessageStatus.sending,
    );
  }

  /// Create a copy of Message with modified fields
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'Message(id: $id, senderId: $senderId, receiverId: $receiverId, text: $text, timestamp: $timestamp, status: ${status.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          senderId == other.senderId &&
          receiverId == other.receiverId &&
          text == other.text &&
          timestamp == other.timestamp &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      text.hashCode ^
      timestamp.hashCode ^
      status.hashCode;
}
