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
      await _firestore.runTransaction((transaction) async {
        // Marca inscrição como cancelada
        final inscricaoRef = _firestore
            .collection('inscricoes')
            .doc(inscricaoId);
        transaction.update(inscricaoRef, {'cancelada': true});

        // Devolve vaga
        final atividadeRef = _firestore
            .collection('atividades')
            .doc(atividadeId);
        final atividadeDoc = await transaction.get(atividadeRef);

        if (atividadeDoc.exists) {
          final vagasDisponiveis =
              atividadeDoc.data()!['vagasDisponiveis'] as int;
          transaction.update(atividadeRef, {
            'vagasDisponiveis': vagasDisponiveis + 1,
          });
        }
      });
    } catch (e) {
      throw Exception('Erro ao cancelar inscrição: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getInscricoesUsuario(String usuarioId) {
    return _firestore
        .collection('inscricoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('cancelada', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
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
}
