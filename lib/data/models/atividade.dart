import 'package:flutter/material.dart';

class Atividade {
  final String id;
  final String titulo;
  final String descricao;
  final String palestrante;
  final DateTime data;
  final TimeOfDay horarioInicio;
  final TimeOfDay horarioFim;
  final String local;
  final String tipo; // "Palestra" ou "Minicurso"
  final bool aoVivo;
  final int vagasTotal;
  final int vagasDisponiveis;

  Atividade({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.palestrante,
    required this.data,
    required this.horarioInicio,
    required this.horarioFim,
    required this.local,
    required this.tipo,
    required this.aoVivo,
    required this.vagasTotal,
    required this.vagasDisponiveis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'palestrante': palestrante,
      'data': data.toIso8601String(),
      'horarioInicio': '${horarioInicio.hour}:${horarioInicio.minute}',
      'horarioFim': '${horarioFim.hour}:${horarioFim.minute}',
      'local': local,
      'tipo': tipo,
      'aoVivo': aoVivo,
      'vagasTotal': vagasTotal,
      'vagasDisponiveis': vagasDisponiveis,
    };
  }

  factory Atividade.fromJson(Map<String, dynamic> json) {
    final inicioStr = (json['horarioInicio'] as String).split(':');
    final fimStr = (json['horarioFim'] as String).split(':');

    return Atividade(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      palestrante: json['palestrante'] as String,
      data: DateTime.parse(json['data'] as String),
      horarioInicio: TimeOfDay(
        hour: int.parse(inicioStr[0]),
        minute: int.parse(inicioStr[1]),
      ),
      horarioFim: TimeOfDay(
        hour: int.parse(fimStr[0]),
        minute: int.parse(fimStr[1]),
      ),
      local: json['local'] as String,
      tipo: json['tipo'] as String,
      aoVivo: json['aoVivo'] as bool,
      vagasTotal: json['vagasTotal'] as int,
      vagasDisponiveis: json['vagasDisponiveis'] as int,
    );
  }

  Atividade copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? palestrante,
    DateTime? data,
    TimeOfDay? horarioInicio,
    TimeOfDay? horarioFim,
    String? local,
    String? tipo,
    bool? aoVivo,
    int? vagasTotal,
    int? vagasDisponiveis,
  }) {
    return Atividade(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      palestrante: palestrante ?? this.palestrante,
      data: data ?? this.data,
      horarioInicio: horarioInicio ?? this.horarioInicio,
      horarioFim: horarioFim ?? this.horarioFim,
      local: local ?? this.local,
      tipo: tipo ?? this.tipo,
      aoVivo: aoVivo ?? this.aoVivo,
      vagasTotal: vagasTotal ?? this.vagasTotal,
      vagasDisponiveis: vagasDisponiveis ?? this.vagasDisponiveis,
    );
  }

  String get horarioFormatado {
    return '${_formatTime(horarioInicio)} - ${_formatTime(horarioFim)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
