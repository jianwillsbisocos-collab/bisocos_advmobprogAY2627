import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/chat_service.dart';
import 'chat_detailscreen.dart';

/// Chat Screen displays the list of all users to chat with
/// Includes search functionality and Material 3 design
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChatDetail(UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(otherUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search users...',
              leading: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.search),
              ),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                      ),
                    ]
                  : null,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Users List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _searchQuery.isEmpty
                  ? chatService.getAllUsers()
                  : chatService.searchUsers(_searchQuery),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading users',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                // Empty State
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.people_outline
                              : Icons.search_off,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No users available'
                              : 'No users found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Users List View
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserChatCard(
                      user: user,
                      onTap: () => _navigateToChatDetail(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual user chat card with avatar and user information
class UserChatCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserChatCard({
    required this.user,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(user),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get display name from user (firstName + lastName or username)
  String _getDisplayName(UserModel user) {
    final firstName = user.firstName.trim();
    final lastName = user.lastName.trim();

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return user.username.isNotEmpty ? user.username : 'User';
  }

  /// Get initials from user name
  String _getInitials(UserModel user) {
    final displayName = _getDisplayName(user);
    final parts = displayName.split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }
}
