import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/atividade.dart';
import '../models/inscricao.dart';
import '../repositories/mock_repository.dart';

class AtividadeProvider with ChangeNotifier {
  final MockRepository _repository = MockRepository();

  List<Atividade> _atividades = [];
  List<Atividade> _atividadesFiltradas = [];
  String? _filtroTipo;
  DateTime? _filtroData;
  bool _isLoading = false;

  List<Atividade> get atividades => _atividadesFiltradas;
  bool get isLoading => _isLoading;
  String? get filtroTipo => _filtroTipo;
  DateTime? get filtroData => _filtroData;

  AtividadeProvider() {
    carregarAtividades();
  }

  void carregarAtividades() {
    _isLoading = true;
    notifyListeners();

    _atividades = _repository.getAtividades();
    _atividadesFiltradas = List.from(_atividades);

    _isLoading = false;
    notifyListeners();
  }

  void aplicarFiltros({String? tipo, DateTime? data}) {
    _filtroTipo = tipo;
    _filtroData = data;

    _atividadesFiltradas = _atividades.where((atividade) {
      bool passaTipo =
          tipo == null || tipo == 'Todos' || atividade.tipo == tipo;
      bool passaData =
          data == null ||
          (atividade.data.year == data.year &&
              atividade.data.month == data.month &&
              atividade.data.day == data.day);

      return passaTipo && passaData;
    }).toList();

    notifyListeners();
  }

  void limparFiltros() {
    _filtroTipo = null;
    _filtroData = null;
    _atividadesFiltradas = List.from(_atividades);
    notifyListeners();
  }

  Atividade? getAtividadeById(String id) {
    return _repository.getAtividadeById(id);
  }

  List<DateTime> getDatasDisponiveis() {
    final datas = _atividades.map((a) => a.data).toSet().toList();
    datas.sort();
    return datas;
  }

  Future<bool> inscreverEmAtividade(
    String usuarioId,
    String atividadeId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular delay de rede
      await Future.delayed(const Duration(seconds: 1));

      final atividade = getAtividadeById(atividadeId);

      if (atividade == null || atividade.vagasDisponiveis <= 0) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (_repository.isUsuarioInscrito(usuarioId, atividadeId)) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final inscricao = Inscricao(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        usuarioId: usuarioId,
        atividadeId: atividadeId,
        dataHora: DateTime.now(),
        checkInRealizado: false,
      );

      _repository.adicionarInscricao(inscricao);
      carregarAtividades(); // Recarregar para atualizar vagas

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool isUsuarioInscrito(String usuarioId, String atividadeId) {
    return _repository.isUsuarioInscrito(usuarioId, atividadeId);
  }
}
