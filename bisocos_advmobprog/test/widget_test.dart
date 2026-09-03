import 'package:bisocos_advmobprogay2627/main.dart';
import 'package:bisocos_advmobprogay2627/models/product_model.dart';
import 'package:bisocos_advmobprogay2627/providers/cart_provider.dart';
import 'package:bisocos_advmobprogay2627/providers/theme_provider.dart';
import 'package:bisocos_advmobprogay2627/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app renders the product home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
    expect(find.text('Products API'), findsOneWidget);
  });

  testWidgets('product detail screen shows add to cart action', (tester) async {
    final product = ProductModel(
      id: 42,
      title: 'Test Product',
      price: 25.0,
      description: 'description',
      category: 'electronics',
      image: 'https://example.com/image.jpg',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(home: ProductDetailScreen(product: product)),
      ),
    );

    expect(find.text('Add to Cart'), findsOneWidget);
  });
}
