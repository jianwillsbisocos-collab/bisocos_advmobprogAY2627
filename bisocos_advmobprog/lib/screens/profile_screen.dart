import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_actions.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.userData;
    final firebaseUser = auth.firebaseUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 38,
                child: Text(
                  (profile?.username.isNotEmpty == true
                          ? profile!.username[0]
                          : firebaseUser?.email?.characters.firstOrNull ?? 'U')
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile?.username.isNotEmpty == true
                    ? profile!.username
                    : firebaseUser?.email ?? 'Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              if (profile == null && auth.isInitializing)
                const Center(child: CircularProgressIndicator())
              else ...[
                _ProfileRow(label: 'UID', value: firebaseUser?.uid ?? ''),
                _ProfileRow(label: 'Username', value: profile?.username ?? ''),
                _ProfileRow(
                  label: 'Email',
                  value: profile?.email ?? firebaseUser?.email ?? '',
                ),
                _ProfileRow(
                  label: 'First name',
                  value: profile?.firstName ?? '',
                ),
                _ProfileRow(label: 'Last name', value: profile?.lastName ?? ''),
                _ProfileRow(
                  label: 'Age',
                  value: profile == null || profile.age == 0
                      ? ''
                      : '${profile.age}',
                ),
                _ProfileRow(
                  label: 'Contact number',
                  value: profile?.contactNumber ?? '',
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => showUsernameDialog(context),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit username'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => showPasswordDialog(context),
                    icon: const Icon(Icons.password_outlined),
                    label: const Text('Change password'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final success = await auth.resetPassword(
                        firebaseUser?.email ?? '',
                      );
                      if (!context.mounted) return;
                      final message = success
                          ? 'Password reset email sent.'
                          : auth.errorMessage ?? 'Unable to send reset email.';
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    },
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: const Text('Reset password'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => showDeleteAccountDialog(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete account'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final success = await context
                          .read<AuthProvider>()
                          .signOut();
                      if (!success && context.mounted) showAuthError(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                ),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Continue to shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(label),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 230),
      child: Text(
        value.isEmpty ? 'Not provided' : value,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
