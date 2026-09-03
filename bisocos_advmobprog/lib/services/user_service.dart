import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/constants.dart';
import '../models/user.dart';
import '../models/cart.dart';

class UserService {
  UserService({required this._preferences, http.Client? client})
    : _client = client ?? http.Client();

  static const _savedUserKey = 'authenticated_user';
  final SharedPreferences _preferences;
  final http.Client _client;

  String get _baseUrl => getCartHost();

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Invalid username or password.');
    }
    final user = User.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    await saveUser(user);
    return user;
  }

  Future<void> saveUser(User user) async {
    await _preferences.setString(_savedUserKey, jsonEncode(user.toJson()));
  }

  User? getSavedUser() {
    final saved = _preferences.getString(_savedUserKey);
    if (saved == null) return null;
    try {
      return User.fromJson(jsonDecode(saved) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> logout() => _preferences.remove(_savedUserKey);

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
