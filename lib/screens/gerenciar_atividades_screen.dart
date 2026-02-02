import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../domain/entities/atividade.dart';
import '../services/firestore_service.dart';
import 'cadastrar_atividade_screen.dart';

class GerenciarAtividadesScreen extends StatelessWidget {
  const GerenciarAtividadesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Atividades'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: StreamBuilder<List<Atividade>>(
        stream: firestoreService.getAtividadesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma atividade cadastrada',
                    style: TextStyle(fontSize: 16, color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          final atividades = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: atividades.length,
            itemBuilder: (context, index) {
              final atividade = atividades[index];
              return _buildAtividadeCard(context, atividade, firestoreService);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarAtividadeScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Atividade'),
      ),
    );
  }

  Widget _buildAtividadeCard(
    BuildContext context,
    Atividade atividade,
    FirestoreService firestoreService,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    atividade.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (atividade.aoVivo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: AppColors.white),
                        SizedBox(width: 4),
                        Text(
                          'Ao Vivo',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: atividade.tipo == 'Palestra'
                        ? AppColors.primaryBlue.withOpacity(0.1)
                        : AppColors.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    atividade.tipo,
                    style: TextStyle(
                      fontSize: 12,
                      color: atividade.tipo == 'Palestra'
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${atividade.vagasDisponiveis}/${atividade.vagasTotal} vagas',
                  style: TextStyle(
                    fontSize: 14,
                    color: atividade.vagasDisponiveis > 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Por: ${atividade.palestrante}',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(atividade.data),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  atividade.horarioFormatado,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(atividade.local, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CadastrarAtividadeScreen(atividade: atividade),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir Atividade'),
                          content: const Text(
                            'Tem certeza que deseja excluir esta atividade?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true && context.mounted) {
                        await firestoreService.excluirAtividade(atividade.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Atividade excluída com sucesso'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
