import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

Future<void> showUsernameDialog(BuildContext context) async {
  final initialUsername = context.read<AuthProvider>().userData?.username ?? '';
  var enteredUsername = initialUsername;
  final username = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Update username'),
      content: TextFormField(
        initialValue: initialUsername,
        autofocus: true,
        onChanged: (value) => enteredUsername = value,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, enteredUsername.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (username == null || username.isEmpty || !context.mounted) return;
  final success = await context.read<AuthProvider>().updateUsername(username);
  if (context.mounted && !success) _showError(context);
}

Future<void> showPasswordDialog(BuildContext context) async {
  var enteredPassword = '';
  final password = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Change password'),
      content: TextFormField(
        autofocus: true,
        obscureText: true,
        onChanged: (value) => enteredPassword = value,
        decoration: const InputDecoration(labelText: 'New password'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, enteredPassword),
          child: const Text('Update'),
        ),
      ],
    ),
  );
  if (password == null || !context.mounted) return;
  if (password.length < 8) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Use at least 8 characters.')));
    return;
  }
  final success = await context.read<AuthProvider>().updatePassword(password);
  if (context.mounted && !success) _showError(context);
}

Future<void> showDeleteAccountDialog(BuildContext context) async {
  var enteredPassword = '';
  final password = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm your password. Your account and profile data will be permanently deleted.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            onChanged: (value) => enteredPassword = value,
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, enteredPassword),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete account'),
        ),
      ],
    ),
  );
  if (password == null || password.isEmpty || !context.mounted) return;
  final auth = context.read<AuthProvider>();
  final reauthenticated = await auth.reauthenticate(password);
  if (!context.mounted) return;
  if (!reauthenticated) {
    _showError(context);
    return;
  }
  final success = await context.read<AuthProvider>().deleteAccount();
  if (context.mounted && !success) _showError(context);
}

void showAuthError(BuildContext context) => _showError(context);

void _showError(BuildContext context) {
  final message = context.read<AuthProvider>().errorMessage;
  if (message == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
