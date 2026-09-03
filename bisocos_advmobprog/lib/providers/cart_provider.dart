import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service = CartService();

  List<Cart> _carts = <Cart>[];
  Cart? _currentCart;
  bool _isLoading = false;
  String? _errorMessage;

  List<Cart> get carts => _carts;
  Cart? get currentCart => _currentCart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Enhancement 1: fetch carts from the service and notify listeners.
  Future<void> fetchCarts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _carts = await _service.fetchCarts();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhancement 3: fetch a particular user's cart by ID.
  Future<void> fetchCartByUserId(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentCart = await _service.fetchCartByUserId(userId);
      _carts = _currentCart != null ? [_currentCart!] : <Cart>[];
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enhancement 3: add a product payload to the cart endpoint and refresh state.
  Future<void> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentCart = await _service.addToCart(
        userId: userId,
        products: products,
      );
      if (_currentCart != null) {
        _carts = [_currentCart!];
      }
      await fetchCartByUserId(userId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
