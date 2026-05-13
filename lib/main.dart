import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/subscription_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.instance.initialize();
    await SubscriptionService.instance.initialize();
    await RemoteConfigService.instance.initialize();

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
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
