import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConfig {
  AppwriteConfig._();

  static String get endpoint => dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  static String get projectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? 'YOUR_APPWRITE_PROJECT_ID';
  static const String databaseId = 'confessions_db';

  static const String usersCollectionId = 'users';
  static const String confessionsCollectionId = 'confessions';
  static const String commentsCollectionId = 'comments';

  static const String audioBucketId = 'confessions_audio';
  static const String imagesBucketId = 'comments_images';

  static Client get client => Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setSelfSigned(status: true);
}
