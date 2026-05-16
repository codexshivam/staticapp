import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../widgets/settings_tile.dart';
import '../models/user.dart';
import '../services/appwrite/appwrite_auth_service.dart';
import '../services/appwrite/appwrite_db_service.dart';
import '../services/auth_state_service.dart';
import '../services/subscription_service.dart';
import 'login_screen.dart';
import 'legal_document_screen.dart';
import 'change_email_screen.dart';
import 'change_username_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late String _currentHandle;
  late String _currentEmail;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthStateService.instance.currentUser;
    _currentHandle = currentUser?.handle ?? '@unknown';
    _currentEmail =
        AuthStateService.instance.sessionEmail ?? 'unknown@email.com';
    _setupRemoteConfig();
    _loadProStatus();
    WidgetsBinding.instance.addObserver(this);
    _checkEmailStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkEmailStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// With Appwrite, email changes are immediately committed — no verification flow.
  /// We reload the profile from the DB to pick up any changes.
  Future<void> _checkEmailStatus() async {
    try {
      final session = await AppwriteAuthService.instance
          .getCurrentSessionUser();
      if (session == null) return;
      final currentSessionUser = AuthStateService.instance.currentUser;
      if (currentSessionUser != null &&
          session.email != null &&
          currentSessionUser.email != session.email) {
        final updatedProfile = currentSessionUser.copyWith(
          email: session.email,
        );
        await AppwriteDbService.instance.updateUserProfile(updatedProfile);
        AuthStateService.instance.setUser(updatedProfile, email: session.email);
        if (mounted) {
          setState(() {
            _currentEmail = session.email!;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadProStatus() async {
    final currentUser = AuthStateService.instance.currentUser;
    await SubscriptionService.instance.initialize(
      userId: currentUser?.id ?? AppUser.fallbackUser.id,
    );
    if (mounted) {
      setState(() => _isPro = SubscriptionService.instance.isPro);
    }
    SubscriptionService.instance.proStatusStream.listen((isPro) {
      if (mounted) setState(() => _isPro = isPro);
    });
  }

  void _openLegalDocument(LegalDocType docType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LegalDocumentScreen(docType: docType),
      ),
    );
  }

  Future<void> _setupRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults(const {
        "privacy_policy_url": "https://codexshivam.github.io/privacy",
        "terms_of_service_url": "https://codexshivam.github.io/terms",
      });
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote config fetch failed: $e');
    }
  }

  void _editHandle() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) =>
            ChangeUsernameScreen(currentHandle: _currentHandle),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentHandle = result;
      });
    }
  }

  void _editEmail() async {
    await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ChangeEmailScreen(currentEmail: _currentEmail),
      ),
    );
  }

  void _changePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }



  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out? ❤️'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await AppwriteAuthService.instance.signOut();
              } catch (_) {}
              AuthStateService.instance.clearUser();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.pureBlack,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ACCOUNT SETTINGS',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              title: 'Edit Handle',
              subtitle: _currentHandle,
              leadingIcon: Icons.alternate_email_rounded,
              onTap: _editHandle,
            ),
            SettingsTile(
              title: 'Change Email',
              subtitle: _currentEmail,
              leadingIcon: Icons.email_outlined,
              onTap: _editEmail,
            ),
            SettingsTile(
              title: 'Change Password',
              subtitle: '••••••••',
              leadingIcon: Icons.lock_outline,
              onTap: _changePassword,
            ),

            const SizedBox(height: 24),

            Text(
              'SUBSCRIPTION',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPro
                      ? AppColors.accentRed.withValues(alpha: 0.5)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isPro
                          ? AppColors.accentRed.withValues(alpha: 0.1)
                          : AppColors.divider.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPro
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isPro
                          ? AppColors.accentRed
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPro ? 'Supporter' : 'Listener',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isPro
                              ? 'Thank you for supporting us! ❤️'
                              : 'Support the platform',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_isPro) {
                        final url = Platform.isIOS
                            ? 'https://apps.apple.com/account/subscriptions'
                            : 'https://play.google.com/store/account/subscriptions';
                        try {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          debugPrint('Could not launch subscription URL: $e');
                        }
                      } else {
                        final result = await SubscriptionService.instance
                            .showPaywall();
                        if (result == PaywallResult.purchased && mounted) {
                          setState(
                            () => _isPro = SubscriptionService.instance.isPro,
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isPro ? 'THANKS' : 'SUPPORT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'LEGAL',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              title: 'Privacy Policy',
              leadingIcon: Icons.policy_outlined,
              onTap: () => _openLegalDocument(LegalDocType.privacyPolicy),
            ),
            SettingsTile(
              title: 'Terms of Service',
              leadingIcon: Icons.gavel_outlined,
              onTap: () => _openLegalDocument(LegalDocType.termsOfService),
            ),

            const SizedBox(height: 32),

            SettingsTile(
              title: 'LOG OUT',
              leadingIcon: Icons.logout_outlined,
              isDestructive: true,
              trailing: const SizedBox.shrink(),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}

