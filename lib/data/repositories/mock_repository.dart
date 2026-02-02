import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/atividade.dart';
import '../models/pergunta.dart';
import '../models/inscricao.dart';

class MockRepository {
  // Usuários Mock
  static final List<Usuario> usuariosMock = [
    Usuario(
      id: '1',
      nome: 'João Participante',
      email: 'participante@ufop.edu.br',
      tipo: 'Participante',
      qrCode: 'QR_PARTICIPANTE_001',
    ),
    Usuario(
      id: '2',
      nome: 'Maria Organizadora',
      email: 'organizador@ufop.edu.br',
      tipo: 'Organizador',
      qrCode: 'QR_ORGANIZADOR_001',
    ),
  ];

  // Atividades Mock
  static final List<Atividade> atividadesMock = [
    Atividade(
      id: '1',
      titulo: 'Abertura da Semana da Computação',
      descricao:
          'Cerimônia de abertura com apresentação da programação completa do evento. Contaremos com a presença de autoridades da UFOP e do DECSI.',
      palestrante: 'Prof. João Silva',
      data: DateTime(2026, 3, 10),
      horarioInicio: const TimeOfDay(hour: 8, minute: 0),
      horarioFim: const TimeOfDay(hour: 9, minute: 0),
      local: 'Auditório Principal',
      tipo: 'Palestra',
      aoVivo: false,
      vagasTotal: 200,
      vagasDisponiveis: 200,
    ),
    Atividade(
      id: '2',
      titulo: 'Introdução ao Flutter',
      descricao:
          'Minicurso prático de desenvolvimento mobile com Flutter. Aprenda a criar aplicativos para Android e iOS com uma única base de código.',
      palestrante: 'Maria Santos',
      data: DateTime(2026, 3, 10),
      horarioInicio: const TimeOfDay(hour: 10, minute: 0),
      horarioFim: const TimeOfDay(hour: 12, minute: 0),
      local: 'Sala 10',
      tipo: 'Minicurso',
      aoVivo: false,
      vagasTotal: 30,
      vagasDisponiveis: 15,
    ),
    Atividade(
      id: '3',
      titulo: 'Inteligência Artificial no Cotidiano',
      descricao:
          'Palestra sobre as aplicações práticas de IA em nosso dia a dia e suas implicações éticas.',
      palestrante: 'Dr. Carlos Alberto',
      data: DateTime(2026, 3, 10),
      horarioInicio: const TimeOfDay(hour: 14, minute: 0),
      horarioFim: const TimeOfDay(hour: 16, minute: 0),
      local: 'Auditório Principal',
      tipo: 'Palestra',
      aoVivo: true,
      vagasTotal: 200,
      vagasDisponiveis: 180,
    ),
    Atividade(
      id: '4',
      titulo: 'Git e GitHub para Iniciantes',
      descricao:
          'Minicurso sobre controle de versão com Git e colaboração através do GitHub.',
      palestrante: 'Ana Paula',
      data: DateTime(2026, 3, 11),
      horarioInicio: const TimeOfDay(hour: 8, minute: 0),
      horarioFim: const TimeOfDay(hour: 10, minute: 0),
      local: 'Sala 12',
      tipo: 'Minicurso',
      aoVivo: false,
      vagasTotal: 25,
      vagasDisponiveis: 5,
    ),
    Atividade(
      id: '5',
      titulo: 'Desenvolvimento Web Moderno',
      descricao:
          'Palestra sobre as tendências atuais em desenvolvimento web: frameworks, ferramentas e melhores práticas.',
      palestrante: 'Prof. Roberto Lima',
      data: DateTime(2026, 3, 11),
      horarioInicio: const TimeOfDay(hour: 10, minute: 30),
      horarioFim: const TimeOfDay(hour: 12, minute: 0),
      local: 'Auditório Principal',
      tipo: 'Palestra',
      aoVivo: false,
      vagasTotal: 200,
      vagasDisponiveis: 150,
    ),
    Atividade(
      id: '6',
      titulo: 'Segurança da Informação',
      descricao:
          'Workshop sobre práticas de segurança em aplicações web e proteção de dados.',
      palestrante: 'Dra. Patricia Souza',
      data: DateTime(2026, 3, 11),
      horarioInicio: const TimeOfDay(hour: 14, minute: 0),
      horarioFim: const TimeOfDay(hour: 17, minute: 0),
      local: 'Sala 15',
      tipo: 'Minicurso',
      aoVivo: false,
      vagasTotal: 20,
      vagasDisponiveis: 0,
    ),
    Atividade(
      id: '7',
      titulo: 'Machine Learning na Prática',
      descricao:
          'Minicurso prático sobre algoritmos de Machine Learning e suas aplicações.',
      palestrante: 'Prof. Fernando Costa',
      data: DateTime(2026, 3, 12),
      horarioInicio: const TimeOfDay(hour: 8, minute: 0),
      horarioFim: const TimeOfDay(hour: 11, minute: 0),
      local: 'Lab. de Computação',
      tipo: 'Minicurso',
      aoVivo: false,
      vagasTotal: 30,
      vagasDisponiveis: 12,
    ),
    Atividade(
      id: '8',
      titulo: 'Carreira em Tecnologia',
      descricao:
          'Mesa redonda com profissionais da área discutindo oportunidades e desafios na carreira de TI.',
      palestrante: 'Diversos Palestrantes',
      data: DateTime(2026, 3, 12),
      horarioInicio: const TimeOfDay(hour: 14, minute: 0),
      horarioFim: const TimeOfDay(hour: 16, minute: 0),
      local: 'Auditório Principal',
      tipo: 'Palestra',
      aoVivo: false,
      vagasTotal: 200,
      vagasDisponiveis: 190,
    ),
    Atividade(
      id: '9',
      titulo: 'Cloud Computing e DevOps',
      descricao:
          'Palestra sobre arquiteturas em nuvem e práticas DevOps para deploy contínuo.',
      palestrante: 'Eng. Lucas Martins',
      data: DateTime(2026, 3, 12),
      horarioInicio: const TimeOfDay(hour: 16, minute: 30),
      horarioFim: const TimeOfDay(hour: 18, minute: 0),
      local: 'Sala 10',
      tipo: 'Palestra',
      aoVivo: false,
      vagasTotal: 100,
      vagasDisponiveis: 85,
    ),
    Atividade(
      id: '10',
      titulo: 'Encerramento da Semana da Computação',
      descricao:
          'Cerimônia de encerramento com premiação dos participantes e entrega de certificados.',
      palestrante: 'Comissão Organizadora',
      data: DateTime(2026, 3, 12),
      horarioInicio: const TimeOfDay(hour: 18, minute: 30),
      horarioFim: const TimeOfDay(hour: 20, minute: 0),
      local: 'Auditório Principal',
      tipo: 'Palestra',
      aoVivo: false,
      vagasTotal: 200,
      vagasDisponiveis: 200,
    ),
  ];

  // Perguntas Mock
  static List<Pergunta> perguntasMock = [];

  // Inscrições Mock
  static List<Inscricao> inscricoesMock = [];

  // Métodos para manipular dados
  Usuario? autenticarUsuario(String email, String senha) {
    try {
      return usuariosMock.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Atividade> getAtividades() {
    return List.from(atividadesMock);
  }

  Atividade? getAtividadeById(String id) {
    try {
      return atividadesMock.firstWhere((ativ) => ativ.id == id);
    } catch (e) {
      return null;
    }
  }

  void adicionarPergunta(Pergunta pergunta) {
    perguntasMock.add(pergunta);
  }

  List<Pergunta> getPerguntasByAtividade(String atividadeId) {
    return perguntasMock.where((p) => p.atividadeId == atividadeId).toList();
  }

  void adicionarInscricao(Inscricao inscricao) {
    inscricoesMock.add(inscricao);

    // Atualizar vagas disponíveis
    final index = atividadesMock.indexWhere(
      (a) => a.id == inscricao.atividadeId,
    );
    if (index != -1) {
      final atividade = atividadesMock[index];
      atividadesMock[index] = atividade.copyWith(
        vagasDisponiveis: atividade.vagasDisponiveis - 1,
      );
    }
  }

  bool isUsuarioInscrito(String usuarioId, String atividadeId) {
    return inscricoesMock.any(
      (i) => i.usuarioId == usuarioId && i.atividadeId == atividadeId,
    );
  }

  void realizarCheckin(String qrCode) {
    final inscricao = inscricoesMock.firstWhere(
      (i) => i.usuarioId == qrCode,
      orElse: () => throw Exception('Inscrição não encontrada'),
    );

    final index = inscricoesMock.indexOf(inscricao);
    inscricoesMock[index] = inscricao.copyWith(checkInRealizado: true);
  }

  Usuario? getUsuarioByQrCode(String qrCode) {
    try {
      return usuariosMock.firstWhere((u) => u.qrCode == qrCode);
    } catch (e) {
      return null;
    }
  }
}
