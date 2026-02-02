import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../domain/entities/atividade.dart';
import '../data/models/inscricao.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../data/models/usuario.dart' as app_models;

class ListaPresencaScreen extends StatefulWidget {
  const ListaPresencaScreen({super.key});

  @override
  State<ListaPresencaScreen> createState() => _ListaPresencaScreenState();
}

class _ListaPresencaScreenState extends State<ListaPresencaScreen> {
  final firestoreService = FirestoreService();
  final firebaseAuthService = FirebaseAuthService();
  String? atividadeSelecionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Presença'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          _buildSeletorAtividade(),
          Expanded(
            child: atividadeSelecionada == null
                ? const Center(
                    child: Text(
                      'Selecione uma atividade para ver a lista',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                  )
                : _buildListaPresenca(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorAtividade() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: StreamBuilder<List<Atividade>>(
        stream: firestoreService.getAtividadesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final atividades = snapshot.data!;

          return DropdownButtonFormField<String>(
            value: atividadeSelecionada,
            decoration: const InputDecoration(
              labelText: 'Selecione uma atividade',
              border: OutlineInputBorder(),
            ),
            items: atividades.map((atividade) {
              return DropdownMenuItem(
                value: atividade.id,
                child: Text(atividade.titulo),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                atividadeSelecionada = value;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildListaPresenca() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getInscricoesAtividade(atividadeSelecionada!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: AppColors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum participante inscrito',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),
              ],
            ),
          );
        }

        final inscricoesData = snapshot.data!;
        final inscricoes = inscricoesData
            .map((data) => Inscricao.fromJson(data))
            .toList();
        final presentes = inscricoes.where((i) => i.checkInRealizado).length;
        final total = inscricoes.length;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryBlue.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const Text('Inscritos', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '$presentes',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Text('Presentes', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${total - presentes}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const Text('Ausentes', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: inscricoes.length,
                itemBuilder: (context, index) {
                  final inscricao = inscricoes[index];
                  return FutureBuilder<app_models.Usuario?>(
                    future: firebaseAuthService.getUsuario(inscricao.usuarioId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final usuario = userSnapshot.data!;
                      return _buildParticipanteCard(inscricao, usuario);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticipanteCard(
    Inscricao inscricao,
    app_models.Usuario usuario,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: inscricao.checkInRealizado
              ? AppColors.success
              : AppColors.grey,
          child: Icon(
            inscricao.checkInRealizado ? Icons.check : Icons.person,
            color: AppColors.white,
          ),
        ),
        title: Text(
          usuario.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email),
            if (inscricao.checkInRealizado)
              Text(
                'Check-in: ${dateFormat.format(inscricao.dataHora)}',
                style: const TextStyle(fontSize: 12, color: AppColors.success),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: inscricao.checkInRealizado
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: inscricao.checkInRealizado
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
          child: Text(
            inscricao.checkInRealizado ? 'Presente' : 'Ausente',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: inscricao.checkInRealizado
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
