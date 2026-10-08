import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _contact = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _contact.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = UserModel(
      uid: '',
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      age: int.parse(_age.text.trim()),
      contactNumber: _contact.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
    );
    final success = await context.read<AuthProvider>().createAccount(
      email: _email.text.trim(),
      password: _password.text,
      profile: profile,
    );
    if (mounted && success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (mounted && !success) {
      final message = context.read<AuthProvider>().errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Your details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  AuthFormField(
                    controller: _firstName,
                    label: 'First name',
                    icon: Icons.person_outline,
                    validator: (value) => _required(value, 'First name'),
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _lastName,
                    label: 'Last name',
                    icon: Icons.person_outline,
                    validator: (value) => _required(value, 'Last name'),
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _age,
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final age = int.tryParse(value?.trim() ?? '');
                      if (age == null) return 'Enter a numeric age.';
                      if (age < 1 || age > 120) {
                        return 'Enter an age from 1 to 120.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _contact,
                    label: 'Contact number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final contact = value?.trim() ?? '';
                      if (contact.isEmpty) return 'Contact number is required.';
                      if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(contact)) {
                        return 'Enter 7 to 15 digits, optionally starting with +.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _username,
                    label: 'Username',
                    icon: Icons.alternate_email,
                    validator: (value) => _required(value, 'Username'),
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _email,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Email is required.';
                      return emailPattern.hasMatch(email)
                          ? null
                          : 'Enter a valid email.';
                    },
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _password,
                    label: 'Password',
                    icon: Icons.password_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Use at least 8 characters.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthFormField(
                    controller: _confirmPassword,
                    label: 'Confirm password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) => value != _password.text
                        ? 'Passwords do not match.'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _signup,
                    child: isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
