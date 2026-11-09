import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Status proses autentikasi.
enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

/// State autentikasi aplikasi.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _user = _repository.currentUser;
    _status = _user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
  }

  final AuthRepository _repository;

  UserModel? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
