import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import 'firebase_db_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._init();
  FirebaseAuthService._init();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentSessionUser() {
    return _auth.currentUser;
  }

  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
    String bio = '',
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) throw Exception('Failed to create Firebase user.');

    await firebaseUser.updateDisplayName(displayName);

    final appUser = AppUser(
      id: firebaseUser.uid,
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

    await FirebaseDbService.instance.createUserProfile(appUser);
    return appUser;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateEmail({required String email, required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('No user currently logged in.');

    final credential = EmailAuthProvider.credential(email: user.email!, password: password);
    await user.reauthenticateWithCredential(credential);

    await user.verifyBeforeUpdateEmail(email);
  }

  Future<void> updatePassword({required String newPassword, required String oldPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('No user currently logged in.');

    final credential = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);
  }

  Future<void> triggerPasswordReset({required String email, required String redirectUrl}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateName({required String displayName}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user currently logged in.');
    await user.updateDisplayName(displayName);
  }
}
