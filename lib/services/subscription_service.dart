import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'firebase/firebase_db_service.dart';
import 'auth_state_service.dart';
import 'remote_config_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/premium_paywall_screen.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._init();
  SubscriptionService._init();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialized = false;
  bool _isPro = false;
  final StreamController<bool> _proStatusController = StreamController<bool>.broadcast();

  static String get _androidKey => dotenv.env['REVENUECAT_ANDROID_KEY'] ?? 'goog_yTGrCFLGYSwwEJkapVcmHHkZYxG';
  static String get _iosKey => dotenv.env['REVENUECAT_IOS_KEY'] ?? 'test_dqUqZKVCRZxyjcGymsxZQGRxHJf';

  Future<void> initialize({String? userId}) async {
    if (_initialized) return;
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        final apiKey = Platform.isIOS ? _iosKey : _androidKey;
        final configuration = PurchasesConfiguration(apiKey);
        if (userId != null && userId.isNotEmpty) {
          configuration.appUserID = userId;
        }
        await Purchases.configure(configuration);
        
        Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
        await _checkCustomerInfo();

        _initialized = true;
        debugPrint('RevenueCat SDK initialized successfully');
      } else {
        debugPrint('Platform not supported by RevenueCat');
      }
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) async {
    final hasPro = customerInfo.entitlements.active.containsKey('TheStatic Pro') || customerInfo.entitlements.active.isNotEmpty;
    if (_isPro != hasPro) {
      _isPro = hasPro;
      _proStatusController.add(_isPro);

      try {
        final currentUser = AuthStateService.instance.currentUser;
        if (currentUser != null) {
          final updated = currentUser.copyWith(isPro: _isPro);
          AuthStateService.instance.updateUser(updated);
          await FirebaseDbService.instance.updateUserProfile(updated);
        }
      } catch (_) {}
    }
  }

  Future<void> _checkCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _onCustomerInfoUpdated(customerInfo);
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
    }
  }

  Future<void> checkCustomerInfoNow() async {
    await _checkCustomerInfo();
  }

  bool get isPro => _isPro;

  Stream<bool> get proStatusStream => _proStatusController.stream;

  Future<PaywallResult?> showPaywall({BuildContext? context}) async {
    final targetContext = context ?? navigatorKey.currentContext;
    if (targetContext != null && targetContext.mounted) {
      final result = await Navigator.push(
        targetContext,
        MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
      );
      if (result == true) {
        return PaywallResult.purchased;
      }
      return PaywallResult.cancelled;
    }

    if (!_initialized) {
      debugPrint('RevenueCat not initialized, cannot show paywall');
      return null;
    }
    try {
      final paywallResult = await RevenueCatUI.presentPaywall(displayCloseButton: true);
      await _checkCustomerInfo();
      return paywallResult;
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  Future<void> restorePurchases() async {
    if (!_initialized) return;
    try {
      final customerInfo = await Purchases.restorePurchases();
      _onCustomerInfoUpdated(customerInfo);
    } catch (e) {
      debugPrint('Restore purchases failed: $e');
    }
  }

  Future<void> updateUserId(String? userId) async {
    if (!_initialized || userId == null || userId.isEmpty) return;
    try {
      final logInResult = await Purchases.logIn(userId);
      _onCustomerInfoUpdated(logInResult.customerInfo);
    } catch (e) {
      debugPrint('Update userId failed: $e');
    }
  }

  Future<bool> canPlayConfession() async {
    if (!RemoteConfigService.instance.isSubscriptionEnabled) {
      return true;
    }

    if (isPro) {
      return true;
    }

    try {
      final currentUser = AuthStateService.instance.currentUser;
      if (currentUser == null) return true;

      AppUser? profile = await FirebaseDbService.instance.getUserProfile(currentUser.id);
      profile ??= currentUser;

      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (profile.lastPlaybackDate == currentDate) {
        return profile.dailyPlaybackCount < 1;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('Offline/Error limit bypass grace: $e');
      return true;
    }
  }

  Future<void> incrementDailyPlaybackCount() async {
    if (isPro || !RemoteConfigService.instance.isSubscriptionEnabled) return;

    try {
      final currentUser = AuthStateService.instance.currentUser;
      if (currentUser == null) return;

      AppUser? profile = await FirebaseDbService.instance.getUserProfile(currentUser.id);
      profile ??= currentUser;

      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      if (profile.lastPlaybackDate == currentDate) {
        final updated = profile.copyWith(dailyPlaybackCount: profile.dailyPlaybackCount + 1);
        AuthStateService.instance.updateUser(updated);
        await FirebaseDbService.instance.updateUserProfile(updated);
      } else {
        final updated = profile.copyWith(lastPlaybackDate: currentDate, dailyPlaybackCount: 1);
        AuthStateService.instance.updateUser(updated);
        await FirebaseDbService.instance.updateUserProfile(updated);
      }
    } catch (e) {
      debugPrint('Error incrementing playback count: $e');
    }
  }

  void dispose() {
    _proStatusController.close();
  }
}
