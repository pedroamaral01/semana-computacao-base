import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../domain/entities/atividade.dart';
import '../data/providers/atividade_provider.dart';
import '../data/providers/agenda_provider.dart';
import '../data/providers/auth_provider.dart';

class AtividadeDetailScreen extends StatefulWidget {
  final String atividadeId;

  const AtividadeDetailScreen({super.key, required this.atividadeId});

  @override
  State<AtividadeDetailScreen> createState() => _AtividadeDetailScreenState();
}

class _AtividadeDetailScreenState extends State<AtividadeDetailScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final atividadeProvider = Provider.of<AtividadeProvider>(context);

    return FutureBuilder<Atividade?>(
      future: atividadeProvider.getAtividadeById(widget.atividadeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Carregando...'),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.erro),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
            ),
            body: const Center(child: Text('Atividade não encontrada')),
          );
        }

        final atividade = snapshot.data!;
        return _buildContent(context, atividade);
      },
    );
  }

  Widget _buildContent(BuildContext context, Atividade atividade) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final agendaProvider = Provider.of<AgendaProvider>(context);
    final isFavorito = agendaProvider.isFavorito(atividade.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(atividade.titulo),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(isFavorito ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              agendaProvider.toggleFavorito(atividade.id!);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: atividade.tipo == 'Palestra'
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              atividade.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, atividade.palestrante),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              dateFormat.format(atividade.data),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, atividade.horarioFormatado),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, atividade.local),
            // Mostra vagas disponíveis se a atividade tiver limite de vagas
            if (atividade.vagasTotal > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.people,
                '${atividade.vagasDisponiveis} de ${atividade.vagasTotal} vagas disponíveis',
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(atividade.descricao, style: const TextStyle(fontSize: 16)),
            // Mostra botão de inscrição para atividades com vagas limitadas
            if (atividade.vagasTotal > 0) ...[
              const SizedBox(height: 24),
              _buildInscricaoButton(context, atividade),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildInscricaoButton(BuildContext context, Atividade atividade) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final atividadeProvider = Provider.of<AtividadeProvider>(context);

    // Verifica se o usuário está autenticado
    if (authProvider.currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Faça login para se inscrever',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<bool>(
      future: atividadeProvider.isUsuarioInscrito(
        atividade.id!,
        authProvider.currentUser!.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isInscrito = snapshot.data ?? false;

        if (isInscrito) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Você está inscrito',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          );
        }

        if (atividade.vagasDisponiveis <= 0) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: AppColors.error),
                SizedBox(width: 8),
                Text(
                  AppStrings.semVagas,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }

        return CustomButton(
          text: AppStrings.inscreverSe,
          onPressed: () async {
            print('DEBUG - Usuário atual: ${authProvider.currentUser?.id}');
            print(
              'DEBUG - Usuário autenticado: ${authProvider.isAuthenticated}',
            );

            final success = await atividadeProvider.inscreverEmAtividade(
              atividade.id!,
              authProvider.currentUser!.id,
            );

            if (context.mounted) {
              final errorMessage =
                  atividadeProvider.error ??
                  'Erro desconhecido ao realizar inscrição';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? AppStrings.inscritoComSucesso : errorMessage,
                  ),
                  backgroundColor: success
                      ? AppColors.success
                      : AppColors.error,
                  duration: const Duration(seconds: 3),
                ),
              );

              // Recarrega a atividade para atualizar o estado
              if (success) {
                setState(() {});
              }
            }
          },
          isLoading: atividadeProvider.isLoading,
        );
      },
    );
  }
}
