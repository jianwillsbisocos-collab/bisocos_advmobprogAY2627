import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._userService) {
    _authSubscription = _userService.authStateChanges.listen(_onAuthChanged);
  }

  final UserService _userService;
  late final StreamSubscription<firebase.User?> _authSubscription;
  firebase.User? _firebaseUser;
  UserModel? _userData;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  firebase.User? get firebaseUser => _firebaseUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _firebaseUser != null;
  String? get errorMessage => _errorMessage;

  Future<void> _onAuthChanged(firebase.User? user) async {
    _firebaseUser = user;
    _userData = user == null ? null : await _loadUserData(user);
    _isInitializing = false;
    notifyListeners();
  }

  Future<UserModel?> _loadUserData(firebase.User user) async {
    try {
      return UserModel.fromMap(await _userService.getUserData());
    } on FirebaseException {
      return UserModel(
        uid: user.uid,
        firstName: '',
        lastName: '',
        age: 0,
        contactNumber: '',
        username: user.displayName ?? '',
        email: user.email ?? '',
      );
    }
  }

  Future<bool> signIn(String email, String password) => _perform(() async {
    await _userService.signIn(email, password);
  });

  Future<bool> createAccount({
    required String email,
    required String password,
    required UserModel profile,
  }) => _perform(() async {
    final credential = await _userService.createAccount(email, password);
    final user = credential?.user;
    if (user == null) throw StateError('Firebase did not return a user.');
    await _userService.saveUserData(profile.copyWith(uid: user.uid));
    await _onAuthChanged(user);
  });

  Future<bool> signOut() => _perform(_userService.signOut);

  Future<bool> resetPassword(String email) =>
      _perform(() => _userService.resetPassword(email));

  Future<bool> updateUsername(String username) => _perform(() async {
    await _userService.updateUsername(username);
    final existing = _userData;
    if (existing != null) {
      _userData = existing.copyWith(username: username);
    }
  });

  Future<bool> updatePassword(String password) =>
      _perform(() => _userService.updatePassword(password));

  Future<bool> reauthenticate(String password) =>
      _perform(() => _userService.reauthenticate(password));

  Future<bool> deleteAccount() => _perform(_userService.deleteAccount);

  Future<bool> _perform(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on firebase.FirebaseAuthException catch (error) {
      _errorMessage = _messageFor(error);
      return false;
    } on FirebaseException catch (error) {
      _errorMessage = error.message ?? 'Unable to complete the request.';
      return false;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(
    firebase.FirebaseAuthException error,
  ) => switch (error.code) {
    'invalid-email' => 'Enter a valid email address.',
    'user-not-found' ||
    'invalid-credential' => 'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for this email.',
    'weak-password' => 'Choose a stronger password (at least 8 characters).',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'requires-recent-login' => 'Sign in again before performing this action.',
    'network-request-failed' => 'Check your internet connection and try again.',
    _ => error.message ?? 'Authentication failed. Please try again.',
  };

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

extension on UserModel {
  UserModel copyWith({String? uid, String? username}) => UserModel(
    uid: uid ?? this.uid,
    firstName: firstName,
    lastName: lastName,
    age: age,
    contactNumber: contactNumber,
    username: username ?? this.username,
    email: email,
  );
}
