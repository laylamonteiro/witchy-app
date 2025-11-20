import 'dart:convert';
import 'rune_model.dart';

enum RuneSpreadType {
  single,
  threeCast,
  nordicCross,
  nineWorlds;

  String get displayName {
    switch (this) {
      case RuneSpreadType.single:
        return 'Runa Única';
      case RuneSpreadType.threeCast:
        return 'Três Runas';
      case RuneSpreadType.nordicCross:
        return 'Cruz Nórdica';
      case RuneSpreadType.nineWorlds:
        return 'Nove Mundos';
    }
  }

  String get description {
    switch (this) {
      case RuneSpreadType.single:
        return 'Mensagem direta e rápida para sua situação atual';
      case RuneSpreadType.threeCast:
        return 'Passado, Presente e Futuro da sua questão';
      case RuneSpreadType.nordicCross:
        return 'Análise completa: situação, desafio, passado, futuro e resultado';
      case RuneSpreadType.nineWorlds:
        return 'Leitura profunda dos nove aspectos da sua vida';
    }
  }

  int get runeCount {
    switch (this) {
      case RuneSpreadType.single:
        return 1;
      case RuneSpreadType.threeCast:
        return 3;
      case RuneSpreadType.nordicCross:
        return 5;
      case RuneSpreadType.nineWorlds:
        return 9;
    }
  }

  String getPositionMeaning(int position) {
    switch (this) {
      case RuneSpreadType.single:
        return 'Mensagem';
      case RuneSpreadType.threeCast:
        return ['Passado', 'Presente', 'Futuro'][position];
      case RuneSpreadType.nordicCross:
        return ['Situação Atual', 'Desafio', 'Passado', 'Futuro', 'Resultado'][position];
      case RuneSpreadType.nineWorlds:
        return [
          'Eu Interior',
          'Mente',
          'Espírito',
          'Recursos',
          'Obstáculos',
          'Oportunidades',
          'Passado',
          'Presente',
          'Futuro'
        ][position];
    }
  }
}

class RunePosition {
  final int position;
  final RuneModel rune;
  final bool isReversed;
  final String positionMeaning;

  const RunePosition({
    required this.position,
    required this.rune,
    required this.isReversed,
    required this.positionMeaning,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'rune': rune.toJson(),
      'isReversed': isReversed,
      'positionMeaning': positionMeaning,
    };
  }

  factory RunePosition.fromJson(Map<String, dynamic> json) {
    return RunePosition(
      position: json['position'],
      rune: RuneModel.fromJson(json['rune']),
      isReversed: json['isReversed'],
      positionMeaning: json['positionMeaning'],
    );
  }
}

class RuneReading {
  final String id;
  final String question;
  final RuneSpreadType spreadType;
  final List<RunePosition> positions;
  final String? interpretation;
  final DateTime date;

  const RuneReading({
    required this.id,
    required this.question,
    required this.spreadType,
    required this.positions,
    this.interpretation,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'spreadType': spreadType.name,
      'positions': positions.map((p) => p.toJson()).toList(),
      'interpretation': interpretation,
      'date': date.toIso8601String(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory RuneReading.fromJson(Map<String, dynamic> json) {
    return RuneReading(
      id: json['id'],
      question: json['question'],
      spreadType: RuneSpreadType.values.firstWhere(
        (e) => e.name == json['spreadType'],
      ),
      positions: (json['positions'] as List)
          .map((p) => RunePosition.fromJson(p))
          .toList(),
      interpretation: json['interpretation'],
      date: DateTime.parse(json['date']),
    );
  }

  factory RuneReading.fromJsonString(String jsonString) {
    return RuneReading.fromJson(jsonDecode(jsonString));
  }
}
