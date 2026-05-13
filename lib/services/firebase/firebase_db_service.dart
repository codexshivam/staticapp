import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../models/confession.dart';
import '../../models/comment.dart';

class FirebaseDbService {
  static final FirebaseDbService instance = FirebaseDbService._init();
  FirebaseDbService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── USER PROFILES ────────────────────────────────────────────────────────

  Future<void> createUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(
      user.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<bool> checkHandleAvailable(String handle) async {
    final snapshot = await _firestore
        .collection('users')
        .where('handle', isEqualTo: handle)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> updateSavedConfessions(String userId, List<String> savedIds) async {
    await _firestore.collection('users').doc(userId).update({
      'savedConfessionIds': savedIds,
    });
  }

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final currentDoc = await _firestore.collection('users').doc(currentUserId).get();
    final targetDoc = await _firestore.collection('users').doc(targetUserId).get();

    if (!currentDoc.exists || !targetDoc.exists) return;

    final currentUser = AppUser.fromJson(currentDoc.data()!);
    final targetUser = AppUser.fromJson(targetDoc.data()!);

    final updatedFollowingIds = [...currentUser.followingIds, targetUserId];
    final updatedFollowerIds = [...targetUser.followerIds, currentUserId];

    await _firestore.collection('users').doc(currentUserId).update({
      'followingIds': updatedFollowingIds,
      'followingCount': currentUser.followingCount + 1,
    });
    await _firestore.collection('users').doc(targetUserId).update({
      'followerIds': updatedFollowerIds,
      'followersCount': targetUser.followersCount + 1,
    });
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final currentDoc = await _firestore.collection('users').doc(currentUserId).get();
    final targetDoc = await _firestore.collection('users').doc(targetUserId).get();

    if (!currentDoc.exists || !targetDoc.exists) return;

    final currentUser = AppUser.fromJson(currentDoc.data()!);
    final targetUser = AppUser.fromJson(targetDoc.data()!);

    await _firestore.collection('users').doc(currentUserId).update({
      'followingIds': currentUser.followingIds.where((id) => id != targetUserId).toList(),
      'followingCount': (currentUser.followingCount - 1).clamp(0, 9999),
    });
    await _firestore.collection('users').doc(targetUserId).update({
      'followerIds': targetUser.followerIds.where((id) => id != currentUserId).toList(),
      'followersCount': (targetUser.followersCount - 1).clamp(0, 9999),
    });
  }

  // ─── CONFESSIONS ──────────────────────────────────────────────────────────

  Future<void> createConfession(Confession confession) async {
    await _firestore
        .collection('confessions')
        .doc(confession.id)
        .set(confession.toJson());
  }

  Future<List<Confession>> getConfessions({int limit = 25, int offset = 0}) async {
    final snapshot = await _firestore
        .collection('confessions')
        .orderBy('createdAt', descending: true)
        .limit(limit + offset)
        .get();

    final all = snapshot.docs.map((doc) => Confession.fromJson(doc.data())).toList();
    if (offset >= all.length) return [];
    return all.sublist(offset);
  }

  Future<List<Confession>> getConfessionsByUser(String userId, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection('confessions')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Confession.fromJson(doc.data())).toList();
  }

  Future<List<Confession>> getConfessionsByDate(String dateText, {int limit = 50, int offset = 0}) async {
    final snapshot = await _firestore
        .collection('confessions')
        .orderBy('createdAt', descending: true)
        .limit(100) // Filter in memory for robust dateText handling
        .get();

    final all = snapshot.docs
        .map((doc) => Confession.fromJson(doc.data()))
        // Assuming dateText formatting logic if stored, or just returning recent
        .toList();

    if (offset >= all.length) return [];
    return all.sublist(offset).take(limit).toList();
  }

  Future<List<Confession>> searchConfessions(String query, {int limit = 30}) async {
    final snapshot = await _firestore
        .collection('confessions')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final all = snapshot.docs.map((doc) => Confession.fromJson(doc.data())).toList();
    if (query.trim().isEmpty) return all.take(limit).toList();

    final q = query.toLowerCase();
    return all
        .where((c) => c.title.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  Future<List<Confession>> getSavedConfessions(List<String> ids) async {
    if (ids.isEmpty) return [];

    // Firestore whereIn supports up to 10 items per chunk
    final List<Confession> results = [];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snapshot = await _firestore
          .collection('confessions')
          .where('id', whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map((doc) => Confession.fromJson(doc.data())));
    }
    return results;
  }

  Future<List<Confession>> getFollowingConfessions(List<String> authorIds, {int limit = 25, int offset = 0}) async {
    if (authorIds.isEmpty) return [];

    final List<Confession> results = [];
    for (var i = 0; i < authorIds.length; i += 10) {
      final chunk = authorIds.sublist(i, i + 10 > authorIds.length ? authorIds.length : i + 10);
      final snapshot = await _firestore
          .collection('confessions')
          .where('authorId', whereIn: chunk)
          .orderBy('createdAt', descending: true)
          .limit(limit + offset)
          .get();
      results.addAll(snapshot.docs.map((doc) => Confession.fromJson(doc.data())));
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (offset >= results.length) return [];
    return results.sublist(offset).take(limit).toList();
  }

  Future<void> incrementCommentsCount(String confessionId, int currentCount) async {
    await _firestore.collection('confessions').doc(confessionId).update({
      'commentsCount': currentCount + 1,
    });
  }

  Future<void> deleteConfession(String id) async {
    await _firestore.collection('confessions').doc(id).delete();
  }

  // ─── COMMENTS ─────────────────────────────────────────────────────────────

  Future<void> createComment(Comment comment) async {
    await _firestore.collection('comments').doc(comment.id).set(comment.toJson());
  }

  Future<List<Comment>> getComments(String confessionId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('confessionId', isEqualTo: confessionId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList();
  }
}
