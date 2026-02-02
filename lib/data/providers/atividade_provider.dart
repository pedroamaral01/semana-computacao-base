import 'package:flutter/foundation.dart';
import 'package:semana_computacao_app/domain/entities/atividade.dart';
import '../../services/firestore_service.dart';

class AtividadeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Atividade> _atividades = [];
  bool _isLoading = false;
  String? _error;

  List<Atividade> get atividades => _atividades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Buscar todas as atividades
  Future<void> fetchAtividades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _atividades = await _firestoreService.getAtividades();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar atividade por ID
  Future<Atividade?> getAtividadeById(String id) async {
    try {
      return await _firestoreService.getAtividadeById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Criar atividade
  Future<bool> criarAtividade(Atividade atividade) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.criarAtividade(atividade);
      await fetchAtividades(); // Atualiza lista
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Atualizar atividade
  Future<bool> atualizarAtividade(String id, Atividade atividade) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.atualizarAtividade(id, atividade);
      await fetchAtividades(); // Atualiza lista
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Excluir atividade
  Future<bool> excluirAtividade(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.excluirAtividade(id);
      await fetchAtividades(); // Atualiza lista
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
