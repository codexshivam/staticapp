import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthStateService extends ChangeNotifier {
  static final AuthStateService instance = AuthStateService._init();
  AuthStateService._init();

  AppUser? _currentUser;
  String? _sessionEmail;

  AppUser? get currentUser => _currentUser;
  String? get sessionEmail => _sessionEmail;
  bool get isLoggedIn => _currentUser != null;

  void setUser(AppUser user, {String? email}) {
    _currentUser = user;
    _sessionEmail = email;
    notifyListeners();
  }

  void updateUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _sessionEmail = null;
    notifyListeners();
  }
}
