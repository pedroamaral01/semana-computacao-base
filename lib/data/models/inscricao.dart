class Inscricao {
  final String id;
  final String usuarioId;
  final String atividadeId;
  final DateTime dataHora;
  final bool checkInRealizado;
  final DateTime? dataCheckin;

  Inscricao({
    required this.id,
    required this.usuarioId,
    required this.atividadeId,
    required this.dataHora,
    required this.checkInRealizado,
    this.dataCheckin,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'atividadeId': atividadeId,
      'dataInscricao': dataHora.toIso8601String(),
      'checkinRealizado': checkInRealizado,
      'dataCheckin': dataCheckin?.toIso8601String(),
    };
  }

  factory Inscricao.fromJson(Map<String, dynamic> json) {
    // O 'id' vem do documento do Firestore, já está no map
    final id = json['id'] as String? ?? '';

    // usuarioId e atividadeId são obrigatórios
    final usuarioId = json['usuarioId'] as String? ?? '';
    final atividadeId = json['atividadeId'] as String? ?? '';

    // dataInscricao pode ser Timestamp do Firestore ou String
    DateTime dataHora;
    try {
      final dataInscricao = json['dataInscricao'];
      if (dataInscricao == null) {
        dataHora = DateTime.now();
      } else if (dataInscricao is String) {
        dataHora = DateTime.parse(dataInscricao);
      } else {
        // É um Timestamp do Firestore
        dataHora = (dataInscricao as dynamic).toDate();
      }
    } catch (e) {
      print('⚠️ Erro ao parsear dataInscricao: $e');
      dataHora = DateTime.now();
    }

    // checkinRealizado (sem maiúscula no I)
    final checkInRealizado = json['checkinRealizado'] as bool? ?? false;

    // dataCheckin pode ser null
    DateTime? dataCheckin;
    try {
      final dataCheckinValue = json['dataCheckin'];
      if (dataCheckinValue != null) {
        if (dataCheckinValue is String) {
          dataCheckin = DateTime.parse(dataCheckinValue);
        } else {
          dataCheckin = (dataCheckinValue as dynamic).toDate();
        }
      }
    } catch (e) {
      print('⚠️ Erro ao parsear dataCheckin: $e');
    }

    return Inscricao(
      id: id,
      usuarioId: usuarioId,
      atividadeId: atividadeId,
      dataHora: dataHora,
      checkInRealizado: checkInRealizado,
      dataCheckin: dataCheckin,
    );
  }

  Inscricao copyWith({
    String? id,
    String? usuarioId,
    String? atividadeId,
    DateTime? dataHora,
    bool? checkInRealizado,
    DateTime? dataCheckin,
  }) {
    return Inscricao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      atividadeId: atividadeId ?? this.atividadeId,
      dataHora: dataHora ?? this.dataHora,
      checkInRealizado: checkInRealizado ?? this.checkInRealizado,
      dataCheckin: dataCheckin ?? this.dataCheckin,
    );
  }
}
