class Inscricao {
  final String id;
  final String usuarioId;
  final String atividadeId;
  final DateTime dataHora;
  final bool checkInRealizado;

  Inscricao({
    required this.id,
    required this.usuarioId,
    required this.atividadeId,
    required this.dataHora,
    required this.checkInRealizado,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'atividadeId': atividadeId,
      'dataHora': dataHora.toIso8601String(),
      'checkInRealizado': checkInRealizado,
    };
  }

  factory Inscricao.fromJson(Map<String, dynamic> json) {
    return Inscricao(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      atividadeId: json['atividadeId'] as String,
      dataHora: DateTime.parse(json['dataHora'] as String),
      checkInRealizado: json['checkInRealizado'] as bool,
    );
  }

  Inscricao copyWith({
    String? id,
    String? usuarioId,
    String? atividadeId,
    DateTime? dataHora,
    bool? checkInRealizado,
  }) {
    return Inscricao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      atividadeId: atividadeId ?? this.atividadeId,
      dataHora: dataHora ?? this.dataHora,
      checkInRealizado: checkInRealizado ?? this.checkInRealizado,
    );
  }
}
