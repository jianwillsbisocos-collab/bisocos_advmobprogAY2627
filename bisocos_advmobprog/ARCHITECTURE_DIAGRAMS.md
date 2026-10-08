# Lab Activity 6: Visual Architecture & Flow Diagrams

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (UI Layer)                        │
│                                                                   │
│  ┌──────────────────┐          ┌──────────────────────────┐    │
│  │  ChatScreen      │          │ ChatDetailScreen         │    │
│  │  - User List     │ ──────→  │ - Messaging              │    │
│  │  - Search        │          │ - Message Status         │    │
│  │  - Real-time     │          │ - Animations             │    │
│  └────────┬─────────┘          └──────────┬───────────────┘    │
│           │                                 │                    │
│           └─────────────────┬───────────────┘                    │
│                             │                                    │
├─────────────────────────────▼────────────────────────────────────┤
│              Provider & Service Layer (Business Logic)           │
│                                                                   │
│              ┌──────────────────────────────┐                   │
│              │     ChatService              │                   │
│              │  - getAllUsers()             │                   │
│              │  - searchUsers()             │                   │
│              │  - getOrCreateConversation() │                   │
│              │  - sendMessage()             │                   │
│              │  - getMessages()             │                   │
│              │  - markMessageAsSeen()       │                   │
│              └──────────────┬───────────────┘                   │
│                             │                                    │
├─────────────────────────────▼────────────────────────────────────┤
│              Models (Data Structures)                             │
│                                                                   │
│   ┌─────────────────┐        ┌──────────────────────┐          │
│   │   UserModel     │        │  Message             │          │
│   │  - uid          │        │  - id                │          │
│   │  - firstName    │        │  - senderId          │          │
│   │  - lastName     │        │  - receiverId        │          │
│   │  - email        │        │  - text              │          │
│   │  - username     │        │  - timestamp         │          │
│   └─────────────────┘        │  - status            │          │
│                              │  (enum: 4 states)    │          │
│                              └──────────────────────┘          │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│         Firebase Firestore (Real-time Database)                 │
│                                                                   │
│  ┌──────────────┐      ┌──────────────────────────────────┐    │
│  │  users/      │      │  conversations/                  │    │
│  │  ├─ userId1  │      │  ├─ userId1_userId2             │    │
│  │  └─ userId2  │      │  │  ├─ participants[]           │    │
│  │              │      │  │  ├─ lastMessage              │    │
│  │              │      │  │  └─ messages/ (subcollection)│    │
│  │              │      │  │     ├─ messageId1            │    │
│  │              │      │  │     └─ messageId2            │    │
│  │              │      │  └─ userId1_userId3            │    │
│  │              │      │     ...                         │    │
│  └──────────────┘      └──────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 User Flow Diagram

```
Start App
    ↓
Login (Firebase Auth)
    ↓
Select "Messages" / Chat Button
    ↓
┌──────────────────────────────────────┐
│    CHAT SCREEN (User List)           │
│  ┌────────────────────────────────┐  │
│  │ Search Bar                     │  │
│  ├────────────────────────────────┤  │
│  │ Alice Johnson (alicej)         │  │ ← ChatService.getAllUsers()
│  │ Bob Smith (bobsmith)           │  │
│  │ Charlie Brown (charliebrown)   │  │   Real-time Stream
│  │ Diana Prince (dianaprince)     │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
    ↓
Tap User → Alice
    ↓
┌──────────────────────────────────────┐
│  CHAT DETAIL SCREEN                  │
│  ┌────────────────────────────────┐  │
│  │ ← Alice Johnson                │  │
│  ├────────────────────────────────┤  │
│  │                                │  │
│  │     "Hey, how are you?" ✓✓   │  │ ← Message with status
│  │                                │  │
│  │  "I'm doing great, thanks!" ✓│  │
│  │                                │  │
│  ├────────────────────────────────┤  │
│  │ [Type message...][SEND BUTTON] │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
    ↓
Type Message
    ↓
Send → ChatService.sendMessage()
    ↓
Message appears with ✓ (Sent)
    ↓
Status updates: ✓ → ✓✓ → ✓✓(blue)
```

---

## 🔄 Message Status Flow

```
┌─────────────────────────────────────────────────────┐
│          MESSAGE LIFECYCLE                          │
└─────────────────────────────────────────────────────┘

┌──────────┐
│ SENDING  │  (🕐 Clock Icon)
│ status:  │  User just hit send
│ sending  │  Message uploading to Firestore
└────┬─────┘
     │
     ↓
┌──────────┐
│ SENT     │  (✓ Single Check)
│ status:  │  Message successfully stored
│ sent     │  in Firestore
└────┬─────┘
     │
     ↓
┌──────────┐
│DELIVERED │  (✓✓ Double Check)
│ status:  │  Recipient device received
│delivered │  the message
└────┬─────┘
     │
     ↓
┌──────────┐
│ SEEN     │  (✓✓ Blue Double Check)
│ status:  │  Recipient opened the chat
│ seen     │  and viewed the message
└──────────┘
```

---

## 🔐 Firestore Security Flow

```
┌──────────────────────────────────────┐
│  User Attempts Action                │
└────────────┬─────────────────────────┘
             │
             ↓
    ┌─────────────────┐
    │ Firebase Auth   │
    │ Verified?       │
    └────┬────────────┘
         │
    No   │   Yes
    ├────┴─────────────────────────┐
    ↓                               ↓
  DENY                    ┌──────────────────┐
(401 Unauthorized)        │ Check Firestore  │
                          │ Security Rules   │
                          └────┬─────────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
                No  │  Yes               │
                ├───┴──────────┐         │
                ↓              ↓         │
              DENY          ALLOW       │
         (403 Forbidden)             (200 OK)
                                        │
                                    Action
                                    Succeeds
```

---

## 🔍 Real-Time Search Flow

```
┌────────────────────────────────┐
│ User Types in Search Bar       │
│ "Bob"                          │
└────────┬───────────────────────┘
         │
         ↓
┌─────────────────────────────────────┐
│ ChatService.searchUsers("bob")      │
│ - Returns Stream<List<UserModel>>   │
└────────┬────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│ Firestore Query:                     │
│ WHERE firstName.contains("bob") OR   │
│       lastName.contains("bob") OR    │
│       username.contains("bob") OR    │
│       email.contains("bob")          │
└────────┬─────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│ Results:                             │
│ - Bob Smith (bobsmith)               │
│ - Bobby Johnson (bobbyjohnson)       │
└────────┬─────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│ StreamBuilder Rebuilds UI            │
│ UserChatCard widgets update          │
└──────────────────────────────────────┘
```

---

## 💬 Conversation Creation

```
┌──────────────────────────────┐
│ User A (uid: aaa)            │
│ Taps on User B (uid: zzz)    │
└────────┬─────────────────────┘
         │
         ↓
┌────────────────────────────────────┐
│ ChatService.getOrCreateConversation│
│   (otherUserId: "zzz")             │
└────────┬────────────────────────────┘
         │
         ↓
┌───────────────────────────────────────┐
│ Validation:                           │
│ Is currentUserId == otherUserId?      │
│ (Is it self-chat?)                    │
└────┬──────────────────────────┬───────┘
     │ YES                      │ NO
     ↓                          ↓
  THROW ERROR          ┌─────────────────────┐
(Cannot self-chat)     │ Generate Conversation│
                       │ ID:                  │
                       │ aaa_zzz (sorted)     │
                       └─────────┬────────────┘
                                 │
                                 ↓
                       ┌──────────────────┐
                       │ Check if exists  │
                       │ in Firestore     │
                       └────┬──────┬──────┘
                         YES │      │ NO
                            │      ↓
                       Exists   Create New
                              Document
                                 │
                                 ↓
                       ┌──────────────────┐
                       │ Return conversation│
                       │ ID for messaging   │
                       └──────────────────┘
```

---

## 📊 Data Synchronization

```
Device A (User 1)          Cloud Firestore         Device B (User 2)
┌───────────────┐         ┌──────────────┐        ┌───────────────┐
│               │         │              │        │               │
│  User opens   │         │ collections: │        │  User opens   │
│  Chat with    │         │              │        │  Chat with    │
│  User 2       │         │ users        │        │  User 1       │
│               │         │ conversations│        │               │
└───────────────┘         │ messages     │        └───────────────┘
        │                 │              │                │
        ├─────────────→ Read all users ←──────────────────┤
        │                 │              │                │
        │        ┌──────────────────────┐                │
        │        │ Real-time listeners  │                │
        │        │ activated            │                │
        │        └──────────────────────┘                │
        │                 │              │                │
        │                 │ Listen to    │                │
        │                 │ conversations│                │
        │                 │ & messages   │                │
        │                 │              │                │
        └─→ Type message ──→ Send message──→ Update Firestore
                                │              │
                                │              ↓
                                │           ┌─────────┐
                                │           │ Trigger │
                                │           │ listener│
                                │           └────┬────┘
                                │                │
                                ↓                ↓
                           Update status    Receive message
                           ✓ → ✓✓ → ✓✓     in real-time
```

---

## 🎨 UI Component Hierarchy

```
ChatScreen (StatefulWidget)
├── AppBar
│   └── Text("Messages")
├── SearchBar
│   ├── Leading Icon (search)
│   ├── TextField (search query)
│   └── Trailing IconButton (clear)
└── StreamBuilder<List<UserModel>>
    └── ListView.builder
        └── UserChatCard × N
            ├── Container (avatar)
            │   └── Text (initials)
            ├── Column (user info)
            │   ├── Text (name)
            │   └── Text (email)
            └── Icon (arrow)

ChatDetailScreen (StatefulWidget)
├── AppBar
│   └── Column
│       ├── Text (user name)
│       └── Text (email)
├── StreamBuilder<List<Message>>
│   └── ListView.builder (reverse: true)
│       └── FadeInWidget
│           └── MessageBubble × N
│               ├── Container (bubble)
│               │   ├── Text (message)
│               │   └── Row
│               │       ├── Text (timestamp)
│               │       └── Icon (status)
│               └── Padding
├── Divider
└── InputField Row
    ├── Expanded
    │   └── TextField
    └── IconButton (send)
```

---

## ⚡ Performance Optimization

```
Firestore Queries:
├── Indexed Fields
│   ├── users: uid
│   ├── conversations: participants
│   └── messages: timestamp, senderId, receiverId
├── Optimized Queries
│   ├── getAllUsers(): collection snapshot
│   ├── searchUsers(query): filtered snapshot
│   └── getMessages(): ordered snapshot (timestamp desc)
└── Batch Operations
    └── markConversationAsSeen(): batch update

UI Rendering:
├── StreamBuilder
│   └── Efficient updates only when data changes
├── ListView
│   └── Virtual scrolling (only visible items)
├── Images
│   └── Avatar cached (initials)
└── Animations
    └── Hardware accelerated (GPU)
```

---

## 🔄 State Management with Provider

```
┌─────────────────────────────────────┐
│ main.dart (MultiProvider Setup)     │
├─────────────────────────────────────┤
│                                     │
│ Provider<ChatService>               │
│ ├─ create: ChatService()            │
│ └─ listen: false (stateless)        │
│                                     │
│ Screens can access via:             │
│ context.read<ChatService>()         │
│ context.watch<ChatService>()        │
│                                     │
└─────────────────────────────────────┘
         │
         ├─────────────────────────────┤
         │                             │
    ┌────▼─────┐              ┌────────▼────┐
    │ChatScreen│              │ChatDetailScreen│
    └────┬─────┘              └────────┬────┘
         │                             │
    access                        access
    ChatService                   ChatService
    methods                       methods
```

---

## 🔒 Self-Chat Prevention Logic

```
User A (uid: "aaa") initiates chat

┌──────────────────────────────────┐
│ ChatScreen displays users        │
├──────────────────────────────────┤
│                                  │
│ Filter: WHERE userId != "aaa"    │
│                                  │
│ Shows:                           │
│ - Bob (bbb)                      │
│ - Charlie (ccc)                  │
│ - Diana (ddd)                    │
│ - NOT: Alice (aaa)               │
│                                  │
│ Even if User A tries to         │
│ manually trigger self-chat:      │
│                                  │
└──────────────────────────────────┘
         │
    ┌────▼─────────────────┐
    │ getOrCreateConversation
    │ (otherUserId: "aaa")  │
    └────┬─────────────────┘
         │
         ↓
    if (currentUserId == otherUserId)
         ↓
    throw Exception(
      "Cannot start a chat with yourself"
    )
         ↓
    Error handled gracefully
    User sees SnackBar message
```

---

**Visual Architecture Diagrams - Lab Activity 6**
**Status**: Complete ✅
**Last Updated**: October 8, 2024

