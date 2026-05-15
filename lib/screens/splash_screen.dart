import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_db_service.dart';
import '../services/auth_state_service.dart';
import 'login_screen.dart';
import 'main_navigation_shell.dart';
import '../services/subscription_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.95;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    Timer(const Duration(milliseconds: 2000), () {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    if (!mounted) return;

    final sessionUser = FirebaseAuthService.instance.getCurrentSessionUser();

    if (!mounted) return;

    if (sessionUser != null) {
      final profile = await FirebaseDbService.instance.getUserProfile(sessionUser.uid);
      if (!mounted) return;

      if (profile != null) {
        AuthStateService.instance.setUser(profile, email: sessionUser.email);
        await SubscriptionService.instance.updateUserId(sessionUser.uid);
        _navigateTo(const MainNavigationShell());
        return;
      }
    }

    _navigateTo(const LoginScreen());
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 850),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background),
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'thestatic ❤️',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: AppColors.pureBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'share and listen to the real voice confessions',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
