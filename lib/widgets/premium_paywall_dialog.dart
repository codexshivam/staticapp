import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/subscription_service.dart';

class PremiumPaywallDialog extends StatelessWidget {
  const PremiumPaywallDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PremiumPaywallDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Daily Playback Limit Reached',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.pureBlack,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Free members can listen to 1 confession per day. Upgrade to Premium to unlock unlimited listening!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBenefitRow(
                    Icons.favorite_rounded,
                    'Support an Individual Developer',
                    'Directly support the journey of an independent developer building and maintaining this platform.',
                  ),
                  const SizedBox(height: 14),
                  _buildBenefitRow(
                    Icons.block_flipped,
                    'Zero Intrusive Ads',
                    'Enjoy a clean, focused, and beautifully crafted authentic audio experience with absolutely no ads.',
                  ),
                  const SizedBox(height: 14),
                  _buildBenefitRow(
                    Icons.bolt_rounded,
                    'Fund Future Innovation',
                    'Help fuel the creation of new features, better audio rendering, and advanced privacy controls.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SubscriptionService.instance.showPaywall();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pureBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Unlock Unlimited Access',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade500,
              ),
              child: const Text(
                'Maybe Later',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.pureBlack, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pureBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
