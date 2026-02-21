import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/constants/app_colors.dart';
import '../domain/entities/atividade.dart';
import '../data/models/inscricao.dart';
import '../data/providers/auth_provider.dart';
import '../services/firestore_service.dart';

class MinhasInscricoesScreen extends StatelessWidget {
  const MinhasInscricoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreService = FirestoreService();

    // Valida se o usuário está autenticado
    if (authProvider.currentUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'Faça login para ver suas inscrições',
              style: TextStyle(fontSize: 16, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final usuarioId = authProvider.currentUser!.id;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getInscricoesUsuario(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Você ainda não está inscrito\nem nenhuma atividade',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final inscricoesData = snapshot.data!;
        final inscricoes = inscricoesData
            .map((data) => Inscricao.fromJson(data))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inscricoes.length,
          itemBuilder: (context, index) {
            final inscricao = inscricoes[index];
            return FutureBuilder<Atividade?>(
              future: firestoreService.getAtividade(inscricao.atividadeId),
              builder: (context, atividadeSnapshot) {
                if (atividadeSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (!atividadeSnapshot.hasData ||
                    atividadeSnapshot.data == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Atividade não encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ID: ${inscricao.atividadeId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final atividade = atividadeSnapshot.data!;
                return _buildInscricaoCard(
                  context,
                  inscricao,
                  atividade,
                  firestoreService,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInscricaoCard(
    BuildContext context,
    Inscricao inscricao,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: inscricao.checkInRealizado
                        ? AppColors.success
                        : AppColors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inscricao.checkInRealizado ? 'Check-in OK' : 'Pendente',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              atividade.tipo,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Por: ${atividade.palestrante}',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mostrarQRCode(context, inscricao);
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Ver QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
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
                          title: const Text('Cancelar Inscrição'),
                          content: const Text(
                            'Tem certeza que deseja cancelar esta inscrição?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Não'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Sim'),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true && context.mounted) {
                        // Guarda o contexto do ScaffoldMessenger
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        // Mostra loading
                        final navigator = Navigator.of(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => WillPopScope(
                            onWillPop: () async => false,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );

                        try {
                          await firestoreService.cancelarInscricao(
                            inscricao.id,
                            inscricao.atividadeId,
                          );

                          // Fecha o loading
                          navigator.pop();

                          // Aguarda um pouco para o dialog ser fechado
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Inscrição cancelada com sucesso'),
                              backgroundColor: AppColors.success,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          // Fecha o loading
                          navigator.pop();

                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );

                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao cancelar: ${e.toString()}',
                              ),
                              backgroundColor: AppColors.error,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
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

  void _mostrarQRCode(BuildContext context, Inscricao inscricao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code da Inscrição'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: inscricao.id,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Apresente este QR Code para fazer check-in',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${inscricao.id.substring(0, 8)}...',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
