import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';
import '../models/user_model.dart';

/// Chat Service handles all Firestore operations for chat functionality
/// Manages users, conversations, and messages with real-time updates
class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> enableNetwork() => _firestore.enableNetwork();

  String _stringValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value.trim() : '';
  }

  UserModel _userFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final name = _stringValue(data, 'name');
    final displayName = _stringValue(data, 'displayName');
    final storedFirstName = _stringValue(data, 'firstName');
    final storedLastName = _stringValue(data, 'lastName');
    final fullName = name.isNotEmpty
        ? name
        : displayName.isNotEmpty
        ? displayName
        : '$storedFirstName $storedLastName'.trim();
    final nameParts = fullName.isEmpty
        ? const <String>[]
        : fullName.split(RegExp(r'\s+'));
    final firstName = storedFirstName.isNotEmpty
        ? storedFirstName
        : nameParts.firstOrNull ?? '';
    final lastName = storedLastName.isNotEmpty
        ? storedLastName
        : nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';

    return UserModel.fromMap({
      ...data,
      'uid': document.id,
      'firstName': firstName,
      'lastName': lastName,
      'username': _stringValue(data, 'username').isNotEmpty
          ? _stringValue(data, 'username')
          : displayName,
      'email': _stringValue(data, 'email'),
    });
  }

  Stream<List<UserModel>> _watchUsers({String query = ''}) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value(const <UserModel>[]);
    }

    final normalizedQuery = query.trim().toLowerCase();
    return _firestore.collection('users').snapshots().map((snapshot) {
      final users =
          snapshot.docs
              .where((document) => document.id != userId)
              .map(_userFromDocument)
              .where((user) {
                if (normalizedQuery.isEmpty) return true;
                final fullName = '${user.firstName} ${user.lastName}'.trim();
                return fullName.toLowerCase().contains(normalizedQuery) ||
                    user.username.toLowerCase().contains(normalizedQuery) ||
                    user.email.toLowerCase().contains(normalizedQuery);
              })
              .toList()
            ..sort((a, b) {
              final nameA = '${a.firstName} ${a.lastName}'.trim().toLowerCase();
              final nameB = '${b.firstName} ${b.lastName}'.trim().toLowerCase();
              return nameA.compareTo(nameB);
            });
      return users;
    });
  }

  /// Get all users except the current user
  /// Real-time stream of users for the chat list
  Stream<List<UserModel>> getAllUsers() => _watchUsers();

  /// Search users by name, username, or email
  /// Returns a stream of filtered users
  Stream<List<UserModel>> searchUsers(String query) =>
      _watchUsers(query: query);

  /// Get or create a conversation ID between two users
  /// Ensures unique and consistent conversation IDs
  String _generateConversationId(String userId1, String userId2) {
    // Prevent self-chat by checking if both users are the same
    if (userId1 == userId2) {
      throw Exception('Cannot create a conversation with yourself');
    }

    // Create consistent ID regardless of parameter order
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get or create conversation between two users
  Future<String> getOrCreateConversation(String otherUserId) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    // Prevent self-chat
    if (currentUserId == otherUserId) {
      throw Exception('Cannot start a chat with yourself');
    }

    final conversationId = _generateConversationId(currentUserId!, otherUserId);

    final conversationDoc = _firestore
        .collection('conversations')
        .doc(conversationId);

    final docSnapshot = await conversationDoc.get();

    if (!docSnapshot.exists) {
      // Create new conversation
      await conversationDoc.set({
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
      });
    }

    return conversationId;
  }

  /// Send a message in a conversation
  Future<void> sendMessage(
    String conversationId,
    String receiverId,
    String text,
  ) async {
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    if (text.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final messagesRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');

    final message = Message(
      id: '',
      senderId: currentUserId!,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    try {
      // Add message to subcollection
      final docRef = await messagesRef.add(message.toMap());

      // Update message with sent status
      await docRef.update({'status': MessageStatus.sent.name});

      // Update conversation last message
      await _firestore.collection('conversations').doc(conversationId).set({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': currentUserId,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get messages for a conversation as a stream
  /// Messages are ordered by timestamp, most recent first
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Mark a message as delivered
  Future<void> markMessageAsDelivered(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'status': MessageStatus.delivered.name});
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  /// Mark a message as seen
  Future<void> markMessageAsSeen(
    String conversationId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({'status': MessageStatus.seen.name});
    } catch (e) {
      throw Exception('Failed to update message status: $e');
    }
  }

  /// Mark all messages in a conversation as seen (for current user)
  /// This updates only the messages received by the current user
  Future<void> markConversationAsSeen(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw StateError('User must be authenticated');
    }

    try {
      final messagesRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages');

      // Filter statuses locally to avoid requiring a composite Firestore index.
      final query = await messagesRef
          .where('receiverId', isEqualTo: userId)
          .get();
      final unseenMessages = query.docs
          .where((doc) => doc.data()['status'] != MessageStatus.seen.name)
          .toList();

      for (var start = 0; start < unseenMessages.length; start += 500) {
        final batch = _firestore.batch();
        final end = (start + 500).clamp(0, unseenMessages.length);
        for (final doc in unseenMessages.sublist(start, end)) {
          batch.update(doc.reference, {'status': MessageStatus.seen.name});
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to mark conversation as seen: $e');
    }
  }

  /// Get conversation reference for a user
  /// Returns list of conversations where current user is participant
  Stream<List<Map<String, dynamic>>> getUserConversations() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList(),
        );
  }

  /// Delete a conversation (optional feature)
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages first
      final messagesRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages');

      final messages = await messagesRef.get();

      final batch = _firestore.batch();

      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      batch.delete(_firestore.collection('conversations').doc(conversationId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  /// Get single user details
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data() ?? <String, dynamic>{};
      return UserModel.fromMap({'uid': doc.id, ...data});
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }
}
