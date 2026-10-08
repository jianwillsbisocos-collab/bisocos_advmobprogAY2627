import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/auth_actions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account information'),
            subtitle: Text(user?.email ?? auth.firebaseUser?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: const Text('Username'),
            subtitle: Text(
              user?.username.isNotEmpty == true ? user!.username : 'Not set',
            ),
            trailing: IconButton(
              tooltip: 'Update username',
              onPressed: () => showUsernameDialog(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Delete account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => showDeleteAccountDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              final success = await context.read<AuthProvider>().signOut();
              if (!success && context.mounted) showAuthError(context);
            },
          ),
        ],
      ),
    );
  }
}
