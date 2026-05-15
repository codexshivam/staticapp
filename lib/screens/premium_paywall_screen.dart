import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  List<Package> _packages = [];
  Package? _selectedPackage;

  final List<Map<String, String>> _mockPackages = [
    {
      'identifier': 'monthly',
      'title': 'Monthly Pass',
      'price': '\$4.99',
      'period': 'per month',
      'description': 'Cancel anytime. Flexible access.',
    },
    {
      'identifier': 'annual',
      'title': 'Annual VIP',
      'price': '\$39.99',
      'period': 'per year',
      'description': 'Save 33% instantly. Best value.',
    },
  ];

  String _selectedMockIdentifier = 'annual';

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        _packages = offerings.current!.availablePackages;
        _selectedPackage = _packages.firstWhere(
          (pkg) => pkg.packageType == PackageType.annual,
          orElse: () => _packages.first,
        );
      }
    } catch (e) {
      debugPrint(
        'No live RevenueCat offerings found, using rich mock packages: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      if (_packages.isNotEmpty && _selectedPackage != null) {
        await Purchases.purchasePackage(_selectedPackage!);
        await SubscriptionService.instance.checkCustomerInfoNow();
      } else {
        throw Exception('No subscription plans available at the moment.');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Welcome to TheStatic Pro! All unlimited features unlocked.',
            ),
            backgroundColor: AppColors.pureBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase canceled / failed'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      await SubscriptionService.instance.restorePurchases();
      if (SubscriptionService.instance.isPro && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Purchases restored successfully!'),
            backgroundColor: AppColors.pureBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscription found to restore.'),
            backgroundColor: AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  Future<void> _launchRefundPolicy() async {
    final url = RemoteConfigService.instance.refundPolicyUrl;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open refund policy url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Feather.x, color: AppColors.pureBlack, size: 24),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          TextButton(
            onPressed: _isPurchasing ? null : _handleRestore,
            child: const Text(
              'Restore',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.pureBlack),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.pureBlack,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Icon(
                        Feather.award,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Unlock TheStatic Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pureBlack,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elevate your listening experience with limitless access to all confessions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Feature Checklist
                  _buildFeatureRow(
                    Feather.heart,
                    'Support Us',
                    'Directly support the journey us on building and maintaining this platform.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Feather.shield,
                    'Zero Intrusive Ads',
                    'Enjoy a clean, focused, and beautifully crafted authentic audio experience with absolutely no ads.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Feather.zap,
                    'Fund Future Innovation',
                    'Help fuel the creation of new features, better audio rendering, and advanced privacy controls.',
                  ),

                  const SizedBox(height: 36),
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Packages Grid/List
                  if (_packages.isNotEmpty)
                    ..._packages.map((pkg) => _buildLivePackageCard(pkg))
                  else
                    ..._mockPackages.map((mpkg) => _buildMockPackageCard(mpkg)),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isPurchasing ? null : _handlePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureBlack,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.pureBlack.withValues(alpha: 0.3),
                    ),
                    child: _isPurchasing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Continue & Subscribe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Subscriptions renew automatically. Cancel anytime in your App Store settings prior to renewal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: _launchRefundPolicy,
                      child: const Text(
                        'Refund & Cancellation Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.pureBlack,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.pureBlack, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pureBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLivePackageCard(Package pkg) {
    final isSelected = _selectedPackage?.identifier == pkg.identifier;
    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = pkg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? AppColors.pureBlack : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Feather.check_circle : Feather.circle,
              color: isSelected ? AppColors.pureBlack : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.packageType == PackageType.annual
                        ? 'Annual VIP'
                        : 'Monthly Pass',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pkg.storeProduct.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              pkg.storeProduct.priceString,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.pureBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockPackageCard(Map<String, String> pkg) {
    final isSelected = _selectedMockIdentifier == pkg['identifier'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMockIdentifier = pkg['identifier']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? AppColors.pureBlack : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Feather.check_circle : Feather.circle,
              color: isSelected ? AppColors.pureBlack : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg['title']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pkg['description']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pkg['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pureBlack,
                  ),
                ),
                Text(
                  pkg['period']!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
