import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Attempt Firebase initialization
    // Generate firebase_options.dart via CLI: flutterfire configure
    await Firebase.initializeApp();
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    debugPrint('Run `flutterfire configure` to connect your Firebase project.');
  }

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
