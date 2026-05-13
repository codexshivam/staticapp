import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../mock_data/sample_data.dart';

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

  @override
  void initState() {
    super.initState();
    final user = SampleData.currentUser;
    _nameController = TextEditingController(text: user.displayName);
    _bioController = TextEditingController(text: user.bio);

    final l1 = user.links.isNotEmpty ? user.links[0] : '';
    final l2 = user.links.length > 1 ? user.links[1] : '';

    _link1Controller = TextEditingController(text: l1);
    _link2Controller = TextEditingController(text: l2);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _link1Controller.dispose();
    _link2Controller.dispose();
    super.dispose();
  }

  void _saveProfile() {
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

    final List<String> updatedLinks = [];
    if (l1.isNotEmpty) updatedLinks.add(l1);
    if (l2.isNotEmpty) updatedLinks.add(l2);

    // Update global state
    SampleData.currentUser = SampleData.currentUser.copyWith(
      displayName: name,
      bio: bio,
      links: updatedLinks,
    );

    Navigator.of(context).pop(true); // Signal profile has changed

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully ❤️'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
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
          icon: const Icon(Icons.close_rounded, color: AppColors.pureBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.pureBlack,
                letterSpacing: 0.5,
              ),
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

            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your name...',
              ),
            ),
            const SizedBox(height: 20),

            // Bio field
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell others about yourself...',
              ),
            ),
            const SizedBox(height: 20),

            // Link 1 field
            TextField(
              controller: _link1Controller,
              decoration: const InputDecoration(
                labelText: 'Link 01',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 20),

            // Link 2 field
            TextField(
              controller: _link2Controller,
              decoration: const InputDecoration(
                labelText: 'Link 02',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
