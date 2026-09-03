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
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuantity(int productId, int change) {
    final cart = _currentCart;
    if (cart == null || change == 0) return;

    final updatedProducts = <CartProduct>[];
    for (final product in cart.products) {
      if (product.id != productId) {
        updatedProducts.add(product);
        continue;
      }

      final quantity = product.quantity + change;
      if (quantity > 0) {
        final total = product.price * quantity;
        final discountedPrice = total * (1 - product.discountPercentage / 100);
        updatedProducts.add(
          CartProduct(
            id: product.id,
            title: product.title,
            price: product.price,
            quantity: quantity,
            total: total,
            discountPercentage: product.discountPercentage,
            discountedPrice: discountedPrice,
            thumbnail: product.thumbnail,
          ),
        );
      }
    }

    final total = updatedProducts.fold<double>(
      0,
      (sum, product) => sum + product.total,
    );
    final discountedTotal = updatedProducts.fold<double>(
      0,
      (sum, product) => sum + product.discountedPrice,
    );
    _currentCart = Cart(
      id: cart.id,
      userId: cart.userId,
      products: updatedProducts,
      total: total,
      discountedTotal: discountedTotal,
      totalProducts: updatedProducts.length,
      totalQuantity: updatedProducts.fold<int>(
        0,
        (sum, product) => sum + product.quantity,
      ),
      isDeleted: cart.isDeleted,
      deletedOn: cart.deletedOn,
    );
    _carts = [_currentCart!];
    notifyListeners();
  }
}
