import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/firebase/firebase_db_service.dart';
import '../services/auth_state_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _link1Controller;
  late TextEditingController _link2Controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthStateService.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    final links = user?.links ?? [];
    _link1Controller = TextEditingController(text: links.isNotEmpty ? links[0] : '');
    _link2Controller = TextEditingController(text: links.length > 1 ? links[1] : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _link1Controller.dispose();
    _link2Controller.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final l1 = _link1Controller.text.trim();
    final l2 = _link2Controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final currentUser = AuthStateService.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final List<String> updatedLinks = [];
      if (l1.isNotEmpty) updatedLinks.add(l1);
      if (l2.isNotEmpty) updatedLinks.add(l2);

      final updatedUser = currentUser.copyWith(
        displayName: name,
        bio: bio,
        links: updatedLinks,
      );

      await FirebaseDbService.instance.updateUserProfile(updatedUser);
      await FirebaseAuthService.instance.updateName(displayName: name);

      AuthStateService.instance.updateUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully ❤️'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.pureBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.pureBlack),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureBlack),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pureBlack, letterSpacing: 0.5),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Display Name', hintText: 'Enter your name...'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              maxLines: 4,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Bio', hintText: 'Tell others about yourself...'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _link1Controller,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Link 01', hintText: 'https://...'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _link2Controller,
              enabled: !_isLoading,
              decoration: const InputDecoration(labelText: 'Link 02', hintText: 'https://...'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
