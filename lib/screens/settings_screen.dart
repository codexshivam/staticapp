import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../core/theme/app_colors.dart';
import '../widgets/settings_tile.dart';
import '../mock_data/sample_data.dart';
import 'login_screen.dart';
import 'legal_document_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentName;
  late String _currentEmail;

  @override
  void initState() {
    super.initState();
    _currentName = SampleData.currentUser.displayName;
    _currentEmail = 'shivam@diary.com'; // Mock email
    _setupRemoteConfig();
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

  void _editProfileName() {
    final controller = TextEditingController(text: _currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          cursorColor: AppColors.pureBlack,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _currentName = newName;
                  SampleData.currentUser = SampleData.currentUser.copyWith(displayName: newName);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username updated successfully ❤️'),
                    backgroundColor: AppColors.pureBlack,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _editEmail() {
    final controller = TextEditingController(text: _currentEmail);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: TextField(
          controller: controller,
          cursorColor: AppColors.pureBlack,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email Address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newEmail = controller.text.trim();
              if (newEmail.isNotEmpty) {
                setState(() {
                  _currentEmail = newEmail;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification link sent to new email ❤️'),
                    backgroundColor: AppColors.pureBlack,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent! Check your inbox ❤️'),
                  backgroundColor: AppColors.pureBlack,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Link'),
          )
        ],
      ),
    );
  }

  void _openLegalDocument(String title, String remoteKey, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LegalDocumentScreen(
          title: title,
          remoteConfigKey: remoteKey,
          localAssetPath: assetPath,
        ),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                (route) => false,
              );
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
            // PROFILE SECTION
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
              title: 'Edit Username',
              subtitle: _currentName,
              leadingIcon: Icons.person_outline,
              onTap: _editProfileName,
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

            // SUBSCRIPTION SECTION
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
            SettingsTile(
              title: 'Premium Access',
              subtitle: '₹270 / \$8 per month',
              leadingIcon: Icons.star_border_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pureBlack,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'UPGRADE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RevenueCat purchase flow initiated... 🚀'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // LEGAL SECTION
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
              onTap: () => _openLegalDocument(
                'Privacy Policy', 
                'privacy_policy_text', 
                'assets/legal/privacy_policy.md'
              ),
            ),
            SettingsTile(
              title: 'Terms of Service',
              leadingIcon: Icons.gavel_outlined,
              onTap: () => _openLegalDocument(
                'Terms of Service', 
                'terms_of_service_text', 
                'assets/legal/terms_of_service.md'
              ),
            ),

            const SizedBox(height: 32),

            // LOGOUT BUTTON
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
