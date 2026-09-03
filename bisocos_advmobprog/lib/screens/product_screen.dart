import 'package:flutter/material.dart';
import '../widgets/constants.dart';
import '../models/product_model.dart';
import '../custom_text.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({required this.product, required this.onTap, super.key});
  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 3,
    shadowColor: Colors.black26,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              height: 82,
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.image_not_supported_outlined),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontSize: productTitleStyle.fontSize,
                    fontWeight: productTitleStyle.fontWeight,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: '\$${product.price.toStringAsFixed(2)}',
                    fontSize: productPriceStyle.fontSize,
                    fontWeight: productPriceStyle.fontWeight,
                    color: productPriceStyle.color,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
