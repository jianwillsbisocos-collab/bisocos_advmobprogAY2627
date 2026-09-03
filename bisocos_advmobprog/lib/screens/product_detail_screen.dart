import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/constants.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../custom_text.dart';

// Enhancement 2: Product detail page
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      floatingActionButton: FloatingActionButton.extended(
        // Enhancement 2: Chat is exposed as the floating action on this screen.
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat feature coming soon.')),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Chat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 250,
                        child: Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomText(
                      text: product.title,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 12),
                    Chip(label: Text(product.category)),
                    const SizedBox(height: 8),
                    CustomText(
                      text: '\$${product.price.toStringAsFixed(2)}',
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                    const SizedBox(height: 20),
                    const CustomText(
                      text: 'Description',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    CustomText(text: product.description, fontSize: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cartProvider.isLoading
                    ? null
                    : () async {
                        // Enhancement 3: add the selected product to the cart using DummyJSON add-to-cart endpoint.
                        await context.read<CartProvider>().addToCart(
                          userId: 1,
                          products: [
                            {'id': product.id, 'quantity': 1},
                          ],
                        );

                        if (context.mounted) {
                          final message =
                              context.read<CartProvider>().errorMessage == null
                              ? 'Added ${product.title} to cart.'
                              : context.read<CartProvider>().errorMessage!;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  cartProvider.isLoading ? 'Adding...' : 'Add to Cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
