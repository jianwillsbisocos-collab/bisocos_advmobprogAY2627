import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/constants.dart';
import '../models/product_model.dart';

class ProductService {
  // API Fetching - Fetch products from the host endpoint
  Future<List<ProductModel>> fetchProducts() async {
    try {
      // Get host dynamically (loads from .env or uses fallback)
      final apiUrl = getHost();
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // Handle dummyjson.com response (has 'products' key)
        final List<dynamic> productsList = data is Map
            ? data['products']
            : data;

        return productsList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load products (Status: ${response.statusCode})',
        );
      }
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }
}
