class FakeAuthService {
  static Map<String, dynamic>? _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static Future<void> signIn(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = userData;
  }

  static void logout() {
    _currentUser = null;
  }
}
