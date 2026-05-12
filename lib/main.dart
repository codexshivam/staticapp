import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ConfessionsApp());
}

class ConfessionsApp extends StatelessWidget {
  const ConfessionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'the static',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
