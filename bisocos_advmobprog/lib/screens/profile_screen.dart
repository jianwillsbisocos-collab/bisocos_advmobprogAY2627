import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'signin_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.user, super.key});
  final User? user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;

  @override
  void initState() {
    super.initState();
    // Enhancement: read the canonical profile from persistent storage through the service.
    _user = context.read<UserService>().getSavedUser() ?? widget.user;
  }

  Future<void> _logout() async {
    // Enhancement: clear the local session and return to the sign-in boundary.
    await context.read<UserService>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No saved user session.')),
      );
    }
    final displayName = '${user.firstname} ${user.lastname}'.trim();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF394A98),
        foregroundColor: Colors.white,
        title: Text(user.firstname.isEmpty ? 'Profile' : user.firstname),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFFE5F3EA),
                  backgroundImage: user.image.isEmpty
                      ? null
                      : NetworkImage(user.image),
                  child: user.image.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF3A9D8A),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  displayName.isEmpty ? user.username : displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    color: Color(0xFFE4A5B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _ProfileRow(
                  label: 'Email',
                  value: user.email,
                  icon: Icons.email_outlined,
                ),
                _ProfileRow(
                  label: 'Gender',
                  value: user.gender,
                  icon: Icons.wc_outlined,
                ),
                _ProfileRow(
                  label: 'User ID',
                  value: '${user.id}',
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _logout,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6258),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    minVerticalPadding: 4,
    leading: Icon(icon, size: 16, color: const Color(0xFFE8B83A)),
    title: Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    ),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(
        value.isEmpty ? 'Not provided' : value,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 10, color: Color(0xFFB5B2BA)),
      ),
    ),
  );
}
