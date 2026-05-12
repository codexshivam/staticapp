import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user.dart';
import '../models/confession.dart';
import '../mock_data/sample_data.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import 'followers_screen.dart';
import 'confession_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser? user;

  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser _activeUser;
  late bool _isMe;

  @override
  void initState() {
    super.initState();
    _loadUserState();
  }

  void _loadUserState() {
    _activeUser = widget.user ?? SampleData.currentUser;
    _isMe = _activeUser.id == SampleData.currentUser.id;
  }

  void _openDetail(Confession confession) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
  }

  void _openFollowersScreen(bool showFollowers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          user: _isMe ? SampleData.currentUser : _activeUser,
          initialShowFollowers: showFollowers,
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (updated == true) {
      setState(() {
        _loadUserState();
      });
    }
  }

  void _toggleFollow() {
    final currentlyFollowing = SampleData.followingList.any((u) => u.id == _activeUser.id);
    
    setState(() {
      if (currentlyFollowing) {
        // Unfollow
        SampleData.followingList.removeWhere((u) => u.id == _activeUser.id);
        _activeUser = _activeUser.copyWith(
          followersCount: _activeUser.followersCount - 1,
        );
        // Update in global mockUsers pool to persist selection
        final idx = SampleData.mockUsers.indexWhere((u) => u.id == _activeUser.id);
        if (idx != -1) {
          SampleData.mockUsers[idx] = _activeUser;
        }
      } else {
        // Follow
        SampleData.followingList.add(_activeUser);
        _activeUser = _activeUser.copyWith(
          followersCount: _activeUser.followersCount + 1,
        );
        // Update in global mockUsers pool to persist selection
        final idx = SampleData.mockUsers.indexWhere((u) => u.id == _activeUser.id);
        if (idx != -1) {
          SampleData.mockUsers[idx] = _activeUser;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentlyFollowing ? 'Unfollowed ${_activeUser.displayName}' : 'Following ${_activeUser.displayName}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = _isMe ? SampleData.currentUser : _activeUser;
    
    // Filter confessions uploaded by this user
    final userConfessions = SampleData.mockConfessions
        .where((c) => c.authorId == displayUser.id)
        .toList();

    final isFollowingThisUser = SampleData.followingList.any((u) => u.id == displayUser.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: !_isMe
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.pureBlack),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          _isMe ? 'My Profile' : '${displayUser.displayName}\'s Profile',
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
            // 1. TOP PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: AppColors.divider),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row with Initials Avatar & Name
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayUser.initials,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pureBlack,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayUser.displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayUser.handle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Bio Description
                  Text(
                    displayUser.bio,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  // Optional Links section
                  if (displayUser.links.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: displayUser.links.map((link) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  link.replaceFirst('https://', ''),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.pureBlack,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(context, 'Confessions', '${userConfessions.length}'),
                      _buildVerticalDivider(),
                      GestureDetector(
                        onTap: () => _openFollowersScreen(true),
                        child: _buildStatColumn(context, 'Followers', '${displayUser.followersCount}'),
                      ),
                      _buildVerticalDivider(),
                      GestureDetector(
                        onTap: () => _openFollowersScreen(false),
                        child: _buildStatColumn(context, 'Following', '${displayUser.followingCount}'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  
                  // Primary Action Button (Edit Profile / Follow-Unfollow)
                  if (_isMe) ...[
                    OutlinedButton(
                      onPressed: _navigateToEditProfile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        side: const BorderSide(color: AppColors.pureBlack, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        'EDIT PROFILE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pureBlack,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowingThisUser ? AppColors.background : AppColors.pureBlack,
                        foregroundColor: isFollowingThisUser ? AppColors.pureBlack : AppColors.cardBg,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: isFollowingThisUser ? const BorderSide(color: AppColors.divider) : BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isFollowingThisUser ? 'UNFOLLOW' : 'FOLLOW',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFollowingThisUser ? AppColors.pureBlack : AppColors.cardBg,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. LIST OF USER CONFESSIONS
            SectionTitle(
              title: _isMe ? 'My Confessions ❤️' : '${displayUser.displayName}\'s Confessions ❤️',
              subtitle: 'Voice expressions',
            ),
            const SizedBox(height: 14),

            userConfessions.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Text(
                      'No confessions posted yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userConfessions.length,
                    itemBuilder: (context, index) {
                      final conf = userConfessions[index];
                      return ConfessionCard(
                        confession: conf,
                        onTap: () => _openDetail(conf),
                      );
                    },
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.pureBlack,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toLowerCase(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.divider,
    );
  }
}
