import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/settings_tile.dart';
import '../mock_data/sample_data.dart';
import '../models/user.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _currentName;
  late String _currentEmail;
  late String _currentUpi;

  @override
  void initState() {
    super.initState();
    _currentName = SampleData.currentUser.displayName;
    _currentEmail = 'shivam@diary.com'; // Mock email
    _currentUpi = SampleData.currentUser.upiId;
  }

  void _editProfileName() {
    final controller = TextEditingController(text: _currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pen Name'),
        content: TextField(
          controller: controller,
          cursorColor: AppColors.pureBlack,
          decoration: const InputDecoration(labelText: 'Pen Name'),
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
                  // Update global user model
                  SampleData.currentUser = AppUser(
                    id: SampleData.currentUser.id,
                    displayName: newName,
                    handle: SampleData.currentUser.handle,
                    bio: SampleData.currentUser.bio,
                    followersCount: SampleData.currentUser.followersCount,
                    followingCount: SampleData.currentUser.followingCount,
                    confessionCount: SampleData.currentUser.confessionCount,
                    upiId: SampleData.currentUser.upiId,
                    links: SampleData.currentUser.links,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pen Name updated successfully ❤️'),
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
        title: const Text('Update Secret Email'),
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
                    content: Text('Secret Email updated successfully ❤️'),
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

  void _editUpiId() {
    final controller = TextEditingController(text: _currentUpi);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set UPI ID'),
        content: TextField(
          controller: controller,
          cursorColor: AppColors.pureBlack,
          decoration: const InputDecoration(
            labelText: 'UPI address',
            hintText: 'e.g. yourname@upi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUpi = controller.text.trim();
              if (newUpi.isNotEmpty) {
                setState(() {
                  _currentUpi = newUpi;
                  // Update global user model
                  SampleData.currentUser = AppUser(
                    id: SampleData.currentUser.id,
                    displayName: SampleData.currentUser.displayName,
                    handle: SampleData.currentUser.handle,
                    bio: SampleData.currentUser.bio,
                    followersCount: SampleData.currentUser.followersCount,
                    followingCount: SampleData.currentUser.followingCount,
                    confessionCount: SampleData.currentUser.confessionCount,
                    upiId: newUpi,
                    links: SampleData.currentUser.links,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UPI ID details configured successfully ❤️'),
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

  void _showLegalDocs(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            'We value absolute anonymity and quiet storytelling above all else.\n\n'
            '1. All voice records are dynamically encrypted using local parameters before streaming.\n'
            '2. We never request your real name, identity markers, or social accounts.\n'
            '3. Any transactional UPI configurations represent direct peer-to-peer relationships—we take exactly 0% commission.\n\n'
            'Your letters belong solely to you, locked inside the sky of confessions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          )
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close your journal? ❤️'),
        content: const Text('Are you sure you want to log out and secure your anonymous diary keys?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Open'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Clear current route hierarchy and return to Login Screen
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
              'DIARY IDENTITIES',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              title: 'Edit Pen Name',
              subtitle: _currentName,
              leadingIcon: Icons.edit_outlined,
              onTap: _editProfileName,
            ),
            SettingsTile(
              title: 'Update Secret Email',
              subtitle: _currentEmail,
              leadingIcon: Icons.email_outlined,
              onTap: _editEmail,
            ),
            SettingsTile(
              title: 'Update Passcode',
              subtitle: '••••••••',
              leadingIcon: Icons.lock_outline,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passcode edit simulation triggered...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // BILLING SECTION
            Text(
              'UPI TIPPING SETUP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            SettingsTile(
              title: 'UPI Virtual Address',
              subtitle: _currentUpi.isEmpty ? 'Not set yet' : _currentUpi,
              leadingIcon: Icons.payment_outlined,
              onTap: _editUpiId,
            ),

            const SizedBox(height: 24),

            // LEGAL SECTION
            Text(
              'LEGAL DOCUMENTS',
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
              onTap: () => _showLegalDocs('Privacy Policy'),
            ),
            SettingsTile(
              title: 'Terms of Service',
              leadingIcon: Icons.gavel_outlined,
              onTap: () => _showLegalDocs('Terms of Service'),
            ),

            const SizedBox(height: 32),

            // LOGOUT BUTTON
            SettingsTile(
              title: 'Secure & Close Diary',
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
