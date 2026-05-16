import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../core/theme/app_colors.dart';
import '../core/navigation/playback_manager.dart';
import '../models/confession.dart';
import '../models/user.dart';
import '../services/appwrite/appwrite_db_service.dart';

class ConfessionCard extends StatelessWidget {
  final Confession confession;
  final bool isHorizontal;
  final VoidCallback? onTap;

  const ConfessionCard({
    super.key,
    required this.confession,
    this.isHorizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pm = PlaybackManager();

    return ListenableBuilder(
      listenable: pm,
      builder: (context, _) {
        final isActive = pm.activeConfession?.id == confession.id;
        final isPlaying = isActive && pm.isPlaying;

        if (isHorizontal) {
          return _buildHorizontalCard(context, isActive, isPlaying, pm);
        } else {
          return _buildVerticalCard(context, isActive, isPlaying, pm);
        }
      },
    );
  }

  Widget _buildCoverArt(BuildContext context, double size, bool isPlaying, AppUser? author) {
    final initial = (author?.displayName.isNotEmpty ?? false)
        ? author!.displayName[0].toUpperCase()
        : 'C';

    return Skeleton.replace(
      width: size,
      height: size,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.pureBlack,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initial,
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(
    BuildContext context,
    bool isActive,
    bool isPlaying,
    PlaybackManager pm,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<AppUser?>(
        future: AppwriteDbService.instance.getUserProfile(confession.authorId),
        builder: (context, snapshot) {
          final author = snapshot.data;
          final authorName = author?.displayName ?? 'Anonymous';

          return SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverArt(context, 140, isPlaying, author),
                const SizedBox(height: 8),
                Text(
                  confession.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.accentRed : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$authorName • ${confession.durationString}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildVerticalCard(
    BuildContext context,
    bool isActive,
    bool isPlaying,
    PlaybackManager pm,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.0),
      child: FutureBuilder<AppUser?>(
        future: AppwriteDbService.instance.getUserProfile(confession.authorId),
        builder: (context, snapshot) {
          final author = snapshot.data;
          final authorName = author?.displayName ?? 'Anonymous';
          final timeAgo = _getRelativeTime(confession.listenedAt ?? confession.createdAt);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              children: [
                _buildCoverArt(context, 48, isPlaying, author),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confession.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? AppColors.accentRed
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$authorName • ${confession.durationString} • $timeAgo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(time);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
