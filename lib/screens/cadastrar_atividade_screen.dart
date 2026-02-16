import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../domain/entities/atividade.dart';
import '../data/providers/auth_provider.dart';
import '../services/firestore_service.dart';

class CadastrarAtividadeScreen extends StatefulWidget {
  final Atividade? atividade; // null para nova atividade

  const CadastrarAtividadeScreen({super.key, this.atividade});

  @override
  State<CadastrarAtividadeScreen> createState() =>
      _CadastrarAtividadeScreenState();
}

class _CadastrarAtividadeScreenState extends State<CadastrarAtividadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _palestranteController = TextEditingController();
  final _localController = TextEditingController();
  final _vagasTotalController = TextEditingController();
  final firestoreService = FirestoreService();

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horarioInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horarioFim = const TimeOfDay(hour: 10, minute: 0);
  String _tipoSelecionado = 'Palestra';
  bool _aoVivo = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.atividade != null) {
      _carregarDados();
    }
  }

  void _carregarDados() {
    final ativ = widget.atividade!;
    _tituloController.text = ativ.titulo;
    _descricaoController.text = ativ.descricao;
    _palestranteController.text = ativ.palestrante;
    _localController.text = ativ.local;
    _vagasTotalController.text = ativ.vagas.toString();
    _dataSelecionada = ativ.dataHora;

    // Calcular horários a partir de dataHora e duracao
    _horarioInicio = TimeOfDay.fromDateTime(ativ.dataHora);
    final fim = ativ.dataHora.add(Duration(minutes: ativ.duracao));
    _horarioFim = TimeOfDay.fromDateTime(fim);

    _tipoSelecionado = ativ.tipo;
    _aoVivo = ativ.aoVivo;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _palestranteController.dispose();
    _localController.dispose();
    _vagasTotalController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _selecionarHorario(bool isInicio) async {
    final horario = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horarioInicio : _horarioFim,
    );

    if (horario != null) {
      setState(() {
        if (isInicio) {
          _horarioInicio = horario;
        } else {
          _horarioFim = horario;
        }
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioId = authProvider.currentUser?.id ?? '';

      // Calcular duração em minutos
      final inicioEmMinutos = _horarioInicio.hour * 60 + _horarioInicio.minute;
      final fimEmMinutos = _horarioFim.hour * 60 + _horarioFim.minute;
      final duracao = fimEmMinutos - inicioEmMinutos;

      // Combinar data com horário
      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horarioInicio.hour,
        _horarioInicio.minute,
      );

      final atividade = Atividade(
        id: widget.atividade?.id,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        palestrante: _palestranteController.text.trim(),
        dataHora: dataHora,
        duracao: duracao,
        local: _localController.text.trim(),
        tipo: _tipoSelecionado,
        aoVivo: _aoVivo,
        vagas: int.parse(_vagasTotalController.text),
        vagasDisponiveis:
            widget.atividade?.vagasDisponiveis ??
            int.parse(_vagasTotalController.text),
        criadoPor: usuarioId,
      );

      if (widget.atividade == null) {
        await firestoreService.criarAtividade(atividade);
      } else {
        await firestoreService.atualizarAtividade(atividade.id!, atividade);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.atividade == null
                  ? 'Atividade criada com sucesso!'
                  : 'Atividade atualizada com sucesso!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar atividade'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.atividade == null ? 'Nova Atividade' : 'Editar Atividade',
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Título',
                controller: _tituloController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Descrição',
                controller: _descricaoController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Palestrante/Instrutor',
                controller: _palestranteController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Palestra', child: Text('Palestra')),
                  DropdownMenuItem(
                    value: 'Minicurso',
                    child: Text('Minicurso'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(dateFormat.format(_dataSelecionada)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selecionarHorario(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário Início',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_horarioInicio.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selecionarHorario(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Horário Fim',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_horarioFim.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Local',
                controller: _localController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Quantidade de Vagas',
                controller: _vagasTotalController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Digite 0 para atividade sem inscrição (palestras abertas)',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Atividade Ao Vivo'),
                subtitle: const Text(
                  'Permite envio de perguntas em tempo real',
                ),
                value: _aoVivo,
                onChanged: (value) {
                  setState(() {
                    _aoVivo = value;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.atividade == null
                    ? 'Criar Atividade'
                    : 'Salvar Alterações',
                onPressed: _salvar,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
