import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/constants.dart';
import '../models/cart.dart';

class CartService {
  final String _baseUrl = getCartHost();

  // Enhancement 3: fetch all carts from the DummyJSON carts endpoint.
  Future<List<Cart>> fetchCarts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/carts'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load carts (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> && decoded is! List) {
        throw Exception('Unexpected cart response format.');
      }

      final cartList = decoded is Map<String, dynamic>
          ? (decoded['carts'] as List? ?? const [])
          : decoded as List;

      return cartList
          .map((cart) => Cart.fromJson(Map<String, dynamic>.from(cart as Map)))
          .toList();
    } catch (error) {
      throw Exception('Unable to fetch carts: $error');
    }
  }

  // Enhancement 3: fetch one user's cart using the DummyJSON user endpoint.
  Future<Cart> fetchCartByUserId(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/carts/user/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load cart for user $userId (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response for cart by user ID.');
      }

      // The documented user endpoint returns {"carts": [...]}.
      final carts = decoded['carts'];
      if (carts is! List || carts.isEmpty) {
        throw Exception('No cart found for user $userId.');
      }

      return Cart.fromJson(Map<String, dynamic>.from(carts.first as Map));
    } catch (error) {
      throw Exception('Unable to fetch cart by user ID: $error');
    }
  }

  // Enhancement 3: add products to a cart using the DummyJSON add-to-cart endpoint.
  Future<Cart> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/carts/add'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'userId': userId, 'products': products}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add item to cart (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response while adding to cart.');
      }

      return Cart.fromJson(decoded);
    } catch (error) {
      throw Exception('Unable to add items to cart: $error');
    }
  }

  // Enhancement 3: convenience method for a single product payload.
  Future<Cart> addProductToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    return addToCart(
      userId: userId,
      products: [
        {'id': productId, 'quantity': quantity},
      ],
    );
  }
}
