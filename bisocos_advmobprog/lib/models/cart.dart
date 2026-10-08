class CartProduct {
  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedPrice,
    this.thumbnail = '',
  });

  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedPrice;
  final String thumbnail;

  // Enhancement 1: map a single cart item from the DummyJSON response.
  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? json['image'] as String? ?? '',
    );
  }
}

class Cart {
  const Cart({
    required this.id,
    required this.userId,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.totalProducts,
    required this.totalQuantity,
    required this.isDeleted,
    this.deletedOn,
  });

  final int id;
  final int userId;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;
  final bool isDeleted;
  final int? deletedOn;

  // Enhancement 3: parse the cart payload returned by the DummyJSON Cart API.
  factory Cart.fromJson(Map<String, dynamic> json) {
    final productsJson = (json['products'] as List? ?? const []);
    final products = productsJson
        .map(
          (product) =>
              CartProduct.fromJson(Map<String, dynamic>.from(product as Map)),
        )
        .toList();

    return Cart(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      products: products,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedOn: json['deletedOn'] as int?,
    );
  }
}
