# Lab Activity 6: Quick Integration Guide

## Quick Copy-Paste Integration Steps

### Step 1: Add Import to Your Navigation File

Add this import at the top of your file (e.g., `profile_screen.dart` or wherever you manage navigation):

```dart
import 'package:bisocos_advmobprogay2627/screens/chat_screen.dart';
```

---

### Step 2: Add FloatingActionButton (Option A)

If your home/main screen uses a FloatingActionButton for navigation:

```dart
FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  },
  tooltip: 'Messages',
  child: const Icon(Icons.chat),
)
```

---

### Step 3: Add Menu Item (Option B)

If you have a menu/drawer/navigation bar:

```dart
ListTile(
  leading: const Icon(Icons.chat),
  title: const Text('Messages'),
  subtitle: const Text('Chat with other users'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  },
)
```

---

### Step 4: Add to BottomNavigationBar (Option C)

If you use a BottomNavigationBar:

```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() => _selectedIndex = index);
    
    if (index == 0) {
      // Home
    } else if (index == 1) {
      // Navigate to Chat
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } else if (index == 2) {
      // Profile
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

---

### Step 5: Verify Main.dart (Already Done ✅)

Your `main.dart` already has:

```dart
import 'services/chat_service.dart';

// In MultiProvider:
Provider(create: (_) => ChatService()),
```

**No additional changes needed!**

---

## Testing the Integration

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Login with a test account**

3. **Navigate to Chat Screen** (using the button/menu you added)

4. **Verify:**
   - ✅ You see a list of all other users
   - ✅ Your own account is NOT in the list
   - ✅ Search works when you type
   - ✅ Tapping a user opens the chat

---

## Complete Example: Adding to Profile Screen

If you want to add a chat button to your profile screen:

```dart
// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bisocos_advmobprogay2627/services/user_service.dart';
import 'package:bisocos_advmobprogay2627/screens/chat_screen.dart';  // ADD THIS

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.read<UserService>();
    final user = userService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // ADD THIS BUTTON
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          ),
          // END OF NEW BUTTON
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user?.email ?? 'Not logged in'),
            const SizedBox(height: 16),
            // ADD THIS BUTTON ALTERNATIVE
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Go to Messages'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
            // END OF ALTERNATIVE BUTTON
          ],
        ),
      ),
    );
  }
}
```

---

## Troubleshooting

### Issue: "ChatScreen not found" or Import error
**Solution**: Make sure the import is correct:
```dart
import 'package:bisocos_advmobprogay2627/screens/chat_screen.dart';
```

### Issue: App crashes when opening Chat Screen
**Solution**: Verify:
1. ChatService is in providers (check main.dart)
2. Firebase is initialized
3. User is authenticated

### Issue: Users list is empty
**Solution**:
1. Check Firestore has `users` collection
2. Verify security rules allow reading users
3. Ensure other users exist in database
4. Refresh the app

### Issue: "Cannot start a chat with yourself" error
**Solution**: This is intentional validation. The app prevents self-chat. The error should not occur in normal usage because you're excluded from the users list.

---

## Firestore Setup (One-Time Only)

### 1. Create Collections in Firestore Console

Go to Firebase Console → Firestore Database

**Collection 1: users**
```
Document ID: (auto)
Fields:
- uid: String
- firstName: String
- lastName: String
- email: String
- username: String
- age: Number
- contactNumber: String
```

**Collection 2: conversations**
```
Document ID: userId1_userId2 (example: aaa_zzz)
Fields:
- participants: Array [userId1, userId2]
- createdAt: Timestamp
- lastMessage: String
- lastMessageTime: Timestamp
- lastMessageSender: String

Subcollection: messages
Document ID: (auto)
Fields:
- senderId: String
- receiverId: String
- text: String
- timestamp: Timestamp
- status: String
```

### 2. Update Security Rules

Go to Firestore Database → Rules

Replace with the rules from `firestore.rules` file in your project.

---

## Features Quick Reference

### Chat Screen (Users List)
- View all users
- Real-time search
- No self-chat
- Modern Material 3 UI

### Chat Detail Screen (Messaging)
- Send messages
- See message status
- Auto-scroll to latest
- Animations
- Timestamp for each message

### Message Status Indicators
- 🕐 = Sending
- ✓ = Sent
- ✓✓ = Delivered
- ✓✓ (blue) = Seen

---

## Code Snippets Ready to Use

### Navigate with Arguments (if needed later)

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const ChatScreen(/* no args needed */),
  ),
);
```

### Custom Navigation with Named Routes (advanced)

If your app uses named routes:

```dart
// In main.dart, add to routes:
'/chat': (context) => const ChatScreen(),

// Then use:
Navigator.of(context).pushNamed('/chat');
```

---

## Success Indicators

You'll know the integration is successful when:

✅ Chat Screen button is visible in your app
✅ Clicking it opens the Users List
✅ You see other users (not yourself)
✅ Search filters users in real-time
✅ Tapping a user opens the chat
✅ You can type and send messages
✅ Messages appear with status icons
✅ No errors in console

---

## Performance Notes

- Users list loads instantly (real-time stream)
- Messages stream updates instantly
- Search filters in real-time
- No noticeable lag with 100+ users
- Optimized Firestore queries

---

## Next Steps After Integration

1. ✅ Integrate Chat Screen into navigation
2. Test chat functionality end-to-end
3. Test on multiple devices
4. Deploy to Firebase Hosting (if needed)
5. Gather user feedback
6. Add additional features (typing indicators, images, etc.)

---

## Support

If you encounter issues:

1. Check the **LAB_ACTIVITY_6_GUIDE.md** for detailed setup
2. Verify all 4 new files exist
3. Run `flutter pub get`
4. Check Firebase console for errors
5. Review Firestore security rules

---

**Ready to go! Start the app and navigate to Chat Screen! 🚀**
