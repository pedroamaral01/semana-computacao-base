import 'package:flutter/foundation.dart';
import '../models/atividade.dart';
import '../repositories/mock_repository.dart';
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';

class AgendaProvider with ChangeNotifier {
  final MockRepository _repository = MockRepository();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  List<String> _favoritosIds = [];
  bool _notificacoesHabilitadas = true;

  List<String> get favoritosIds => _favoritosIds;
  bool get notificacoesHabilitadas => _notificacoesHabilitadas;

  AgendaProvider() {
    carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    _favoritosIds = await _storageService.getFavorites();
    notifyListeners();
  }

  List<Atividade> getAtividadesFavoritas() {
    final todasAtividades = _repository.getAtividades();
    return todasAtividades
        .where((atividade) => _favoritosIds.contains(atividade.id))
        .toList()
      ..sort((a, b) {
        final dateCompare = a.data.compareTo(b.data);
        if (dateCompare != 0) return dateCompare;
        return a.horarioInicio.hour.compareTo(b.horarioInicio.hour);
      });
  }

  bool isFavorito(String atividadeId) {
    return _favoritosIds.contains(atividadeId);
  }

  Future<void> toggleFavorito(String atividadeId) async {
    if (_favoritosIds.contains(atividadeId)) {
      _favoritosIds.remove(atividadeId);
      await _cancelarNotificacao(atividadeId);
    } else {
      _favoritosIds.add(atividadeId);
      if (_notificacoesHabilitadas) {
        await _agendarNotificacao(atividadeId);
      }
    }

    await _storageService.saveFavorites(_favoritosIds);
    notifyListeners();
  }

  Future<void> toggleNotificacoes() async {
    _notificacoesHabilitadas = !_notificacoesHabilitadas;

    if (_notificacoesHabilitadas) {
      // Solicitar permissões
      await _notificationService.requestPermissions();
      // Reagendar todas as notificações
      for (final id in _favoritosIds) {
        await _agendarNotificacao(id);
      }
    } else {
      // Cancelar todas as notificações
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> _agendarNotificacao(String atividadeId) async {
    final atividade = _repository.getAtividadeById(atividadeId);
    if (atividade == null) return;

    // Agendar notificação 10 minutos antes
    final dataHoraAtividade = DateTime(
      atividade.data.year,
      atividade.data.month,
      atividade.data.day,
      atividade.horarioInicio.hour,
      atividade.horarioInicio.minute,
    );

    final dataNotificacao = dataHoraAtividade.subtract(
      const Duration(minutes: 10),
    );

    // Só agendar se a data for futura
    if (dataNotificacao.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: atividadeId.hashCode,
        title: 'Lembrete de Atividade',
        body:
            'Lembrete: A \'${atividade.titulo}\' começa em 10 minutos na ${atividade.local}.',
        scheduledDate: dataNotificacao,
      );
    }
  }

  Future<void> _cancelarNotificacao(String atividadeId) async {
    await _notificationService.cancelNotification(atividadeId.hashCode);
  }
}
