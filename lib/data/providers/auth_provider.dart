import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final StorageService _storageService = StorageService();

  Usuario? _currentUser;
  bool _isLoading = false;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isOrganizador => _currentUser?.tipo == 'Organizador';

  Future<void> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseUser = _firebaseAuthService.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _firebaseAuthService.getUsuario(firebaseUser.uid);
        if (_currentUser != null) {
          await _storageService.saveUser(_currentUser!.toJson());
        }
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String tipo,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final usuario = await _firebaseAuthService.cadastrarUsuario(
        nome: nome,
        email: email,
        senha: senha,
        tipo: tipo,
      );

      if (usuario != null) {
        _currentUser = usuario;
        await _storageService.saveUser(usuario.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Erro no cadastro: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      final usuario = await _firebaseAuthService.login(
        email: email,
        senha: senha,
      );

      if (usuario != null) {
        _currentUser = usuario;
        await _storageService.saveUser(usuario.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Erro no login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuthService.logout();
    notifyListeners();
  }
}
