import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/storage_service.dart';
import '../../core/utils/auth_result.dart';

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

  Future<AuthResult> cadastrar({
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
        return AuthResult.success();
      }

      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(
        message: 'Erro ao criar conta. Tente novamente.',
      );
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este email já está cadastrado.';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido.';
          break;
        case 'weak-password':
          errorMessage = 'Senha muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'network-request-failed':
          errorMessage = 'Erro de conexão. Verifique sua internet.';
          break;
        default:
          errorMessage = 'Erro ao criar conta: ${e.message}';
      }

      return AuthResult.failure(message: errorMessage, code: e.code);
    } catch (e) {
      print('Erro no cadastro: $e');
      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(
        message: 'Erro inesperado ao criar conta. Tente novamente.',
      );
    }
  }

  Future<AuthResult> login(String email, String senha) async {
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
        return AuthResult.success();
      }

      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(message: 'Erro ao carregar dados do usuário');
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      // Traduz os códigos de erro do Firebase para mensagens amigáveis
      String errorMessage;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
          errorMessage = 'Senha incorreta. Tente novamente.';
          break;
        case 'user-not-found':
          errorMessage = 'Email não cadastrado no sistema.';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido.';
          break;
        case 'user-disabled':
          errorMessage = 'Esta conta foi desativada.';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        case 'network-request-failed':
          errorMessage = 'Erro de conexão. Verifique sua internet.';
          break;
        default:
          errorMessage = 'Erro ao fazer login: ${e.message}';
      }

      print('❌ Erro no login: ${e.code} - $errorMessage');
      return AuthResult.failure(message: errorMessage, code: e.code);
    } catch (e) {
      print('❌ Erro inesperado no login: $e');
      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(
        message: 'Erro inesperado ao fazer login. Tente novamente.',
      );
    }
  }

  Future<void> logout() async {
    await _firebaseAuthService.logout();
    await _storageService.clearUser();
    _currentUser = null;
    notifyListeners();
  }
}
