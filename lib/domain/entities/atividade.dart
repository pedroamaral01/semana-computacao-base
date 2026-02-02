class Atividade {
  final String? id;
  final String titulo;
  final String descricao;
  final String tipo;
  final String palestrante;
  final String local;
  final DateTime dataHora;
  final int duracao;
  final int vagas;
  final int vagasDisponiveis;
  final bool aoVivo;
  final String criadoPor;

  Atividade({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.palestrante,
    required this.local,
    required this.dataHora,
    required this.duracao,
    required this.vagas,
    required this.vagasDisponiveis,
    this.aoVivo = false,
    required this.criadoPor,
  });

  // Getter para compatibilidade com código antigo
  DateTime get data => dataHora;
  int get vagasTotal => vagas;

  String get horarioFormatado {
    final inicio = dataHora;
    final fim = dataHora.add(Duration(minutes: duracao));
    return '${_formatTime(inicio)} - ${_formatTime(fim)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'palestrante': palestrante,
      'local': local,
      'dataHora': dataHora.toIso8601String(),
      'duracao': duracao,
      'vagas': vagas,
      'vagasDisponiveis': vagasDisponiveis,
      'aoVivo': aoVivo,
      'criadoPor': criadoPor,
    };
  }

  factory Atividade.fromMap(Map<String, dynamic> map, String id) {
    return Atividade(
      id: id,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      tipo: map['tipo'] ?? '',
      palestrante: map['palestrante'] ?? '',
      local: map['local'] ?? '',
      dataHora: DateTime.parse(map['dataHora']),
      duracao: map['duracao'] ?? 0,
      vagas: map['vagas'] ?? 0,
      vagasDisponiveis: map['vagasDisponiveis'] ?? 0,
      aoVivo: map['aoVivo'] ?? false,
      criadoPor: map['criadoPor'] ?? '',
    );
  }

  Atividade copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? tipo,
    String? palestrante,
    String? local,
    DateTime? dataHora,
    int? duracao,
    int? vagas,
    int? vagasDisponiveis,
    bool? aoVivo,
    String? criadoPor,
  }) {
    return Atividade(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      palestrante: palestrante ?? this.palestrante,
      local: local ?? this.local,
      dataHora: dataHora ?? this.dataHora,
      duracao: duracao ?? this.duracao,
      vagas: vagas ?? this.vagas,
      vagasDisponiveis: vagasDisponiveis ?? this.vagasDisponiveis,
      aoVivo: aoVivo ?? this.aoVivo,
      criadoPor: criadoPor ?? this.criadoPor,
    );
  }
}
