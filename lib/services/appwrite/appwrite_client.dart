import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteClient {
  static final AppwriteClient _instance = AppwriteClient._();
  AppwriteClient._();
  static AppwriteClient get instance => _instance;

  late final Client client;
  late final Account account;
  late final Databases databases;

  void initialize() {
    final endpoint =
        dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
    final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

    client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId)
      ..setSelfSigned(status: false);

    account = Account(client);
    databases = Databases(client);
  }

  /// Appwrite Database ID
  static String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';

  static const String usersCollection = 'users';
  static const String confessionsCollection = 'confessions';
  static const String commentsCollection = 'comments';
}
