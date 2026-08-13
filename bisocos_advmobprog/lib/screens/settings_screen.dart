import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/theme_provider.dart';

// Enhancement 3: Settings page
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) { final themeProvider = context.watch<ThemeProvider>(); return Scaffold(appBar: AppBar(title: const Text(settingsTitle)), body: ListView(children: [SwitchListTile(title: const Text('Dark Mode'), subtitle: const Text('Use the dark application theme'), secondary: const Icon(Icons.dark_mode_outlined), value: themeProvider.isDarkMode, onChanged: (_) => themeProvider.toggleTheme())])); }
}
