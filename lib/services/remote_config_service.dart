import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._init();
  RemoteConfigService._init();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(const {
        'is_subscription_enabled': true,
        'refund_policy_url': 'https://support.google.com/googleplay/answer/2479637',
      });
      await _remoteConfig.fetchAndActivate();
      debugPrint('RemoteConfigService initialized');
    } catch (e) {
      debugPrint('RemoteConfigService init failed: $e');
    }
  }

  bool get isSubscriptionEnabled {
    try {
      return _remoteConfig.getBool('is_subscription_enabled');
    } catch (_) {
      return true;
    }
  }

  String get refundPolicyUrl {
    try {
      final url = _remoteConfig.getString('refund_policy_url');
      return url.isNotEmpty ? url : 'https://support.google.com/googleplay/answer/2479637';
    } catch (_) {
      return 'https://support.google.com/googleplay/answer/2479637';
    }
  }

  Future<void> updateCountryTargeting(String countryCode) async {
    try {
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'country',
        value: countryCode,
      );
      await _remoteConfig.fetchAndActivate();
      debugPrint('Country targeting updated to: $countryCode');
    } catch (e) {
      debugPrint('Error updating country targeting: $e');
    }
  }
}
