import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'appwrite_config.dart';
import 'appwrite_db_service.dart';
import 'appwrite_performance_helper.dart';
import '../../models/user.dart';

class AppwriteAuthService {
  static final AppwriteAuthService instance = AppwriteAuthService._init();
  AppwriteAuthService._init();

  final Account _account = Account(AppwriteConfig.client);

  Future<appwrite_models.User?> getCurrentSessionUser() async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_get_current_session_user',
      operation: () async {
        try {
          return await _account.get();
        } catch (_) {
          return null;
        }
      },
    );
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
    String bio = '',
  }) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_sign_up',
      operation: () async {
        final userId = ID.unique();
        
        await _account.create(
          userId: userId,
          email: email,
          password: password,
          name: displayName,
        );

        await signIn(email: email, password: password);

        final appUser = AppUser(
          id: userId,
          displayName: displayName,
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
      },
    );
  }

  Future<appwrite_models.Session> signIn({
    required String email,
    required String password,
  }) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_sign_in',
      operation: () => _account.createEmailPasswordSession(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_sign_out',
      operation: () => _account.deleteSession(sessionId: 'current'),
    );
  }

  Future<void> updateEmail({required String email, required String password}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_update_email',
      operation: () => _account.updateEmail(email: email, password: password),
    );
  }

  Future<void> updatePassword({required String newPassword, required String oldPassword}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_update_password',
      operation: () => _account.updatePassword(password: newPassword, oldPassword: oldPassword),
    );
  }

  Future<void> triggerPasswordReset({required String email, required String redirectUrl}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_trigger_password_reset',
      operation: () => _account.createRecovery(email: email, url: redirectUrl),
    );
  }

  Future<void> updateName({required String displayName}) async {
    return AppwritePerformanceHelper.traceAndHandle(
      traceName: 'auth_update_name',
      operation: () => _account.updateName(name: displayName),
    );
  }
}
