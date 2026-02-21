import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/atividade.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== ATIVIDADES ====================

  Future<List<Atividade>> getAtividades() async {
    try {
      final snapshot = await _firestore
          .collection('atividades')
          .orderBy('dataHora', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Atividade.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar atividades: $e');
    }
  }

  Future<Atividade?> getAtividadeById(String id) async {
    try {
      final doc = await _firestore.collection('atividades').doc(id).get();

      if (!doc.exists) return null;

      return Atividade.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar atividade: $e');
    }
  }

  // Alias para compatibilidade
  Future<Atividade?> getAtividade(String id) => getAtividadeById(id);

  Stream<List<Atividade>> getAtividadesStream() {
    return _firestore
        .collection('atividades')
        .orderBy('dataHora', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Atividade.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> criarAtividade(Atividade atividade) async {
    try {
      final docRef = await _firestore
          .collection('atividades')
          .add(atividade.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar atividade: $e');
    }
  }

  Future<void> atualizarAtividade(String id, Atividade atividade) async {
    try {
      await _firestore
          .collection('atividades')
          .doc(id)
          .update(atividade.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar atividade: $e');
    }
  }

  Future<void> excluirAtividade(String id) async {
    try {
      await _firestore.collection('atividades').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir atividade: $e');
    }
  }

  // ==================== INSCRIÇÕES ====================

  Future<void> inscreverEmAtividade(
    String usuarioId,
    String atividadeId,
  ) async {
    try {
      print(
        '🔍 DEBUG - Tentando inscrever usuário: $usuarioId na atividade: $atividadeId',
      );

      // Verifica se já existe inscrição ativa
      final inscricoesExistentes = await _firestore
          .collection('inscricoes')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('atividadeId', isEqualTo: atividadeId)
          .where('cancelada', isEqualTo: false)
          .get();

      if (inscricoesExistentes.docs.isNotEmpty) {
        throw Exception('Você já está inscrito nesta atividade');
      }

      print(
        '🔍 DEBUG - Nenhuma inscrição duplicada encontrada, prosseguindo...',
      );

      await _firestore.runTransaction((transaction) async {
        // Busca a atividade
        final atividadeRef = _firestore
            .collection('atividades')
            .doc(atividadeId);
        final atividadeDoc = await transaction.get(atividadeRef);

        if (!atividadeDoc.exists) {
          throw Exception('Atividade não encontrada');
        }

        final vagasDisponiveis =
            atividadeDoc.data()!['vagasDisponiveis'] as int;

        if (vagasDisponiveis <= 0) {
          throw Exception('Não há vagas disponíveis');
        }

        // Cria a inscrição
        final inscricaoRef = _firestore.collection('inscricoes').doc();
        transaction.set(inscricaoRef, {
          'usuarioId': usuarioId,
          'atividadeId': atividadeId,
          'dataInscricao': FieldValue.serverTimestamp(),
          'checkinRealizado': false,
          'dataCheckin': null,
          'cancelada': false,
        });

        // Atualiza vagas disponíveis
        transaction.update(atividadeRef, {
          'vagasDisponiveis': vagasDisponiveis - 1,
        });
      });
    } catch (e) {
      print('Erro ao inscrever em atividade: $e');
      rethrow;
    }
  }

  Future<void> cancelarInscricao(String inscricaoId, String atividadeId) async {
    try {
      print('🔄 Iniciando cancelamento da inscrição: $inscricaoId');
      print('🔄 Atividade ID: $atividadeId');

      // Marca inscrição como cancelada
      final inscricaoRef = _firestore.collection('inscricoes').doc(inscricaoId);

      print('🔄 Buscando inscrição...');
      final inscricaoDoc = await inscricaoRef.get();

      if (!inscricaoDoc.exists) {
        print('❌ Inscrição não encontrada');
        throw Exception('Inscrição não encontrada');
      }

      print('🔄 Marcando inscrição como cancelada...');
      await inscricaoRef.set({'cancelada': true}, SetOptions(merge: true));
      print('✅ Inscrição marcada como cancelada');

      // Devolve vaga
      print('🔄 Devolvendo vaga...');
      final atividadeRef = _firestore.collection('atividades').doc(atividadeId);
      final atividadeDoc = await atividadeRef.get();

      if (atividadeDoc.exists) {
        final data = atividadeDoc.data();
        if (data != null && data.containsKey('vagasDisponiveis')) {
          final vagasDisponiveis = data['vagasDisponiveis'] as int;
          await atividadeRef.update({'vagasDisponiveis': vagasDisponiveis + 1});
          print('✅ Vaga devolvida. Total disponível: ${vagasDisponiveis + 1}');
        } else {
          print('⚠️ Campo vagasDisponiveis não encontrado na atividade');
        }
      } else {
        print('⚠️ Atividade não encontrada: $atividadeId');
      }

      print('✅ Cancelamento concluído com sucesso');
    } catch (e, stackTrace) {
      print('❌ Erro ao cancelar inscrição: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getInscricoesUsuario(String usuarioId) {
    return _firestore
        .collection('inscricoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) {
                // Filtra inscrições canceladas
                final data = doc.data();
                final cancelada = data['cancelada'] as bool?;
                return cancelada != true; // Retorna true se não for cancelada
              })
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getInscricoesPorAtividade(
    String atividadeId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('inscricoes')
          .where('atividadeId', isEqualTo: atividadeId)
          .where('cancelada', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw Exception('Erro ao buscar inscrições: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getInscricoesAtividade(
    String atividadeId,
  ) {
    return _firestore
        .collection('inscricoes')
        .where('atividadeId', isEqualTo: atividadeId)
        .where('cancelada', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ==================== FAVORITOS ====================

  Future<void> salvarFavoritos(String userId, List<String> favoritosIds) async {
    try {
      print(
        '🔄 Firestore: Iniciando salvamento de ${favoritosIds.length} favoritos para $userId',
      );
      print('🔄 Firestore: IDs dos favoritos: $favoritosIds');

      // Sempre usa merge: true para criar ou atualizar
      await _firestore.collection('usuarios').doc(userId).set({
        'favoritos': favoritosIds,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Firestore: Favoritos salvos com sucesso!');

      // Verifica se realmente salvou fazendo uma leitura
      final doc = await _firestore.collection('usuarios').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final savedFavoritos = data?['favoritos'] as List?;
        print(
          '✅ Firestore: Verificação - ${savedFavoritos?.length ?? 0} favoritos no banco',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erro crítico ao salvar favoritos: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('Erro ao salvar favoritos: $e');
    }
  }

  Future<List<String>> carregarFavoritos(String userId) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(userId).get();

      if (!doc.exists) {
        print('📂 Firestore: Usuário $userId não existe ainda');
        return [];
      }

      final data = doc.data();
      if (data == null || !data.containsKey('favoritos')) {
        print('📂 Firestore: Nenhum favorito encontrado para $userId');
        return [];
      }

      final favoritos = List<String>.from(data['favoritos'] ?? []);
      print(
        '📂 Firestore: Carregados ${favoritos.length} favoritos para $userId',
      );
      return favoritos;
    } catch (e) {
      print('❌ Erro ao carregar favoritos: $e');
      return [];
    }
  }

  Stream<List<String>> getFavoritosStream(String userId) {
    return _firestore.collection('usuarios').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return <String>[];
      final data = doc.data();
      if (data == null || !data.containsKey('favoritos')) return <String>[];
      return List<String>.from(data['favoritos'] ?? []);
    });
  }
}
