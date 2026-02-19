import 'package:flutter/foundation.dart';
import '../../domain/entities/atividade.dart';
import '../../services/notification_service.dart';
import '../../services/firestore_service.dart';

class AgendaProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<String> _favoritosIds = [];
  bool _notificacoesHabilitadas = true;
  List<Atividade> _atividades = [];
  String? _currentUserId;

  List<String> get favoritosIds => _favoritosIds;
  bool get notificacoesHabilitadas => _notificacoesHabilitadas;

  AgendaProvider() {
    carregarAtividades();
  }

  // Método para definir o usuário atual e carregar seus favoritos
  Future<void> setUsuario(String userId) async {
    print('📱 AgendaProvider: setUsuario chamado com userId: $userId');
    _currentUserId = userId;
    await carregarFavoritos();
  }

  Future<void> carregarFavoritos() async {
    if (_currentUserId == null) {
      print('⚠️ AgendaProvider: Tentou carregar favoritos sem userId');
      return;
    }
    _favoritosIds = await _firestoreService.carregarFavoritos(_currentUserId!);
    print(
      '✅ AgendaProvider: ${_favoritosIds.length} favoritos carregados para usuário $_currentUserId',
    );
    notifyListeners();
  }

  Future<void> carregarAtividades() async {
    try {
      _atividades = await _firestoreService.getAtividades();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar atividades na agenda: $e');
    }
  }

  List<Atividade> getAtividadesFavoritas() {
    return _atividades
        .where((atividade) => _favoritosIds.contains(atividade.id))
        .toList()
      ..sort((a, b) {
        final dateCompare = a.dataHora.compareTo(b.dataHora);
        return dateCompare;
      });
  }

  bool isFavorito(String atividadeId) {
    return _favoritosIds.contains(atividadeId);
  }

  Future<void> toggleFavorito(String atividadeId) async {
    if (_currentUserId == null) {
      print('⚠️ Usuário não definido no AgendaProvider');
      return;
    }

    try {
      if (_favoritosIds.contains(atividadeId)) {
        _favoritosIds.remove(atividadeId);
        try {
          await _cancelarNotificacao(atividadeId);
        } catch (e) {
          print('⚠️ Erro ao cancelar notificação (ignorado): $e');
        }
        print('❌ AgendaProvider: Removido favorito $atividadeId');
      } else {
        _favoritosIds.add(atividadeId);
        // Recarrega atividades se a lista estiver vazia
        if (_atividades.isEmpty) {
          await carregarAtividades();
        }
        if (_notificacoesHabilitadas && !kIsWeb) {
          try {
            await _agendarNotificacao(atividadeId);
          } catch (e) {
            print('⚠️ Erro ao agendar notificação (ignorado): $e');
          }
        }
        print('⭐ AgendaProvider: Adicionado favorito $atividadeId');
      }

      // SEMPRE salvar no Firestore, independente do erro de notificação
      await _firestoreService.salvarFavoritos(_currentUserId!, _favoritosIds);
      print(
        '💾 AgendaProvider: Salvos ${_favoritosIds.length} favoritos para usuário $_currentUserId',
      );
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao toggle favorito: $e');
      // Reverte a alteração local se falhou no Firestore
      if (_favoritosIds.contains(atividadeId)) {
        _favoritosIds.remove(atividadeId);
      } else {
        _favoritosIds.add(atividadeId);
      }
      notifyListeners();
      rethrow;
    }
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
    try {
      // Notificações não são suportadas na web
      if (kIsWeb) {
        print('ℹ️ Notificações não disponíveis na web');
        return;
      }

      // Busca atividade na lista já carregada
      final atividade = _atividades.firstWhere(
        (a) => a.id == atividadeId,
        orElse: () => _atividades.first, // Fallback temporário
      );

      if (atividade.id != atividadeId) {
        print('Atividade não encontrada para notificação: $atividadeId');
        return;
      }

      // Agendar notificação 10 minutos antes
      final dataNotificacao = atividade.dataHora.subtract(
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
    } catch (e) {
      print('❌ Erro ao agendar notificação: $e');
      // Não propaga o erro - notificações são opcionais
    }
  }

  Future<void> _cancelarNotificacao(String atividadeId) async {
    try {
      if (kIsWeb) return; // Notificações não disponíveis na web
      await _notificationService.cancelNotification(atividadeId.hashCode);
    } catch (e) {
      print('❌ Erro ao cancelar notificação: $e');
      // Não propaga o erro - notificações são opcionais
    }
  }
}
