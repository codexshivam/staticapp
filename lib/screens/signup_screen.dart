import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../core/theme/app_colors.dart';
import '../services/appwrite/appwrite_auth_service.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';
import 'legal_document_screen.dart';
import 'main_navigation_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  Timer? _debounceTimer;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _usernameErrorText;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _usernameController.text.trim().replaceAll('@', '');
    _debounceTimer?.cancel();

    if (text.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
        _usernameErrorText = null;
      });
      return;
    }

    if (text.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameErrorText = 'Username must be at least 3 characters';
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(text)) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameErrorText = 'Only letters, numbers, and underscores allowed';
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
      _usernameErrorText = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      try {
        final handle = '@$text';
        final available = await AppwriteDbService.instance.checkHandleAvailable(handle);
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = available;
            _usernameErrorText = available ? null : 'This username is already taken';
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            _isUsernameAvailable = null;
            _usernameErrorText = null;
          });
        }
      }
    });
  }

  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim().replaceAll('@', '');
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('Please enter a username', isError: true);
      return;
    }
    if (_isCheckingUsername) {
      _showSnackBar('Still validating your username...', isError: false);
      return;
    }
    if (_isUsernameAvailable != true) {
      _showSnackBar('Please choose an available username', isError: true);
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newUser = await AppwriteAuthService.instance.signUp(
        email: email,
        password: password,
        displayName: username,
        username: username,
        bio: bio,
      );

      if (newUser == null) throw Exception('Account creation failed');

      final sessionUser = await AppwriteAuthService.instance.getCurrentSessionUser();
      AuthStateService.instance.setUser(newUser, email: sessionUser?.email ?? email);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
          (route) => false,
        );
        _showSnackBar('Account created successfully! Welcome ❤️');
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Widget? _buildUsernameSuffix() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(14.0),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureBlack),
        ),
      );
    }
    if (_isUsernameAvailable == true) {
      return const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.error_outline_rounded, color: AppColors.accentRed, size: 20);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 75.0,
        leading: IconButton(
          icon: const Icon(Feather.x, size: 30.0, color: Color.fromARGB(255, 71, 71, 71)),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: AppColors.pureBlack,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Create your profile to start your journey.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 35),
              TextField(
                controller: _usernameController,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Your unique @handle',
                  hintText: 'e.g. dreamer',
                  prefixText: '@',
                  suffixIcon: _buildUsernameSuffix(),
                  helperText: _isUsernameAvailable == true ? 'Username is available.' : null,
                  helperStyle: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                  errorText: _usernameErrorText,
                  errorStyle: const TextStyle(color: AppColors.accentRed, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. dreamer@helloworld.com',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 14),
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
              const SizedBox(height: 14),
              TextField(
                controller: _bioController,
                maxLines: 2,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Short Bio (optional)',
                  hintText: 'e.g. welcome to my voice confessions diary...',
                ),
              ),
              const SizedBox(height: 16),
              _LegalConsentText(context),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('SIGN UP'),
              ),
              const SizedBox(height: 27.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Log in',
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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.6),
      children: [
        const TextSpan(text: 'By signing up, you agree to our\n'),
        TextSpan(
          text: 'Terms of Service',
          style: const TextStyle(decoration: TextDecoration.underline, color: AppColors.pureBlack, fontWeight: FontWeight.w600),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalDocumentScreen(docType: LegalDocType.termsOfService)),
                ),
        ),
        const TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy',
          style: const TextStyle(decoration: TextDecoration.underline, color: AppColors.pureBlack, fontWeight: FontWeight.w600),
          recognizer: TapGestureRecognizer()
            ..onTap = () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalDocumentScreen(docType: LegalDocType.privacyPolicy)),
                ),
        ),
        const TextSpan(text: '.'),
      ],
    ),
  );
}
