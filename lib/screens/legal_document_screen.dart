import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';

enum LegalDocType { privacyPolicy, termsOfService }

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocType docType;

  const LegalDocumentScreen({super.key, required this.docType});

  String get _title =>
      docType == LegalDocType.privacyPolicy ? 'Privacy Policy' : 'Terms of Service';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.pureBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.pureBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: docType == LegalDocType.privacyPolicy
            ? _PrivacyPolicyContent(context)
            : _TermsOfServiceContent(context),
      ),
    );
  }
}

Widget _PrivacyPolicyContent(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lastUpdated(context, 'May 13, 2026'),
      _intro(context,
          'the static ("we", "us", "our") is committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, and your rights as a user.'),
      _section(context, '1. Information We Collect', [
        _bullet(context, 'Account Data', 'Your name, handle, and email address when you register.'),
        _bullet(context, 'Audio Confessions', 'Voice recordings you choose to upload or record within the app.'),
        _bullet(context, 'Usage Data', 'App interactions, playback history, and device identifiers collected via Firebase Analytics.'),
        _bullet(context, 'Crash Reports', 'Anonymized crash logs collected by Firebase Crashlytics to improve reliability.'),
        _bullet(context, 'Payment Data', 'Subscription purchases are handled entirely by RevenueCat and the App Store / Google Play. We never store your payment card information.'),
      ]),
      _section(context, '2. How We Use Your Information', [
        _point(context, 'To provide and improve the app experience.'),
        _point(context, 'To send push notifications about activity on your confessions.'),
        _point(context, 'To manage your subscription status via RevenueCat.'),
        _point(context, 'To analyze usage patterns and fix bugs.'),
        _point(context, 'We never sell your personal data to third parties.'),
      ]),
      _section(context, '3. Data Storage & Security', [
        _point(context, 'Your data is stored securely using Firebase (Google Cloud infrastructure).'),
        _point(context, 'Audio files are encrypted at rest and in transit.'),
        _point(context, 'Your listen history is stored locally on your device using an encrypted SQLite database.'),
      ]),
      _section(context, '4. Third-Party Services', [
        _bullet(context, 'Firebase', 'Analytics, Crashlytics, Remote Config, and Cloud Messaging by Google.'),
        _bullet(context, 'RevenueCat', 'In-app subscription management. Subject to RevenueCat\'s Privacy Policy.'),
        _bullet(context, 'App Store / Google Play', 'Purchase validation by Apple or Google.'),
      ]),
      _section(context, '5. Your Rights', [
        _point(context, 'You may request deletion of your account and all associated data at any time by contacting us.'),
        _point(context, 'You may export or request a copy of your data.'),
        _point(context, 'You may opt out of analytics tracking in device settings.'),
      ]),
      _section(context, '6. Children\'s Privacy', [
        _point(context, 'the static is not intended for users under 13 years of age. We do not knowingly collect personal data from children.'),
      ]),
      _section(context, '7. Changes to This Policy', [
        _point(context, 'We may update this Privacy Policy periodically. Continued use of the app after changes constitutes acceptance of the updated policy.'),
      ]),
      _section(context, '8. Contact Us', [
        _point(context, 'For any questions or data requests, contact us at: privacy@thestatic.app'),
      ]),
    ],
  );
}

Widget _TermsOfServiceContent(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _lastUpdated(context, 'May 13, 2026'),
      _intro(context,
          'These Terms of Service govern your use of the static app. By using the app, you agree to be bound by these terms.'),
      _section(context, '1. Eligibility', [
        _point(context, 'You must be at least 13 years of age to use the static.'),
        _point(context, 'By creating an account, you confirm that the information you provide is accurate and complete.'),
      ]),
      _section(context, '2. User Content', [
        _point(context, 'You retain full ownership of all audio confessions and content you upload.'),
        _point(context, 'By uploading content, you grant us a non-exclusive, royalty-free license to display it to other users within the app.'),
        _point(context, 'You are solely responsible for the content you share. Do not upload content that is illegal, hateful, or violates the rights of others.'),
      ]),
      _section(context, '3. Prohibited Conduct', [
        _point(context, 'Harassment, threats, or abuse directed at other users.'),
        _point(context, 'Uploading content that infringes third-party copyrights or trademarks.'),
        _point(context, 'Attempting to access, scrape, or disrupt our backend systems.'),
        _point(context, 'Creating multiple accounts to circumvent a ban.'),
      ]),
      _section(context, '4. Subscriptions & Payments', [
        _point(context, 'the static Pro is an auto-renewing subscription billed through the App Store or Google Play.'),
        _point(context, 'Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current billing period.'),
        _point(context, 'You can manage or cancel your subscription at any time through your App Store or Google Play account settings.'),
        _point(context, 'No refunds are provided for partial subscription periods, except as required by applicable law.'),
      ]),
      _section(context, '5. Account Termination', [
        _point(context, 'We reserve the right to suspend or terminate your account at any time for violations of these Terms.'),
        _point(context, 'You may delete your account at any time from within the app settings.'),
      ]),
      _section(context, '6. Disclaimers', [
        _point(context, 'the static is provided "as is" without warranties of any kind.'),
        _point(context, 'We are not liable for any indirect, incidental, or consequential damages arising from your use of the app.'),
      ]),
      _section(context, '7. Governing Law', [
        _point(context, 'These Terms are governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in India.'),
      ]),
      _section(context, '8. Contact', [
        _point(context, 'For questions about these Terms, contact us at: legal@thestatic.app'),
      ]),
    ],
  );
}

Widget _lastUpdated(BuildContext context, String date) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Last updated: $date',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
      ),
    );

Widget _intro(BuildContext context, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
      ),
    );

Widget _section(BuildContext context, String heading, List<Widget> items) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );

Widget _point(BuildContext context, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );

Widget _bullet(BuildContext context, String label, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6, color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );

Future<void> openLegalUrl(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}
