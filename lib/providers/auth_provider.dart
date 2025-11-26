import 'package:flutter/foundation.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser?.isGuest == true;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      debugPrint('Auth check error: $e');
    }
    
    _setLoading(false);
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signUp(email, password, username);
      _setLoading(false);
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _formatError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.login(email, password);
      _setLoading(false);
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _formatError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAsGuest({String? username}) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.loginAsGuest(username: username);
      _setLoading(false);
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _formatError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _errorMessage = _formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatError(e);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _formatError(dynamic error) {
    if (error is String) return error;
    if (error is Error) return error.toString();
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('Invalid login credentials')) {
        return 'Wrong email or password';
      }
      if (msg.contains('Email not confirmed')) {
        return 'Please check your email and confirm your account';
      }
      if (msg.contains('network')) {
        return 'No internet connection';
      }
      return msg.replaceFirst('Exception: ', '').split('\n').first;
    }
    return 'An unexpected error occurred';
  }
}