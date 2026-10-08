import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../models/user_model.dart';

class UserService {
  UserService({
    required this._preferences,
    http.Client? client,
    this._auth,
    this._firestore,
  }) : _client = client ?? http.Client();

  static const _savedUserKey = 'authenticated_user';
  final SharedPreferences _preferences;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final http.Client _client;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String get _baseUrl => getCartHost();

  Future<UserCredential?> signIn(String email, String password) => _firebaseAuth
      .signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<UserCredential?> createAccount(String email, String password) async =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  Future<void> saveUserData(UserModel profile) async {
    final user = currentUser;
    if (user == null) throw StateError('Sign in before saving a profile.');
    await user.updateDisplayName(profile.username);
    await _database.collection('users').doc(user.uid).set(profile.toMap());
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _preferences.remove(_savedUserKey);
  }

  Future<void> updateUsername(String username) async {
    final user = currentUser;
    if (user == null) throw StateError('You must be signed in.');
    await user.updateDisplayName(username.trim());
    await _database.collection('users').doc(user.uid).set({
      'username': username.trim(),
    }, SetOptions(merge: true));
  }

  Future<void> updatePassword(String password) async {
    final user = currentUser;
    if (user == null) throw StateError('You must be signed in.');
    await user.updatePassword(password);
  }

  Future<void> resetPassword(String email) =>
      _firebaseAuth.sendPasswordResetEmail(email: email.trim());

  Future<void> reauthenticate(String password) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw StateError('A signed-in email/password account is required.');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw StateError('You must be signed in.');
    await _database.collection('users').doc(user.uid).delete();
    await user.delete();
    await _preferences.remove(_savedUserKey);
  }

  Future<Map<String, dynamic>> getUserData() async {
    final user = currentUser;
    if (user == null) throw StateError('You must be signed in.');
    final snapshot = await _database.collection('users').doc(user.uid).get();

    final data = {
      'uid': user.uid,
      'firstName': '',
      'lastName': '',
      'age': 0,
      'contactNumber': '',
      'username': user.displayName ?? '',
      'email': user.email ?? '',
      ...?snapshot.data(),
    };

    if (!snapshot.exists) {
      await snapshot.reference.set(data);
    }

    return data;
  }

  Future<List<Cart>> fetchCartsByUserId(int userId) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/carts/user/$userId'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Unable to load carts (${response.statusCode}).');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = payload['carts'];
    if (carts is! List) return const [];
    return carts
        .map((cart) => Cart.fromJson(Map<String, dynamic>.from(cart as Map)))
        .toList();
  }
}
