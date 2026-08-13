import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/product_model.dart';
import '../widgets/custom_text.dart';

// Enhancement 2: Product detail page
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});
  final ProductModel product;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Product Details')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(child: SizedBox(height: 250, child: Image.network(product.image, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_outlined, size: 80)))),
    const SizedBox(height: 24), CustomText(text: product.title, fontSize: 22, fontWeight: FontWeight.bold), const SizedBox(height: 12), Chip(label: Text(product.category)), const SizedBox(height: 8),
    CustomText(text: '\$${product.price.toStringAsFixed(2)}', fontSize: 21, fontWeight: FontWeight.bold, color: secondaryColor), const SizedBox(height: 20), const CustomText(text: 'Description', fontSize: 18, fontWeight: FontWeight.w600), const SizedBox(height: 8), CustomText(text: product.description, fontSize: 16),
  ])))));
}
