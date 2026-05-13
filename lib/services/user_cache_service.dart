import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'firebase/firebase_db_service.dart';

class UserCacheService {
  static final UserCacheService instance = UserCacheService._init();
  UserCacheService._init();

  final Map<String, AppUser> _cache = {};
  final Map<String, Future<AppUser?>> _inflightRequests = {};

  /// Fetches an AppUser by ID. Checks the memory cache first to avoid N+1 query problems.
  Future<AppUser?> getUser(String userId) async {
    if (userId.isEmpty) return null;

    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }

    if (_inflightRequests.containsKey(userId)) {
      return await _inflightRequests[userId];
    }

    final future = FirebaseDbService.instance.getUserProfile(userId);
    _inflightRequests[userId] = future;

    try {
      final user = await future;
      if (user != null) {
        _cache[userId] = user;
      }
      return user;
    } catch (e) {
      debugPrint('Failed to fetch user $userId for cache: $e');
      return null;
    } finally {
      _inflightRequests.remove(userId);
    }
  }

  /// Manually update a cached user, for example, if the current user updates their profile.
  void updateCachedUser(AppUser user) {
    _cache[user.id] = user;
  }

  void clearCache() {
    _cache.clear();
    _inflightRequests.clear();
  }
}
