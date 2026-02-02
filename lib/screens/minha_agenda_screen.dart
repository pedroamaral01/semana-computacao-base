import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../data/models/atividade.dart';
import '../data/providers/agenda_provider.dart';
import 'atividade_detail_screen.dart';

class MinhaAgendaScreen extends StatelessWidget {
  const MinhaAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AgendaProvider>(
      builder: (context, agendaProvider, child) {
        final atividades = agendaProvider.getAtividadesFavoritas();

        return Column(
          children: [
            _buildNotificationToggle(context, agendaProvider),
            Expanded(
              child: atividades.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 80,
                            color: AppColors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            AppStrings.nenhumaAtividadeFavoritada,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: atividades.length,
                      itemBuilder: (context, index) {
                        return _buildAtividadeCard(
                          context,
                          atividades[index],
                          agendaProvider,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    AgendaProvider agendaProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        children: [
          const Icon(Icons.notifications, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Notificações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: agendaProvider.notificacoesHabilitadas,
            onChanged: (value) {
              agendaProvider.toggleNotificacoes();
            },
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildAtividadeCard(
    BuildContext context,
    Atividade atividade,
    AgendaProvider agendaProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AtividadeDetailScreen(atividadeId: atividade.id),
            ),
          );
        },
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
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: AppColors.accentGold,
                    ),
                    onPressed: () {
                      agendaProvider.toggleFavorito(atividade.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(height: 8),
              Text(
                'Por: ${atividade.palestrante}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
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
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.grey,
                  ),
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
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(atividade.local, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
