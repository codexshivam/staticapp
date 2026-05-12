import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user.dart';

class UserListTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;
  final bool isFollowing;
  final VoidCallback? onActionTap;

  const UserListTile({
    super.key,
    required this.user,
    this.onTap,
    this.isFollowing = false,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: Text(
            user.initials,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        title: Text(
          user.displayName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          user.handle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: onActionTap != null
            ? OutlinedButton(
                onPressed: onActionTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  backgroundColor: isFollowing ? Colors.transparent : AppColors.pureBlack,
                  foregroundColor: isFollowing ? AppColors.pureBlack : AppColors.cardBg,
                  side: BorderSide(
                    color: isFollowing ? AppColors.divider : AppColors.pureBlack,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                ),
              )
            : const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 16,
              ),
      ),
    );
  }
}
