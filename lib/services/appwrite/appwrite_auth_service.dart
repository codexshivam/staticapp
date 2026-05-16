import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import '../../models/user.dart';
import 'appwrite_client.dart';
import 'appwrite_db_service.dart';

class AppSession {
  final String uid;
  final String? email;

  const AppSession({required this.uid, this.email});
}

class AppwriteAuthService {
  static final AppwriteAuthService instance = AppwriteAuthService._();
  AppwriteAuthService._();

  Account get _account => AppwriteClient.instance.account;

  Future<AppSession?> getCurrentSessionUser() async {
    try {
      final user = await _account.get();
      return AppSession(uid: user.$id, email: user.email);
    } on AppwriteException {
      return null;
    }
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
    String bio = '',
  }) async {
    final aw_models.User awUser = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: displayName,
    );

    await _account.createEmailPasswordSession(email: email, password: password);

    final appUser = AppUser(
      id: awUser.$id,
      displayName: displayName,
      email: email,
      handle: '@${username.replaceAll('@', '')}',
      bio: bio,
      followersCount: 0,
      followingCount: 0,
      confessionCount: 0,
      upiId: '',
      links: [],
    );

    await AppwriteDbService.instance.createUserProfile(appUser);
    return appUser;
  }

  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return AppSession(uid: session.userId, email: email);
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {}
  }

  Future<void> updateEmail({
    required String email,
    required String password,
  }) async {
    await _account.updateEmail(email: email, password: password);
  }

  Future<void> updatePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  Future<void> triggerPasswordReset({
    required String email,
    required String redirectUrl,
  }) async {
    await _account.createRecovery(email: email, url: redirectUrl);
  }

  Future<void> updateName({required String displayName}) async {
    await _account.updateName(name: displayName);
  }
}
