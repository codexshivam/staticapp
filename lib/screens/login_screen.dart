import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../core/theme/app_colors.dart';
import '../services/appwrite/appwrite_auth_service.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';
import 'legal_document_screen.dart';
import 'signup_screen.dart';
import 'main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter your email and password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AppwriteAuthService.instance.signIn(email: email, password: password);
      final sessionUser = await AppwriteAuthService.instance.getCurrentSessionUser();
      if (sessionUser == null) throw Exception('Session not found after login');

      final profile = await AppwriteDbService.instance.getUserProfile(sessionUser.$id);
      if (profile == null) throw Exception('Profile not found');

      AuthStateService.instance.setUser(profile, email: sessionUser.email);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0.0, 0.05), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 650),
          ),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Forgot Password ❤️',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);
              try {
                await AppwriteAuthService.instance.triggerPasswordReset(
                  email: email,
                  redirectUrl: 'https://confessions.app/reset',
                );
                if (mounted) _showSnackBar('Password reset link sent to your email ❤️');
              } catch (e) {
                if (mounted) _showSnackBar(e.toString(), isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Send Reset Link', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.pureBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome !',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: AppColors.pureBlack,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Log in to listen to confessions and share your voice with the world.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. hello@world.com',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _showForgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('LOG IN'),
              ),
              const SizedBox(height: 24),
              _LegalConsentText(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("First time here?", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const SignupScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                    FadeTransition(opacity: animation, child: child),
                                transitionDuration: const Duration(milliseconds: 350),
                              ),
                            ),
                    child: Text(
                      'Register your Account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureBlack,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _LegalConsentText(BuildContext context) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      children: [
        const TextSpan(text: 'By continuing, you agree to our\n'),
        TextSpan(
          text: 'Terms of Service',
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: AppColors.pureBlack,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentScreen(docType: LegalDocType.termsOfService),
                  ),
                ),
        ),
        const TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy',
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: AppColors.pureBlack,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentScreen(docType: LegalDocType.privacyPolicy),
                  ),
                ),
        ),
        const TextSpan(text: '.'),
      ],
    ),
  );
}
