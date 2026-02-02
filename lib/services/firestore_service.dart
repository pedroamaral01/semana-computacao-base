import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/atividade.dart';
import '../data/models/inscricao.dart';
import '../data/models/pergunta.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ===== ATIVIDADES =====

  Stream<List<Atividade>> getAtividadesStream() {
    return _firestore.collection('atividades').orderBy('data').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Atividade.fromJson(data);
      }).toList();
    });
  }

  Future<Atividade?> getAtividade(String id) async {
    try {
      final doc = await _firestore.collection('atividades').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Atividade.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao obter atividade: $e');
      return null;
    }
  }

  Future<void> criarAtividade(Atividade atividade) async {
    await _firestore.collection('atividades').add(atividade.toJson());
  }

  Future<void> atualizarAtividade(Atividade atividade) async {
    await _firestore
        .collection('atividades')
        .doc(atividade.id)
        .update(atividade.toJson());
  }

  Future<void> excluirAtividade(String id) async {
    await _firestore.collection('atividades').doc(id).delete();
  }

  // ===== INSCRIÇÕES =====

  Future<bool> inscreverEmAtividade({
    required String usuarioId,
    required String atividadeId,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Verificar vagas disponíveis
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
          return false;
        }

        // Verificar se já está inscrito
        final inscricoesQuery = await _firestore
            .collection('inscricoes')
            .where('usuarioId', isEqualTo: usuarioId)
            .where('atividadeId', isEqualTo: atividadeId)
            .get();

        if (inscricoesQuery.docs.isNotEmpty) {
          return false;
        }

        // Criar inscrição
        final inscricao = Inscricao(
          id: _uuid.v4(),
          usuarioId: usuarioId,
          atividadeId: atividadeId,
          dataHora: DateTime.now(),
          checkInRealizado: false,
        );

        await _firestore
            .collection('inscricoes')
            .doc(inscricao.id)
            .set(inscricao.toJson());

        // Decrementar vagas
        transaction.update(atividadeRef, {
          'vagasDisponiveis': vagasDisponiveis - 1,
        });

        return true;
      });
    } catch (e) {
      print('Erro ao inscrever em atividade: $e');
      return false;
    }
  }

  Future<void> cancelarInscricao(String inscricaoId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final inscricaoRef = _firestore
            .collection('inscricoes')
            .doc(inscricaoId);
        final inscricaoDoc = await transaction.get(inscricaoRef);

        if (!inscricaoDoc.exists) {
          throw Exception('Inscrição não encontrada');
        }

        final atividadeId = inscricaoDoc.data()!['atividadeId'] as String;
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

        transaction.delete(inscricaoRef);
      });
    } catch (e) {
      print('Erro ao cancelar inscrição: $e');
    }
  }

  Stream<List<Inscricao>> getInscricoesUsuario(String usuarioId) {
    return _firestore
        .collection('inscricoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Inscricao.fromJson(data);
          }).toList();
        });
  }

  Stream<List<Inscricao>> getInscricoesAtividade(String atividadeId) {
    return _firestore
        .collection('inscricoes')
        .where('atividadeId', isEqualTo: atividadeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Inscricao.fromJson(data);
          }).toList();
        });
  }

  Future<bool> isUsuarioInscrito(String usuarioId, String atividadeId) async {
    final query = await _firestore
        .collection('inscricoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('atividadeId', isEqualTo: atividadeId)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> realizarCheckin(String inscricaoId) async {
    await _firestore.collection('inscricoes').doc(inscricaoId).update({
      'checkInRealizado': true,
    });
  }

  Future<Inscricao?> getInscricaoByQrCode(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('inscricoes')
          .where('id', isEqualTo: qrCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['id'] = querySnapshot.docs.first.id;
        return Inscricao.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar inscrição por QR Code: $e');
      return null;
    }
  }

  // ===== PERGUNTAS =====

  Future<void> enviarPergunta(Pergunta pergunta) async {
    await _firestore
        .collection('perguntas')
        .doc(pergunta.id)
        .set(pergunta.toJson());
  }

  Stream<List<Pergunta>> getPerguntasAtividade(String atividadeId) {
    return _firestore
        .collection('perguntas')
        .where('atividadeId', isEqualTo: atividadeId)
        .orderBy('dataHora', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Pergunta.fromJson(data);
          }).toList();
        });
  }

  // ===== FAVORITOS =====

  Future<void> adicionarFavorito(String usuarioId, String atividadeId) async {
    await _firestore
        .collection('favoritos')
        .doc('${usuarioId}_$atividadeId')
        .set({
          'usuarioId': usuarioId,
          'atividadeId': atividadeId,
          'dataHora': DateTime.now().toIso8601String(),
        });
  }

  Future<void> removerFavorito(String usuarioId, String atividadeId) async {
    await _firestore
        .collection('favoritos')
        .doc('${usuarioId}_$atividadeId')
        .delete();
  }

  Stream<List<String>> getFavoritosUsuario(String usuarioId) {
    return _firestore
        .collection('favoritos')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['atividadeId'] as String)
              .toList();
        });
  }
}
