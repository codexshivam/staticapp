import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import '../../models/user.dart';
import '../../models/confession.dart';
import '../../models/comment.dart';
import 'appwrite_client.dart';

class AppwriteDbService {
  static final AppwriteDbService instance = AppwriteDbService._();
  AppwriteDbService._();

  Databases get _db => AppwriteClient.instance.databases;
  String get _dbId => AppwriteClient.databaseId;

  final Map<String, AppUser> _userCache = {};
  List<Confession>? _feedCache;
  DateTime? _feedCachedAt;
  static const _feedTtl = Duration(minutes: 5);

  void _invalidateFeedCache() {
    _feedCache = null;
    _feedCachedAt = null;
  }

  bool get _isFeedCacheValid =>
      _feedCache != null &&
      _feedCachedAt != null &&
      DateTime.now().difference(_feedCachedAt!) < _feedTtl;

  Future<void> initialize() async {}

  List<String> _decodeList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return List<String>.from(raw);
    if (raw is String && raw.isNotEmpty) {
      try {
        return List<String>.from(jsonDecode(raw));
      } catch (_) {}
    }
    return [];
  }

  AppUser _docToUser(aw_models.Document doc) {
    final d = doc.data;
    return AppUser(
      id: doc.$id,
      displayName: d['displayName'] ?? '',
      email: d['email'] ?? '',
      handle: d['handle'] ?? '',
      bio: d['bio'] ?? '',
      followersCount: d['followersCount'] ?? 0,
      followingCount: d['followingCount'] ?? 0,
      confessionCount: d['confessionCount'] ?? 0,
      upiId: d['upiId'] ?? '',
      links: _decodeList(d['links']),
      lastPlaybackDate: d['lastPlaybackDate'] ?? '',
      dailyPlaybackCount: d['dailyPlaybackCount'] ?? 0,
      savedConfessionIds: _decodeList(d['savedConfessionIds']),
      followingIds: _decodeList(d['followingIds']),
      followerIds: _decodeList(d['followerIds']),
      isPro: d['isPro'] ?? false,
    );
  }

  Confession _docToConfession(aw_models.Document doc) {
    final d = doc.data;
    return Confession(
      id: doc.$id,
      title: d['title'] ?? '',
      authorId: d['authorId'] ?? '',
      createdAt: DateTime.parse(doc.$createdAt),
      durationString: d['durationString'] ?? '',
      durationSeconds: d['durationSeconds'] ?? 0,
      waveformData: List<double>.from(
        (_decodeList(d['waveformData'])).map((e) => double.tryParse(e) ?? 0.0),
      ),
      commentsCount: d['commentsCount'] ?? 0,
      isSaved: false,
      audioUrl: d['audioUrl'],
    );
  }

  Comment _docToComment(aw_models.Document doc) {
    final d = doc.data;
    return Comment(
      id: doc.$id,
      confessionId: d['confessionId'] ?? '',
      authorId: d['authorId'] ?? '',
      content: d['content'] ?? '',
      createdAt: DateTime.parse(doc.$createdAt),
      imageUrl: d['imageUrl'],
    );
  }

  Future<void> createUserProfile(AppUser user) async {
    await _db.createDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.usersCollection,
      documentId: user.id,
      data: {
        ...user.toJson(),
        'links': user.links,
        'savedConfessionIds': user.savedConfessionIds,
        'followingIds': user.followingIds,
        'followerIds': user.followerIds,
      },
    );
    _userCache[user.id] = user;
  }

  Future<AppUser?> getUserProfile(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId];

    try {
      final doc = await _db.getDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        documentId: userId,
      );
      final user = _docToUser(doc);
      _userCache[userId] = user;
      return user;
    } on AppwriteException {
      return null;
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _db.updateDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.usersCollection,
      documentId: user.id,
      data: {
        ...user.toJson(),
        'links': user.links,
        'savedConfessionIds': user.savedConfessionIds,
        'followingIds': user.followingIds,
        'followerIds': user.followerIds,
      },
    );
    _userCache[user.id] = user;
  }

  Future<bool> checkHandleAvailable(String handle) async {
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        queries: [Query.equal('handle', handle), Query.limit(1)],
      );
      return result.documents.isEmpty;
    } catch (_) {
      return true;
    }
  }

  Future<List<AppUser>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        queries: [Query.search('displayName', query), Query.limit(limit)],
      );
      final users = result.documents.map(_docToUser).toList();
      for (final u in users) {
        _userCache[u.id] = u;
      }
      return users;
    } catch (_) {
      return [];
    }
  }

  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    final cached = <AppUser>[];
    final missing = <String>[];
    for (final id in userIds) {
      if (_userCache.containsKey(id)) {
        cached.add(_userCache[id]!);
      } else {
        missing.add(id);
      }
    }
    if (missing.isEmpty) return cached;

    final fetched = <AppUser>[];
    for (var i = 0; i < missing.length; i += 100) {
      final chunk = missing.sublist(i, (i + 100).clamp(0, missing.length));
      try {
        final result = await _db.listDocuments(
          databaseId: _dbId,
          collectionId: AppwriteClient.usersCollection,
          queries: [Query.equal('\$id', chunk), Query.limit(100)],
        );
        for (final doc in result.documents) {
          final u = _docToUser(doc);
          _userCache[u.id] = u;
          fetched.add(u);
        }
      } catch (_) {}
    }
    return [...cached, ...fetched];
  }

  Future<void> updateSavedConfessions(
    String userId,
    List<String> savedIds,
  ) async {
    await _db.updateDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.usersCollection,
      documentId: userId,
      data: {'savedConfessionIds': savedIds},
    );
    if (_userCache.containsKey(userId)) {
      _userCache[userId] = _userCache[userId]!.copyWith(
        savedConfessionIds: savedIds,
      );
    }
  }

  /// Follow: atomic batch — update both users in parallel.
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final current = await getUserProfile(currentUserId);
    final target = await getUserProfile(targetUserId);
    if (current == null || target == null) return;

    final updatedFollowing = [...current.followingIds, targetUserId];
    final updatedFollowers = [...target.followerIds, currentUserId];

    await Future.wait([
      _db.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        documentId: currentUserId,
        data: {
          'followingIds': updatedFollowing,
          'followingCount': current.followingCount + 1,
        },
      ),
      _db.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        documentId: targetUserId,
        data: {
          'followerIds': updatedFollowers,
          'followersCount': target.followersCount + 1,
        },
      ),
    ]);

    _userCache[currentUserId] = current.copyWith(
      followingIds: updatedFollowing,
      followingCount: current.followingCount + 1,
    );
    _userCache[targetUserId] = target.copyWith(
      followerIds: updatedFollowers,
      followersCount: target.followersCount + 1,
    );
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final current = await getUserProfile(currentUserId);
    final target = await getUserProfile(targetUserId);
    if (current == null || target == null) return;

    final updatedFollowing = current.followingIds
        .where((id) => id != targetUserId)
        .toList();
    final updatedFollowers = target.followerIds
        .where((id) => id != currentUserId)
        .toList();

    await Future.wait([
      _db.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        documentId: currentUserId,
        data: {
          'followingIds': updatedFollowing,
          'followingCount': (current.followingCount - 1).clamp(0, 99999),
        },
      ),
      _db.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.usersCollection,
        documentId: targetUserId,
        data: {
          'followerIds': updatedFollowers,
          'followersCount': (target.followersCount - 1).clamp(0, 99999),
        },
      ),
    ]);

    _userCache[currentUserId] = current.copyWith(
      followingIds: updatedFollowing,
      followingCount: (current.followingCount - 1).clamp(0, 99999),
    );
    _userCache[targetUserId] = target.copyWith(
      followerIds: updatedFollowers,
      followersCount: (target.followersCount - 1).clamp(0, 99999),
    );
  }

  Future<void> createConfession(Confession confession) async {
    await _db.createDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.confessionsCollection,
      documentId: confession.id,
      data: {
        'title': confession.title,
        'authorId': confession.authorId,
        'durationString': confession.durationString,
        'durationSeconds': confession.durationSeconds,
        'waveformData': confession.waveformData,
        'commentsCount': confession.commentsCount,
        'audioUrl': confession.audioUrl,
      },
    );
    _invalidateFeedCache();
  }

  Future<List<Confession>> getConfessions({
    int limit = 25,
    int offset = 0,
  }) async {
    if (_isFeedCacheValid) {
      final cached = _feedCache!;
      if (offset >= cached.length) return [];
      return cached.sublist(offset).take(limit).toList();
    }

    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.confessionsCollection,
        queries: [Query.orderDesc('\$createdAt'), Query.limit(limit + offset)],
      );
      final all = result.documents.map(_docToConfession).toList();
      _feedCache = all;
      _feedCachedAt = DateTime.now();
      if (offset >= all.length) return [];
      return all.sublist(offset).take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Confession>> getConfessionsByUser(
    String userId, {
    int limit = 50,
  }) async {
    if (userId.isEmpty) return [];
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.confessionsCollection,
        queries: [
          Query.equal('authorId', userId),
          Query.orderDesc('\$createdAt'),
          Query.limit(limit),
        ],
      );
      return result.documents.map(_docToConfession).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Confession>> getConfessionsByDate(
    String dateText, {
    int limit = 50,
    int offset = 0,
  }) async {
    List<Confession> all;
    if (_isFeedCacheValid) {
      all = _feedCache!;
    } else {
      all = await getConfessions(limit: 200, offset: 0);
    }

    final filtered = all.where((c) {
      final str =
          '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')}';
      return str == dateText;
    }).toList();

    if (offset >= filtered.length) return [];
    return filtered.sublist(offset).take(limit).toList();
  }

  Future<List<Confession>> searchConfessions(
    String query, {
    int limit = 30,
  }) async {
    if (query.trim().isEmpty) return getConfessions(limit: limit);
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.confessionsCollection,
        queries: [
          Query.search('title', query),
          Query.orderDesc('\$createdAt'),
          Query.limit(limit),
        ],
      );
      return result.documents.map(_docToConfession).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Confession>> getSavedConfessions(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = <Confession>[];
    for (var i = 0; i < ids.length; i += 100) {
      final chunk = ids.sublist(i, (i + 100).clamp(0, ids.length));
      try {
        final result = await _db.listDocuments(
          databaseId: _dbId,
          collectionId: AppwriteClient.confessionsCollection,
          queries: [Query.equal('\$id', chunk), Query.limit(100)],
        );
        results.addAll(result.documents.map(_docToConfession));
      } catch (_) {}
    }
    return results;
  }

  Future<List<Confession>> getFollowingConfessions(
    List<String> authorIds, {
    int limit = 25,
    int offset = 0,
  }) async {
    if (authorIds.isEmpty) return [];
    final results = <Confession>[];

    for (var i = 0; i < authorIds.length; i += 100) {
      final chunk = authorIds.sublist(i, (i + 100).clamp(0, authorIds.length));
      try {
        final result = await _db.listDocuments(
          databaseId: _dbId,
          collectionId: AppwriteClient.confessionsCollection,
          queries: [
            Query.equal('authorId', chunk),
            Query.orderDesc('\$createdAt'),
            Query.limit(limit + offset),
          ],
        );
        results.addAll(result.documents.map(_docToConfession));
      } catch (_) {}
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (offset >= results.length) return [];
    return results.sublist(offset).take(limit).toList();
  }

  Future<void> incrementCommentsCount(
    String confessionId,
    int currentCount,
  ) async {
    await _db.updateDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.confessionsCollection,
      documentId: confessionId,
      data: {'commentsCount': currentCount + 1},
    );
  }

  Future<void> decrementCommentsCount(String confessionId) async {
    try {
      final doc = await _db.getDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.confessionsCollection,
        documentId: confessionId,
      );
      final count = (doc.data['commentsCount'] as int? ?? 1);
      await _db.updateDocument(
        databaseId: _dbId,
        collectionId: AppwriteClient.confessionsCollection,
        documentId: confessionId,
        data: {'commentsCount': (count - 1).clamp(0, 99999)},
      );
    } catch (_) {}
  }

  Future<void> deleteConfession(String id) async {
    await _db.deleteDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.confessionsCollection,
      documentId: id,
    );
    _invalidateFeedCache();
  }

  Future<void> createComment(Comment comment) async {
    await _db.createDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.commentsCollection,
      documentId: comment.id,
      data: {
        'confessionId': comment.confessionId,
        'authorId': comment.authorId,
        'content': comment.content,
        'imageUrl': comment.imageUrl,
      },
    );
  }

  Future<void> deleteComment(String id) async {
    await _db.deleteDocument(
      databaseId: _dbId,
      collectionId: AppwriteClient.commentsCollection,
      documentId: id,
    );
  }

  Future<List<Comment>> getComments(String confessionId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: AppwriteClient.commentsCollection,
        queries: [
          Query.equal('confessionId', confessionId),
          Query.orderAsc('\$createdAt'),
          Query.limit(200),
        ],
      );
      return result.documents.map(_docToComment).toList();
    } catch (_) {
      return [];
    }
  }
}
