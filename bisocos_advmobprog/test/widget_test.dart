import 'package:bisocos_advmobprogay2627/main.dart';
import 'package:bisocos_advmobprogay2627/models/product_model.dart';
import 'package:bisocos_advmobprogay2627/providers/cart_provider.dart';
import 'package:bisocos_advmobprogay2627/providers/theme_provider.dart';
import 'package:bisocos_advmobprogay2627/screens/product_detail_screen.dart';
import 'package:bisocos_advmobprogay2627/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app renders the authentication splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          Provider(create: (_) => UserService(preferences: preferences)),
        ],
        child: const MyApp(),
      ),
    );
    expect(find.text('ShopSphere'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
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
