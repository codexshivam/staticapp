import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user.dart';
import '../widgets/user_list_tile.dart';
import 'profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final AppUser user;
  final bool initialShowFollowers;

  const FollowersScreen({
    super.key,
    required this.user,
    required this.initialShowFollowers,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late bool _showFollowers;
  late List<AppUser> _followers;
  late List<AppUser> _following;

  @override
  void initState() {
    super.initState();
    _showFollowers = widget.initialShowFollowers;

    _followers = [AppUser.fallbackUser];
    _following = [AppUser.fallbackUser];
  }

  void _navigateToProfile(AppUser otherUser) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: otherUser),
      ),
    );
  }

  void _toggleFollowUser(AppUser otherUser, int index, bool isFollowersTab) {
    final isCurrentlyFollowing = _following.any((u) => u.id == otherUser.id);

    setState(() {
      if (isCurrentlyFollowing) {
        _following.removeWhere((u) => u.id == otherUser.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unfollowed ${otherUser.displayName} ❤️'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.pureBlack,
          ),
        );
      } else {
        _following.add(otherUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Followed ${otherUser.displayName}\'s diary ❤️'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.pureBlack,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _showFollowers ? _followers : _following;

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
          widget.user.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFollowers = true),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _showFollowers ? AppColors.pureBlack : Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Followers (${_followers.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _showFollowers ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFollowers = false),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !_showFollowers ? AppColors.pureBlack : Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Following (${_following.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !_showFollowers ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: activeList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: activeList.length,
                      itemBuilder: (context, index) {
                        final u = activeList[index];
                        final isFollowing = _following.any((user) => user.id == u.id);

                        return UserListTile(
                          user: u,
                          isFollowing: isFollowing,
                          onTap: () => _navigateToProfile(u),
                          onActionTap: () => _toggleFollowUser(u, index, _showFollowers),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, color: AppColors.textSecondary, size: 36),
          const SizedBox(height: 12),
          Text(
            _showFollowers ? 'no followers yet.' : 'not following anyone yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _showFollowers 
                ? 'some voices take time to attract listeners.' 
                : 'explore diaries and follow pages that touch you.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
