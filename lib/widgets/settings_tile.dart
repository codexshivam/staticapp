import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? AppColors.accentRed : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.accentRed : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: leadingIcon != null
            ? Icon(
                leadingIcon,
                color: iconColor,
                size: 20,
              )
            : null,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: isDestructive ? AppColors.accentRed.withOpacity(0.5) : AppColors.textSecondary,
              size: 18,
            ),
      ),
    );
  }
}
