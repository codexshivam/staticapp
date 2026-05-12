import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user.dart';
import '../models/confession.dart';
import '../mock_data/sample_data.dart';
import '../widgets/section_title.dart';
import '../widgets/confession_card.dart';
import 'followers_screen.dart';
import 'confession_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser? user;

  const ProfileScreen({super.key, this.user});

  void _openDetail(BuildContext context, Confession confession) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfessionDetailScreen(confession: confession),
      ),
    );
  }

  void _openFollowersScreen(BuildContext context, bool showFollowers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          user: user ?? SampleData.currentUser,
          initialShowFollowers: showFollowers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = user ?? SampleData.currentUser;
    final isMe = activeUser.id == SampleData.currentUser.id;

    // Filter confessions uploaded by this user
    final userConfessions = SampleData.mockConfessions
        .where((c) => c.authorId == activeUser.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: !isMe
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.pureBlack),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          isMe ? 'My Secret Diary' : '${activeUser.displayName}\'s Diary',
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          activeUser.initials,
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
                              activeUser.displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeUser.handle,
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
                    activeUser.bio,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Subtle Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(context, 'Whispers', '${userConfessions.length}'),
                      _buildVerticalDivider(),
                      GestureDetector(
                        onTap: () => _openFollowersScreen(context, true),
                        child: _buildStatColumn(context, 'Followers', '${activeUser.followersCount}'),
                      ),
                      _buildVerticalDivider(),
                      GestureDetector(
                        onTap: () => _openFollowersScreen(context, false),
                        child: _buildStatColumn(context, 'Following', '${activeUser.followingCount}'),
                      ),
                    ],
                  ),

                  // Optional Links section
                  if (activeUser.links.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: activeUser.links.map((link) {
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. LIST OF USER CONFESSIONS
            SectionTitle(
              title: isMe ? 'My Recorded Secrets ❤️' : '${activeUser.displayName}\'s Whispers ❤️',
              subtitle: 'voices spoken late at night...',
            ),
            const SizedBox(height: 14),

            userConfessions.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Text(
                      'This diary is empty. No feelings have been spoken yet.',
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
                        onTap: () => _openDetail(context, conf),
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
