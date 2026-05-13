import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../widgets/settings_tile.dart';
import '../mock_data/sample_data.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/auth_state_service.dart';
import '../services/subscription_service.dart';
import 'login_screen.dart';
import 'legal_document_screen.dart';
import 'change_email_screen.dart';
import 'change_username_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentHandle;
  late String _currentEmail;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthStateService.instance.currentUser;
    _currentHandle = currentUser?.handle ?? '@unknown';
    _currentEmail = AuthStateService.instance.sessionEmail ?? 'unknown@email.com';
    _setupRemoteConfig();
    _loadProStatus();
  }

  Future<void> _loadProStatus() async {
    await SubscriptionService.instance.initialize(
      userId: SampleData.currentUser.id,
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
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults(const {
        "privacy_policy_url": "https://codexshivam.github.io/privacy",
        "terms_of_service_url": "https://codexshivam.github.io/terms"
      });
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote config fetch failed: $e');
    }
  }

  void _editHandle() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ChangeUsernameScreen(currentHandle: _currentHandle),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentHandle = result;
      });
    }
  }

  void _editEmail() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ChangeEmailScreen(currentEmail: _currentEmail),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _currentEmail = result;
      });
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('We will send a password reset link to your email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuthService.instance.triggerPasswordReset(
                  email: _currentEmail,
                  redirectUrl: 'https://confessions.app/reset',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent! Check your inbox ❤️'), backgroundColor: AppColors.pureBlack, behavior: SnackBarBehavior.floating));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
                }
              }
            },
            child: const Text('Send Link'),
          )
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out? ❤️'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuthService.instance.signOut();
              } catch (_) {}
              AuthStateService.instance.clearUser();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            child: const Text('Log out'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  color: _isPro ? AppColors.accentRed.withValues(alpha: 0.5) : AppColors.divider,
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
                      _isPro ? Icons.verified_rounded : Icons.star_border_rounded,
                      color: _isPro ? AppColors.accentRed : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPro ? 'the static Pro' : 'Free Plan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isPro
                              ? 'Your subscription is active'
                              : 'Upgrade to unlock all features',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } catch (e) {
                          debugPrint('Could not launch subscription URL: $e');
                        }
                      } else {
                        final result = await SubscriptionService.instance.showPaywall();
                        if (result != null && mounted) {
                          setState(() => _isPro = SubscriptionService.instance.isPro);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isPro ? 'MANAGE' : 'UPGRADE',
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
