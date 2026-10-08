# Firestore Test Data Setup Guide

## How to Populate Test Data for Lab Activity 6

This guide helps you create sample users and test conversations in Firestore for testing the chat app.

---

## Method 1: Manual Setup via Firebase Console (Easiest)

### Step 1: Create Users Collection

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database
4. Click "Start Collection"
5. Collection ID: `users` → Next

### Step 2: Add Test Users

For each test user, create a document:

**User 1 - Alice**
- Document ID: `alice123`
- Fields:
  ```
  uid          : "alice123"
  firstName    : "Alice"
  lastName     : "Johnson"
  email        : "alice@example.com"
  username     : "alicej"
  age          : 25
  contactNumber: "+1234567890"
  ```

**User 2 - Bob**
- Document ID: `bob456`
- Fields:
  ```
  uid          : "bob456"
  firstName    : "Bob"
  lastName     : "Smith"
  email        : "bob@example.com"
  username     : "bobsmith"
  age          : 28
  contactNumber: "+1234567891"
  ```

**User 3 - Charlie**
- Document ID: `charlie789`
- Fields:
  ```
  uid          : "charlie789"
  firstName    : "Charlie"
  lastName     : "Brown"
  email        : "charlie@example.com"
  username     : "charliebrown"
  age          : 30
  contactNumber: "+1234567892"
  ```

**User 4 - Diana**
- Document ID: `diana321`
- Fields:
  ```
  uid          : "diana321"
  firstName    : "Diana"
  lastName     : "Prince"
  email        : "diana@example.com"
  username     : "dianaprince"
  age          : 26
  contactNumber: "+1234567893"
  ```

### Step 3: Create Conversations Collection

1. In Firestore, click "Start Collection"
2. Collection ID: `conversations` → Next
3. Document ID: `alice123_bob456` (follow format: smaller_uid_larger_uid)
4. Fields:
   ```
   participants     : ["alice123", "bob456"]
   createdAt        : 2024-10-08 (server timestamp)
   lastMessage      : "Hey, how's it going?"
   lastMessageTime  : 2024-10-08 (server timestamp)
   lastMessageSender: "alice123"
   ```

### Step 4: Add Messages Subcollection

For the conversation `alice123_bob456`:
1. Click on the document
2. "Start Subcollection" → Collection ID: `messages` → Next
3. Document ID: (auto-generated)
4. First message:
   ```
   senderId   : "alice123"
   receiverId : "bob456"
   text       : "Hey Bob, how are you?"
   timestamp  : 2024-10-08 (server timestamp)
   status     : "sent"
   ```
5. Second message:
   ```
   senderId   : "bob456"
   receiverId : "alice123"
   text       : "Hi Alice! I'm doing great, thanks for asking!"
   timestamp  : 2024-10-08 (server timestamp)
   status     : "seen"
   ```

---

## Method 2: Firestore Import JSON (Advanced)

### Step 1: Create Firestore Export File

Create a file named `firestore-test-data.json`:

```json
{
  "users": {
    "alice123": {
      "uid": "alice123",
      "firstName": "Alice",
      "lastName": "Johnson",
      "email": "alice@example.com",
      "username": "alicej",
      "age": 25,
      "contactNumber": "+1234567890"
    },
    "bob456": {
      "uid": "bob456",
      "firstName": "Bob",
      "lastName": "Smith",
      "email": "bob@example.com",
      "username": "bobsmith",
      "age": 28,
      "contactNumber": "+1234567891"
    },
    "charlie789": {
      "uid": "charlie789",
      "firstName": "Charlie",
      "lastName": "Brown",
      "email": "charlie@example.com",
      "username": "charliebrown",
      "age": 30,
      "contactNumber": "+1234567892"
    },
    "diana321": {
      "uid": "diana321",
      "firstName": "Diana",
      "lastName": "Prince",
      "email": "diana@example.com",
      "username": "dianaprince",
      "age": 26,
      "contactNumber": "+1234567893"
    }
  },
  "conversations": {
    "alice123_bob456": {
      "participants": ["alice123", "bob456"],
      "createdAt": "2024-10-08T10:00:00Z",
      "lastMessage": "Hey, how's it going?",
      "lastMessageTime": "2024-10-08T10:05:00Z",
      "lastMessageSender": "bob456"
    }
  }
}
```

### Step 2: Use Firebase CLI

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Import data
firebase firestore:import firestore-test-data.json
```

---

## Method 3: Create Sample Users During Auth (Recommended)

After a user signs up, automatically create their user document:

```dart
// In your signup/auth service
Future<void> createAccount(String email, String password, String firstName, 
                          String lastName, String username) async {
  final credential = await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Create user document in Firestore
  await _firestore.collection('users').doc(credential.user!.uid).set({
    'uid': credential.user!.uid,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'username': username,
    'age': 0,  // Optional
    'contactNumber': '',  // Optional
    // 'photoUrl': photoUrl,  // Optional
  });

  return credential;
}
```

---

## Test Data Scenarios

### Scenario 1: Basic Chat Test

**Participants**: Alice & Bob
**Messages**:
1. Alice → Bob: "Hi Bob!"
2. Bob → Alice: "Hello Alice! How are you?"
3. Alice → Bob: "I'm doing great, thanks!"
4. Bob → Alice: "Great to hear!"

---

### Scenario 2: Multiple Conversations

**Conversation 1**: Alice ↔ Bob
- Status: Active (recent messages)

**Conversation 2**: Alice ↔ Charlie
- Status: Old (last message from week ago)

**Conversation 3**: Bob ↔ Diana
- Status: New (just created, no messages yet)

---

### Scenario 3: Search Testing

Create users with various name combinations to test search:

```
- John Anderson (username: janderson, email: john.anderson@example.com)
- Jane Adams (username: jadams, email: jane.adams@example.com)
- John Baker (username: jbaker, email: john.baker@example.com)
- Amy Johnson (username: ajohnson, email: amy.johnson@example.com)
```

**Search tests**:
- Search "John" → Find John Anderson & John Baker
- Search "anderson" → Find John Anderson
- Search "john@example.com" → Find corresponding user
- Search "ja" → Find Jane Adams & John Anderson

---

## Message Status Testing

### Create Messages with Different Statuses

In the same conversation, create messages with different statuses:

**Message 1** (Sent):
```
senderId: "alice123"
receiverId: "bob456"
text: "This message was delivered"
timestamp: 2024-10-08T10:00:00Z
status: "sent"
```

**Message 2** (Delivered):
```
senderId: "alice123"
receiverId: "bob456"
text: "This message was delivered"
timestamp: 2024-10-08T10:01:00Z
status: "delivered"
```

**Message 3** (Seen):
```
senderId: "alice123"
receiverId: "bob456"
text: "This message was read"
timestamp: 2024-10-08T10:02:00Z
status: "seen"
```

**Message 4** (Sending):
```
senderId: "alice123"
receiverId: "bob456"
text: "This message is being sent"
timestamp: 2024-10-08T10:03:00Z
status: "sending"
```

---

## Complete Example: Step-by-Step

### 1. Create First User (Alice)

```
Collection: users
Document ID: alice123
Data:
{
  "uid": "alice123",
  "firstName": "Alice",
  "lastName": "Johnson",
  "email": "alice@example.com",
  "username": "alicej",
  "age": 25,
  "contactNumber": "+1234567890"
}
```

### 2. Create Second User (Bob)

```
Collection: users
Document ID: bob456
Data:
{
  "uid": "bob456",
  "firstName": "Bob",
  "lastName": "Smith",
  "email": "bob@example.com",
  "username": "bobsmith",
  "age": 28,
  "contactNumber": "+1234567891"
}
```

### 3. Create Conversation

```
Collection: conversations
Document ID: alice123_bob456
Data:
{
  "participants": ["alice123", "bob456"],
  "createdAt": Timestamp (server time),
  "lastMessage": "Hey Bob!",
  "lastMessageTime": Timestamp (server time),
  "lastMessageSender": "alice123"
}
```

### 4. Add First Message to Subcollection

```
Subcollection: conversations/alice123_bob456/messages
Document ID: (auto-generated)
Data:
{
  "senderId": "alice123",
  "receiverId": "bob456",
  "text": "Hey Bob, how are you?",
  "timestamp": Timestamp (server time),
  "status": "sent"
}
```

### 5. Add Second Message to Subcollection

```
Subcollection: conversations/alice123_bob456/messages
Document ID: (auto-generated)
Data:
{
  "senderId": "bob456",
  "receiverId": "alice123",
  "text": "Hi Alice! I'm doing great!",
  "timestamp": Timestamp (server time),
  "status": "seen"
}
```

---

## Firebase Emulator (For Local Testing)

### Setup Emulator

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init emulators

# Start emulator
firebase emulators:start
```

### Use Emulator in Flutter

```dart
// In main.dart
if (kDebugMode) {
  await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## Cleanup

### Delete Test Data

1. Go to Firestore Console
2. Select a collection (e.g., `conversations`)
3. Click "Delete Collection"
4. Confirm deletion

**Or programmatically:**

```dart
// Delete a conversation
await FirebaseFirestore.instance
    .collection('conversations')
    .doc('alice123_bob456')
    .delete();
```

---

## Verification Checklist

After setting up test data:

- [ ] `users` collection exists with 4+ test users
- [ ] `conversations` collection exists
- [ ] Conversation document has `participants` array
- [ ] `messages` subcollection exists under a conversation
- [ ] Messages have all required fields (senderId, receiverId, text, timestamp, status)
- [ ] You can see all test users when logged in
- [ ] Search works for finding test users
- [ ] Can open a conversation and see messages
- [ ] Message status indicators work correctly

---

## Sample Test Cases

### Test 1: User List Display
- Login as Alice
- Go to Chat Screen
- Should see Bob, Charlie, Diana (not Alice herself)
- ✅ PASS if 3 users shown

### Test 2: Search Functionality
- Search "Bob"
- Should show only Bob Smith
- Search "john"
- Should show John Anderson, John Baker, etc.
- ✅ PASS if filtering works correctly

### Test 3: Open Conversation
- Tap on Bob in user list
- Chat screen opens
- Previous messages appear
- ✅ PASS if messages display

### Test 4: Send Message
- Type "Hello!"
- Tap send
- Message appears with status
- Bob's device receives it in real-time
- ✅ PASS if message sends

### Test 5: Message Status
- Watch status change from ✓ to ✓✓ to ✓✓ (colored)
- ✅ PASS if all statuses work

---

## Common Issues & Solutions

### Issue: No users appear in chat list
**Solution**: Check if `users` collection exists and has documents

### Issue: Search doesn't work
**Solution**: Verify user documents have firstName, lastName, username, email fields

### Issue: Conversation doesn't load
**Solution**: Check conversation document ID format is `userId1_userId2`

### Issue: Messages don't appear
**Solution**: 
- Verify messages subcollection exists
- Check all required fields present
- Verify senderId/receiverId match participants

---

## Performance Notes

- 4 test users: ~100ms to load
- 10 messages in conversation: ~200ms to load
- Search among 100 users: <300ms

---

**Test data setup complete! You're ready to test Lab Activity 6! 🎉**
