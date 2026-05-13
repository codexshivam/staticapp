import 'package:appwrite/appwrite.dart';
import 'appwrite_config.dart';
import 'appwrite_performance_helper.dart';
import '../../models/user.dart';
import '../../models/confession.dart';
import '../../models/comment.dart';

class AppwriteDbService {
  static final AppwriteDbService instance = AppwriteDbService._init();
  AppwriteDbService._init();

  final Databases _db = Databases(AppwriteConfig.client);

  // ─── USER PROFILES ────────────────────────────────────────────────────────

  Future<void> createUserProfile(AppUser user) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_create_user_profile',
      operation: () => _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.id,
        data: user.toJson(),
      ),
    );
  }

  Future<AppUser?> getUserProfile(String userId) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_user_profile',
      operation: () async {
        try {
          final doc = await _db.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollectionId,
            documentId: userId,
          );
          return AppUser.fromJson(doc.data);
        } catch (_) {
          return null;
        }
      },
    );
  }

  Future<void> updateUserProfile(AppUser user) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_update_user_profile',
      operation: () => _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.id,
        data: user.toJson(),
      ),
    );
  }

  Future<bool> checkHandleAvailable(String handle) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_check_handle_available',
      operation: () async {
        final result = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          queries: [Query.equal('handle', handle), Query.limit(1)],
        );
        return result.total == 0;
      },
    );
  }

  Future<void> updateSavedConfessions(String userId, List<String> savedIds) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_update_saved_confessions',
      operation: () => _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
        data: {'savedConfessionIds': savedIds},
      ),
    );
  }

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_follow_user',
      operation: () async {
        final currentDoc = await _db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: currentUserId,
        );
        final targetDoc = await _db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: targetUserId,
        );

        final currentUser = AppUser.fromJson(currentDoc.data);
        final targetUser = AppUser.fromJson(targetDoc.data);

        final updatedFollowingIds = [...currentUser.followingIds, targetUserId];
        final updatedFollowerIds = [...targetUser.followerIds, currentUserId];

        await _db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: currentUserId,
          data: {
            'followingIds': updatedFollowingIds,
            'followingCount': currentUser.followingCount + 1,
          },
        );
        await _db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: targetUserId,
          data: {
            'followerIds': updatedFollowerIds,
            'followersCount': targetUser.followersCount + 1,
          },
        );
      },
    );
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_unfollow_user',
      operation: () async {
        final currentDoc = await _db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: currentUserId,
        );
        final targetDoc = await _db.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: targetUserId,
        );

        final currentUser = AppUser.fromJson(currentDoc.data);
        final targetUser = AppUser.fromJson(targetDoc.data);

        await _db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: currentUserId,
          data: {
            'followingIds': currentUser.followingIds.where((id) => id != targetUserId).toList(),
            'followingCount': (currentUser.followingCount - 1).clamp(0, 9999),
          },
        );
        await _db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: targetUserId,
          data: {
            'followerIds': targetUser.followerIds.where((id) => id != currentUserId).toList(),
            'followersCount': (targetUser.followersCount - 1).clamp(0, 9999),
          },
        );
      },
    );
  }

  // ─── CONFESSIONS ──────────────────────────────────────────────────────────

  Future<void> createConfession(Confession confession) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_create_confession',
      operation: () => _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.confessionsCollectionId,
        documentId: confession.id,
        data: confession.toJson(),
      ),
    );
  }

  Future<List<Confession>> getConfessions({int limit = 25, int offset = 0}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_confessions',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.limit(limit),
            Query.offset(offset),
            Query.orderDesc('createdAt'),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }

  Future<List<Confession>> getConfessionsByUser(String userId, {int limit = 50}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_confessions_by_user',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.equal('authorId', userId),
            Query.limit(limit),
            Query.orderDesc('createdAt'),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }

  Future<List<Confession>> getConfessionsByDate(String dateText, {int limit = 50, int offset = 0}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_confessions_by_date',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.equal('dateText', dateText), // You might want to update this to createdAt ranges if needed later
            Query.limit(limit),
            Query.offset(offset),
            Query.orderDesc('createdAt'),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }

  Future<List<Confession>> searchConfessions(String query, {int limit = 30}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_search_confessions',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.search('title', query),
            Query.limit(limit),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }

  Future<List<Confession>> getSavedConfessions(List<String> ids) async {
    if (ids.isEmpty) return [];
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_saved_confessions',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.equal('\$id', ids),
            Query.limit(ids.length),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }

  Future<List<Confession>> getFollowingConfessions(List<String> authorIds, {int limit = 25, int offset = 0}) async {
    if (authorIds.isEmpty) return [];
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_following_confessions',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.confessionsCollectionId,
          queries: [
            Query.equal('authorId', authorIds),
            Query.limit(limit),
            Query.offset(offset),
            Query.orderDesc('createdAt'),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
    );
  }



  Future<void> incrementCommentsCount(String confessionId, int currentCount) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_increment_comments_count',
      operation: () => _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.confessionsCollectionId,
        documentId: confessionId,
        data: {'commentsCount': currentCount + 1},
      ),
    );
  }

  Future<void> deleteConfession(String id) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_delete_confession',
      operation: () => _db.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.confessionsCollectionId,
        documentId: id,
      ),
    );
  }

  // ─── COMMENTS ─────────────────────────────────────────────────────────────

  Future<void> createComment(Comment comment) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_create_comment',
      operation: () => _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.commentsCollectionId,
        documentId: comment.id,
        data: comment.toJson(),
      ),
    );
  }

  Future<List<Comment>> getComments(String confessionId) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_get_comments',
      operation: () async {
        final list = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.commentsCollectionId,
          queries: [
            Query.equal('confessionId', confessionId),
            Query.orderAsc('createdAt'),
          ],
        );
        return list.documents.map((doc) => Comment.fromJson(doc.data)).toList();
      },
    );
  }
}
