import 'package:flutter/foundation.dart';
import '../models/pergunta.dart';
import '../repositories/mock_repository.dart';

class PerguntaProvider with ChangeNotifier {
  final MockRepository _repository = MockRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> enviarPergunta({
    required String usuarioId,
    required String atividadeId,
    required String texto,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular delay de rede
      await Future.delayed(const Duration(milliseconds: 500));

      final pergunta = Pergunta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        usuarioId: usuarioId,
        atividadeId: atividadeId,
        texto: texto,
        dataHora: DateTime.now(),
      );

      _repository.adicionarPergunta(pergunta);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Pergunta> getPerguntasByAtividade(String atividadeId) {
    return _repository.getPerguntasByAtividade(atividadeId);
  }
}
