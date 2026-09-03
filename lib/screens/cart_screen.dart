import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../providers/cart_provider.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const int _userId = 1;

  @override
  void initState() {
    super.initState();

    // Enhancement 3: load a single user's cart using the user ID endpoint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCartByUserId(_userId);
    });
  }

  Future<void> _refreshCartList() async {
    await context.read<CartProvider>().fetchCartByUserId(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: RefreshIndicator(
        onRefresh: _refreshCartList,
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            if (cartProvider.isLoading && cartProvider.currentCart == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cartProvider.errorMessage != null &&
                cartProvider.currentCart == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(cartProvider.errorMessage!),
                ),
              );
            }

            final cart = cartProvider.currentCart;
            if (cart == null) {
              return const Center(
                child: Text('No cart available for this user.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(
                      'Cart #${cart.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'User ${cart.userId} • ${cart.totalQuantity} items',
                    ),
                    trailing: Text(
                      '\$${cart.discountedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    onTap: () {
                      // Enhancement 1: pass the selected cart to the detail screen.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(cart: cart),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cart Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...cart.products.map((product) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Enhancement 1: each product row opens the cart detail screen.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(cart: cart),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: product.thumbnail.isNotEmpty
                                  ? Image.network(
                                      product.thumbnail,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                    )
                                  : const SizedBox(
                                      width: 64,
                                      height: 64,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Qty ${product.quantity} • Total \$${product.total.toStringAsFixed(2)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () {},
                                ),
                                Text('${product.quantity}'),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('\$${cart.total.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${cart.discountedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order confirmed.')),
                      );
                    },
                    child: const Text('Confirm Order'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // Enhancement 2: hide the floating action button when the user is on the cart screen.
      floatingActionButton: null,
    );
  }
}
