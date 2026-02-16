import 'package:flutter/foundation.dart';
import '../../domain/entities/atividade.dart';
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

  // Obter datas disponíveis das atividades
  List<DateTime> getDatasDisponiveis() {
    final datas = _atividades.map((a) => a.dataHora).toSet().toList();
    datas.sort();
    return datas;
  }

  // Aplicar filtros
  List<Atividade> aplicarFiltros({String? tipo, DateTime? data}) {
    var atividadesFiltradas = _atividades;

    if (tipo != null && tipo.isNotEmpty) {
      atividadesFiltradas = atividadesFiltradas
          .where((a) => a.tipo == tipo)
          .toList();
    }

    if (data != null) {
      atividadesFiltradas = atividadesFiltradas.where((a) {
        return a.dataHora.year == data.year &&
            a.dataHora.month == data.month &&
            a.dataHora.day == data.day;
      }).toList();
    }

    return atividadesFiltradas;
  }

  // Verificar se usuário está inscrito
  Future<bool> isUsuarioInscrito(String atividadeId, String usuarioId) async {
    try {
      final inscricoes = await _firestoreService.getInscricoesPorAtividade(
        atividadeId,
      );
      return inscricoes.any(
        (i) => i['usuarioId'] == usuarioId && i['cancelada'] == false,
      );
    } catch (e) {
      return false;
    }
  }

  // Inscrever em atividade
  Future<bool> inscreverEmAtividade(
    String atividadeId,
    String usuarioId,
  ) async {
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.inscreverEmAtividade(usuarioId, atividadeId);
      await fetchAtividades(); // Atualiza lista
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('Erro na inscrição: $_error');
      notifyListeners();
      return false;
    }
  }
}
