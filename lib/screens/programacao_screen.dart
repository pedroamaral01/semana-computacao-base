import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../domain/entities/atividade.dart';
import '../data/providers/atividade_provider.dart';
import '../data/providers/agenda_provider.dart';
import 'atividade_detail_screen.dart';

class ProgramacaoScreen extends StatefulWidget {
  const ProgramacaoScreen({super.key});

  @override
  State<ProgramacaoScreen> createState() => _ProgramacaoScreenState();
}

class _ProgramacaoScreenState extends State<ProgramacaoScreen> {
  String? _tipoSelecionado;
  DateTime? _dataSelecionada;

  @override
  Widget build(BuildContext context) {
    return Consumer<AtividadeProvider>(
      builder: (context, atividadeProvider, child) {
        final atividades = atividadeProvider.aplicarFiltros(
          tipo: _tipoSelecionado,
          data: _dataSelecionada,
        );
        final datas = atividadeProvider.getDatasDisponiveis();

        if (atividadeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildFiltros(datas),
            Expanded(
              child: atividades.isEmpty
                  ? const Center(child: Text(AppStrings.nenhumaAtividade))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: atividades.length,
                      itemBuilder: (context, index) {
                        return _buildAtividadeCard(context, atividades[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltros(List<DateTime> datas) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: AppStrings.filtrarPorTipo,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(AppStrings.todos),
                    ),
                    const DropdownMenuItem(
                      value: 'Palestra',
                      child: Text(AppStrings.palestra),
                    ),
                    const DropdownMenuItem(
                      value: 'Minicurso',
                      child: Text(AppStrings.minicurso),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoSelecionado = value;
                    });
                    _aplicarFiltros();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  value: _dataSelecionada,
                  decoration: const InputDecoration(
                    labelText: AppStrings.filtrarPorDia,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text(AppStrings.todos),
                    ),
                    ...datas.map((data) {
                      return DropdownMenuItem(
                        value: data,
                        child: Text(DateFormat('dd/MM').format(data)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _dataSelecionada = value;
                    });
                    _aplicarFiltros();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _aplicarFiltros() {
    setState(() {
      // Os filtros já foram aplicados no build
    });
  }

  Widget _buildAtividadeCard(BuildContext context, Atividade atividade) {
    final agendaProvider = Provider.of<AgendaProvider>(context);
    final isFavorito = agendaProvider.isFavorito(atividade.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AtividadeDetailScreen(atividadeId: atividade.id!),
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
                    icon: Icon(
                      isFavorito ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorito ? AppColors.accentGold : AppColors.grey,
                    ),
                    onPressed: () {
                      agendaProvider.toggleFavorito(atividade.id!);
                    },
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
                  if (atividade.aoVivo) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        AppStrings.aoVivo,
                        style: TextStyle(fontSize: 12, color: AppColors.white),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Por: ${atividade.palestrante}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
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
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(atividade.local, style: const TextStyle(fontSize: 14)),
                ],
              ),
              if (atividade.tipo == 'Minicurso') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${atividade.vagasDisponiveis} ${AppStrings.vagasDisponiveis}',
                      style: TextStyle(
                        fontSize: 14,
                        color: atividade.vagasDisponiveis > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
