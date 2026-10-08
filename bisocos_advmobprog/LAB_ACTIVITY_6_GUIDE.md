## Lab Activity 6: Firebase Firestore Chat App - Implementation Guide

### Quick Start Setup

This guide will help you integrate the new chat functionality into your existing Flutter Firebase app.

---

## Step 1: Verify Dependencies

Ensure your `pubspec.yaml` has these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.0
  flutter_dotenv: ^5.1.0
  flutter_svg: ^2.0.0
  shared_preferences: ^2.5.3
  firebase_core: ^4.15.0
  firebase_auth: ^6.7.0
  cloud_firestore: ^6.10.0
```

Run: `flutter pub get`

---

## Step 2: Firestore Security Rules Update

1. Go to Firebase Console → Your Project → Firestore Database → Rules
2. Replace the rules with the updated `firestore.rules` provided in the project
3. Publish the rules

These rules ensure:
- ✅ Users can read all user profiles (for the chat list)
- ✅ Users can only write their own profile
- ✅ Only conversation participants can access conversations and messages
- ✅ Only participants can create/read/update messages

---

## Step 3: Firestore Collections Structure

Create the following collections in your Firestore database:

### Collection 1: `users`

**Document Path**: `users/{userId}`

**Document Fields**:
```
{
  "uid": "user123",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "username": "johndoe",
  "age": 25,
  "contactNumber": "+1234567890",
  "photoUrl": "https://..." (optional)
}
```

### Collection 2: `conversations`

**Document Path**: `conversations/{conversationId}`

**Naming Convention**: `{userId1}_{userId2}` (sorted lexicographically)

Example: If User A (uid: "aaa") chats with User B (uid: "zzz"), the conversation ID is `aaa_zzz`

**Document Fields**:
```
{
  "participants": ["userId1", "userId2"],
  "createdAt": Timestamp (server time),
  "lastMessage": "Hello there!",
  "lastMessageTime": Timestamp (server time),
  "lastMessageSender": "userId1"
}
```

### Subcollection: `conversations/{conversationId}/messages`

**Document Path**: `conversations/{conversationId}/messages/{messageId}`

**Document Fields**:
```
{
  "senderId": "userId1",
  "receiverId": "userId2",
  "text": "Hello, how are you?",
  "timestamp": Timestamp (server time),
  "status": "sent"  // Options: "sending", "sent", "delivered", "seen"
}
```

---

## Step 4: File Integration

The following files have been created:

### Models
- **`lib/models/message.dart`** - Message model with status tracking

### Services
- **`lib/services/chat_service.dart`** - All Firestore operations for chat

### Screens
- **`lib/screens/chat_screen.dart`** - Users list with real-time search
- **`lib/screens/chat_detailscreen.dart`** - Chat messaging interface

### Updated Files
- **`lib/main.dart`** - Added ChatService provider

---

## Step 5: Integration into Your App

### Adding Chat to Navigation

Update your profile screen or navigation to include the chat screen:

```dart
import 'package:your_app/screens/chat_screen.dart';

// In your navigation menu:
FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  },
  child: const Icon(Icons.chat),
)

// Or in your menu:
ListTile(
  leading: const Icon(Icons.chat),
  title: const Text('Messages'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  },
)
```

### Verify Provider Setup

Check that `lib/main.dart` includes:

```dart
import 'services/chat_service.dart';

// In MultiProvider:
Provider(create: (_) => ChatService()),
```

---

## Step 6: Testing the Features

### Test 1: User List
1. Login with a test user
2. Navigate to Chat Screen
3. Verify all other users appear (excluding yourself)

### Test 2: Search
1. In Chat Screen, type in the search bar
2. Test searching by: name, username, email
3. Results should filter in real-time

### Test 3: Start Conversation
1. Tap on a user
2. The conversation screen should open
3. Should not be able to chat with yourself (error handled)

### Test 4: Send Message
1. Type a message in the text field
2. Tap send button
3. Message appears with status icons:
   - 🕐 = sending
   - ✓ = sent
   - ✓✓ = delivered
   - ✓✓ (colored) = seen

### Test 5: Real-Time Updates
1. Open chat on two devices with different users
2. Send message from Device A
3. Message appears instantly on Device B

### Test 6: Auto-Scroll
1. Open a conversation with many messages
2. Send a new message
3. Should auto-scroll to the latest message

---

## Step 7: Database Indexing (if needed)

If you see Firestore suggesting composite indexes in the logs:

1. Go to Firebase Console → Firestore → Indexes
2. Create the suggested indexes
3. Firestore will automatically use them for optimized queries

---

## Firestore Features Used

### 1. Real-Time Listeners (Streams)
- Users list updates automatically when new users join
- Messages appear instantly as they're sent
- Conversation list updates with latest message

### 2. Subcollections
- Messages stored in subcollections for better organization
- Allows hierarchical data structure
- Easier to manage permissions

### 3. Batch Operations
- Marking multiple messages as seen in one operation
- More efficient than individual updates

### 4. Server Timestamps
- `FieldValue.serverTimestamp()` ensures consistent time across all devices
- Prevents time sync issues

### 5. Query Operations
- `orderBy()` - Sort messages by timestamp
- `where()` - Filter messages by sender/receiver
- `snapshots()` - Real-time listeners

---

## Performance Optimization Tips

1. **Pagination**: For large conversation histories, implement pagination:
```dart
query.limit(20).orderBy('timestamp', descending: true)
```

2. **Indexed Queries**: The app uses indexed fields (timestamp, participants)

3. **Subcollections**: Messages are in subcollections to avoid large documents

4. **Real-Time Listeners**: Only active conversations listen to messages (not all conversations at once)

---

## Troubleshooting

### Issue: "Permission denied" error
**Solution**: Check Firestore rules. Ensure your security rules are updated.

### Issue: Self-chat creates an error
**Solution**: This is intentional. The app validates and prevents self-chat to maintain data integrity.

### Issue: Messages not appearing
**Solution**: 
- Check Firestore rules allow read access
- Verify message was added to correct conversation path
- Check timestamps are using server time

### Issue: Search not working
**Solution**:
- Ensure query is lowercase and matches case in database
- Check that user documents exist in `users` collection
- Verify no special characters in search query

---

## Architecture Overview

```
lib/
├── main.dart (ChatService provider added)
├── models/
│   └── message.dart (Message model + enum)
├── services/
│   ├── user_service.dart (existing)
│   └── chat_service.dart (new - Firestore operations)
└── screens/
    ├── chat_screen.dart (new - users list + search)
    └── chat_detailscreen.dart (new - messaging UI)
```

### Data Flow

```
ChatService (Firestore operations)
    ↓
StreamBuilder (real-time updates)
    ↓
UI Widgets (chat_screen, chat_detailscreen)
    ↓
User Actions (send message, search)
    ↓
ChatService (update Firestore)
```

---

## Key Design Decisions

### 1. Conversation ID Format
- Sorted user IDs: `aaa_zzz` not `zzz_aaa`
- Prevents duplicate conversations
- Consistent regardless of who initiates

### 2. Message Status Levels
- Provides clear delivery and read status
- Visual indicators help users understand message state
- Status updates automatically

### 3. Subcollections for Messages
- Keeps conversation document size small
- Easier to manage permissions
- Better for large message histories

### 4. Service Layer
- Separates business logic from UI
- Easier to test and maintain
- Can be reused across different screens

---

## Future Enhancement Ideas

1. **Message Typing Indicators**: Show when user is typing
2. **Image/File Sharing**: Support media messages
3. **Message Search**: Search through all messages
4. **Conversation Pinning**: Pin important conversations
5. **Group Chats**: Extend to support multiple users
6. **Message Deletion**: Allow users to delete messages
7. **User Online Status**: Show if user is currently online
8. **Message Reactions**: Add emoji reactions to messages
9. **Voice Messages**: Record and send audio
10. **Chat Backup**: Export conversation history

---

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules with production rules
- [ ] Set up Firebase quota limits
- [ ] Enable Firestore backups
- [ ] Test with real data
- [ ] Monitor Firestore usage and optimize queries
- [ ] Implement rate limiting on message send
- [ ] Add error logging/analytics
- [ ] Test on multiple devices and network conditions
- [ ] Review security rules one more time
- [ ] Set up Firestore backup schedule

---

## Support & Further Learning

- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules Guide](https://firebase.google.com/docs/firestore/security/start)
- [Flutter Firebase Integration](https://firebase.flutter.dev/)
- [Provider Package Documentation](https://pub.dev/packages/provider)

---

**Lab Activity 6 Implementation Complete! 🎉**
