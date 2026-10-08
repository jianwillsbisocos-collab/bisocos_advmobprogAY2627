# Bisocos Advanced Mobile Programming

Flutter project for INF 233 - CTADMOBL Advanced Mobile Programming.

## Lab Activity 6 Discussion

### Firestore chat structure

The app stores registered profile data in the top-level `users` collection. A
user profile is saved at `users/{userId}`, where `userId` is the Firebase
Authentication UID. Profile fields include the user's UID, first and last name,
username, and email. The chat list reads this collection and excludes the
currently signed-in user's UID.

When a user selects another registered user, the app creates or reuses one
conversation document at `conversations/{conversationId}`. The conversation ID
is made by sorting the two participant UIDs and joining them, so both users
resolve to the same conversation regardless of who started the chat. The
document stores the participant UIDs and the latest-message preview and time.

Messages are stored in the conversation's `messages` subcollection:

```text
users/{userId}
  uid
  firstName
  lastName
  username
  email

conversations/{conversationId}
  participants: [userId1, userId2]
  lastMessage
  lastMessageTime
  lastMessageSender

conversations/{conversationId}/messages/{messageId}
  senderId
  receiverId
  text
  timestamp
  status: sending | sent | delivered | seen
```

The app uses Firestore snapshot streams to update the user list and conversation
messages in real time. Message status is stored with each message and shown in
the chat UI.

### Preventing self-chat

Starting a chat with the currently signed-in account is blocked. Self-chat
would assign the same UID as sender and receiver, creating a redundant
conversation and confusing message/status behavior. The app therefore excludes
the current user from the list and validates participant UIDs before creating
a conversation.

## Running the Flutter app

1. Install Flutter and configure Firebase for the app.
2. From the app project directory, fetch dependencies with `flutter pub get`.
3. Run the app with `flutter run`.

Firebase client configuration is provided in the Flutter project. Do not commit
local `.env` files or other secrets.
