import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bisocos_advmobprogay2627/main.dart';
import 'package:bisocos_advmobprogay2627/providers/theme_provider.dart';

void main() {
  testWidgets('app renders the product home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => ThemeProvider(), child: const MyApp()),
    );
    expect(find.text('Products API'), findsOneWidget);
  });
}
