import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../repositories/mock_repository.dart';
import '../../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final MockRepository _repository = MockRepository();
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
      final userData = await _storageService.getUser();
      if (userData != null) {
        _currentUser = Usuario.fromJson(userData);
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final usuario = _repository.autenticarUsuario(email, senha);

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
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.removeUser();
    notifyListeners();
  }
}
