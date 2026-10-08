import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'widgets/firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  final preferences = await SharedPreferences.getInstance();
  var firebaseReady = false;
  String? firebaseSetupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (error) {
    firebaseSetupError = error.toString();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider(create: (_) => UserService(preferences: preferences)),
        if (firebaseReady)
          ChangeNotifierProvider(
            create: (context) => AuthProvider(context.read<UserService>()),
          ),
      ],
      child: MyApp(
        firebaseReady: firebaseReady,
        firebaseSetupError: firebaseSetupError,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({this.firebaseReady = false, this.firebaseSetupError, super.key});

  final bool firebaseReady;
  final String? firebaseSetupError;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      home: firebaseReady
          ? const AuthGate()
          : FirebaseSetupScreen(error: firebaseSetupError),
    );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({this.error, super.key});

  final String? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'ShopSphere',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Firebase credentials are not configured for this app yet.',
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                const SelectableText(
                  'After installing Node.js and enabling Windows Developer Mode, '
                  'run:\n\nnpm install -g firebase-tools\nfirebase login\n'
                  'dart pub global run flutterfire_cli:flutterfire configure',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
