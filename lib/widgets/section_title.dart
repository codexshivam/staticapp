import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTrailingTap;
  final String? trailingText;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onTrailingTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null && onTrailingTap != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.pureBlack,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
