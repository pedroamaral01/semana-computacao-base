import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../data/providers/atividade_provider.dart';
import '../data/providers/pergunta_provider.dart';

class PerguntasRecebidasScreen extends StatelessWidget {
  const PerguntasRecebidasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final atividadeProvider = Provider.of<AtividadeProvider>(context);
    final perguntaProvider = Provider.of<PerguntaProvider>(context);
    final atividades = atividadeProvider.atividades;

    // Agrupar perguntas por atividade
    final Map<String, List> perguntasPorAtividade = {};

    for (final atividade in atividades) {
      if (atividade.id != null) {
        final perguntas = perguntaProvider.getPerguntasByAtividade(
          atividade.id!,
        );
        if (perguntas.isNotEmpty) {
          perguntasPorAtividade[atividade.id!] = [atividade, perguntas];
        }
      }
    }

    if (perguntasPorAtividade.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma pergunta recebida',
              style: TextStyle(fontSize: 16, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: perguntasPorAtividade.length,
      itemBuilder: (context, index) {
        final entry = perguntasPorAtividade.entries.elementAt(index);
        final atividade = entry.value[0];
        final perguntas = entry.value[1];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              atividade.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${perguntas.length} perguntas',
              style: const TextStyle(color: AppColors.grey),
            ),
            children: perguntas.map<Widget>((pergunta) {
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
              return ListTile(
                leading: const Icon(
                  Icons.question_answer,
                  color: AppColors.primaryBlue,
                ),
                title: Text(pergunta.texto),
                subtitle: Text(
                  dateFormat.format(pergunta.dataHora),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
