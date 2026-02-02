class Pergunta {
  final String id;
  final String usuarioId;
  final String atividadeId;
  final String texto;
  final DateTime dataHora;

  Pergunta({
    required this.id,
    required this.usuarioId,
    required this.atividadeId,
    required this.texto,
    required this.dataHora,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'atividadeId': atividadeId,
      'texto': texto,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      atividadeId: json['atividadeId'] as String,
      texto: json['texto'] as String,
      dataHora: DateTime.parse(json['dataHora'] as String),
    );
  }
}
