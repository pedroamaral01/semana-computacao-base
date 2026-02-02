class Usuario {
  final String id;
  final String nome;
  final String email;
  final String tipo; // "Participante" ou "Organizador"
  final String qrCode;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.qrCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'qrCode': qrCode,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      tipo: json['tipo'] as String,
      qrCode: json['qrCode'] as String,
    );
  }

  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipo,
    String? qrCode,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipo: tipo ?? this.tipo,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
