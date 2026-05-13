import 'package:appwrite/appwrite.dart';
import 'appwrite_config.dart';
import 'appwrite_performance_helper.dart';

class AppwriteStorageService {
  static final AppwriteStorageService instance = AppwriteStorageService._init();
  AppwriteStorageService._init();

  final Storage _storage = Storage(AppwriteConfig.client);

  Future<String> uploadConfessionAudio(String localPath) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'storage_upload_confession_audio',
      operation: () async {
        final fileId = ID.unique();
        final file = await _storage.createFile(
          bucketId: AppwriteConfig.audioBucketId,
          fileId: fileId,
          file: InputFile.fromPath(
            path: localPath,
            filename: 'confession_$fileId.m4a',
          ),
        );

        return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.audioBucketId}/files/${file.$id}/view?project=${AppwriteConfig.projectId}';
      },
    );
  }

  Future<String> uploadCommentImage(String localPath) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'storage_upload_comment_image',
      operation: () async {
        final fileId = ID.unique();
        final file = await _storage.createFile(
          bucketId: AppwriteConfig.imagesBucketId,
          fileId: fileId,
          file: InputFile.fromPath(
            path: localPath,
            filename: 'comment_$fileId.png',
          ),
        );

        return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.imagesBucketId}/files/${file.$id}/view?project=${AppwriteConfig.projectId}';
      },
    );
  }

  Future<void> deleteAudioFile(String fileId) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'storage_delete_audio_file',
      operation: () => _storage.deleteFile(
        bucketId: AppwriteConfig.audioBucketId,
        fileId: fileId,
      ),
    );
  }

  Future<void> deleteImageFile(String fileId) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'storage_delete_image_file',
      operation: () => _storage.deleteFile(
        bucketId: AppwriteConfig.imagesBucketId,
        fileId: fileId,
      ),
    );
  }
}
