import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchase_service/purchase_service.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._init();
  SubscriptionService._init();

  final PurchasesService _purchases = PurchasesService();
  bool _initialized = false;

  static const String _androidKey = 'YOUR_REVENUECAT_ANDROID_KEY';
  static const String _iosKey = 'YOUR_REVENUECAT_IOS_KEY';

  Future<void> initialize({String? userId}) async {
    if (_initialized) return;
    try {
      final apiKey = Platform.isIOS ? _iosKey : _androidKey;
      await _purchases.initialize(
        apiKey: apiKey,
        userId: userId,
        observerMode: false,
      );
      _initialized = true;
      debugPrint('SubscriptionService initialized');
    } catch (e) {
      debugPrint('SubscriptionService init failed: $e');
    }
  }

  bool get isPro => _initialized ? _purchases.isPro : false;

  Stream<bool> get proStatusStream => _purchases.proStatusStream;

  Future<PaywallResult?> showPaywall() async {
    if (!_initialized) {
      debugPrint('SubscriptionService not initialized, cannot show paywall');
      return null;
    }
    try {
      return await _purchases.presentPaywallIfNeeded(
        entitlement: 'pro',
        showCloseButton: true,
      );
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  Future<void> restorePurchases() async {
    if (!_initialized) return;
    try {
      await _purchases.restorePurchases();
    } catch (e) {
      debugPrint('Restore purchases failed: $e');
    }
  }

  Future<void> updateUserId(String? userId) async {
    if (!_initialized) return;
    try {
      await _purchases.updateUserId(userId);
    } catch (e) {
      debugPrint('Update userId failed: $e');
    }
  }

  void dispose() => _purchases.dispose();
}
