import 'package:flutter/material.dart';

import '../models/cart.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.cart, super.key});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart Details #${cart.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ID: ${cart.userId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Products: ${cart.totalProducts}'),
                    const SizedBox(height: 4),
                    Text('Total Items: ${cart.totalQuantity}'),
                    const SizedBox(height: 4),
                    Text('Subtotal: \$${cart.total.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Discounted Total: \$${cart.discountedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products in Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cart.products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = cart.products[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product.thumbnail.isNotEmpty
                              ? Image.network(
                                  product.thumbnail,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                  ),
                                )
                              : const SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Icon(Icons.shopping_bag_outlined),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('Qty: ${product.quantity}'),
                              const SizedBox(height: 4),
                              Text(
                                'Price: \$${product.price.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discount: ${product.discountPercentage.toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
