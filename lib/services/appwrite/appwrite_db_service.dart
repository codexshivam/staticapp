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

  // --- USER PROFILES ---
  
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

  // --- CONFESSIONS ---

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
            Query.orderDesc('timestamp'),
          ],
        );
        return list.documents.map((doc) => Confession.fromJson(doc.data)).toList();
      },
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

  // --- COMMENTS ---

  Future<void> createComment(String confessionId, Comment comment) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'db_create_comment',
      operation: () {
        final data = comment.toJson();
        data['confessionId'] = confessionId;

        return _db.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.commentsCollectionId,
          documentId: comment.id,
          data: data,
        );
      },
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
            Query.orderAsc('timestamp'),
          ],
        );
        return list.documents.map((doc) => Comment.fromJson(doc.data)).toList();
      },
    );
  }
}
