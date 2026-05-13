import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../core/theme/app_colors.dart';
import 'main_navigation_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();

  Timer? _debounceTimer;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _usernameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _nameController.text.trim();

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

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
      _usernameErrorText = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      const takenUsernames = {
        'dreamer',
        'admin',
        'love',
        'secret',
        'confessor',
        'angel',
      };
      final isTaken = takenUsernames.contains(text.toLowerCase());

      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = !isTaken;
        _usernameErrorText = isTaken ? 'This username is already taken' : null;
      });
    });
  }

  void _handleSignup() {
    final username = _nameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isCheckingUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Still validating your username...'),
          backgroundColor: AppColors.pureBlack,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isUsernameAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose an available username'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: AppColors.pureBlack,
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.pureBlack,
          ),
        ),
      );
    }

    if (_isUsernameAvailable == true) {
      return const Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.green,
        size: 20,
      );
    }

    if (_isUsernameAvailable == false) {
      return const Icon(
        Icons.error_outline_rounded,
        color: AppColors.accentRed,
        size: 20,
      );
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
          icon: const Icon(
            Feather.x,
            size: 30.0,
            color: Color.fromARGB(255, 71, 71, 71),
          ),
          onPressed: () => Navigator.pop(context),
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
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Your unique username',
                  hintText: 'e.g. dreamer',
                  suffixIcon: _buildUsernameSuffix(),
                  helperText: _isUsernameAvailable == true
                      ? 'Username is available.'
                      : null,
                  helperStyle: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  errorText: _usernameErrorText,
                  errorStyle: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. dreamer@helloworld.com',
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _bioController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Short Bio',
                  hintText: 'e.g. welcome to my voice confessions diary...',
                ),
              ),

              const SizedBox(height: 27.50),

              ElevatedButton(
                onPressed: _handleSignup,
                child: const Text('SIGN UP'),
              ),

              const SizedBox(height: 27.50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
