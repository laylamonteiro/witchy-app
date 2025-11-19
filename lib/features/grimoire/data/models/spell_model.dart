import 'package:uuid/uuid.dart';

enum SpellType {
  attraction, // Atração/crescimento
  banishment, // Banimento/corte
}

enum MoonPhase {
  newMoon, // Lua nova
  waxingCrescent, // Crescente
  firstQuarter, // Quarto crescente
  waxingGibbous, // Gibosa crescente
  fullMoon, // Lua cheia
  waningGibbous, // Gibosa minguante
  lastQuarter, // Quarto minguante
  waningCrescent, // Minguante
}

class SpellModel {
  final String id;
  final String name;
  final String purpose;
  final SpellType type;
  final MoonPhase? moonPhase;
  final List<String> ingredients;
  final String steps;
  final int? duration; // em dias
  final String? observations;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpellModel({
    String? id,
    required this.name,
    required this.purpose,
    required this.type,
    this.moonPhase,
    required this.ingredients,
    required this.steps,
    this.duration,
    this.observations,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'purpose': purpose,
      'type': type.name,
      'moon_phase': moonPhase?.name,
      'ingredients': ingredients.join('|||'), // separador
      'steps': steps,
      'duration': duration,
      'observations': observations,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SpellModel.fromMap(Map<String, dynamic> map) {
    return SpellModel(
      id: map['id'],
      name: map['name'],
      purpose: map['purpose'],
      type: SpellType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SpellType.attraction,
      ),
      moonPhase: map['moon_phase'] != null
          ? MoonPhase.values.firstWhere(
              (e) => e.name == map['moon_phase'],
              orElse: () => MoonPhase.newMoon,
            )
          : null,
      ingredients: map['ingredients'] != null && map['ingredients'].isNotEmpty
          ? (map['ingredients'] as String).split('|||')
          : [],
      steps: map['steps'],
      duration: map['duration'],
      observations: map['observations'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  SpellModel copyWith({
    String? name,
    String? purpose,
    SpellType? type,
    MoonPhase? moonPhase,
    List<String>? ingredients,
    String? steps,
    int? duration,
    String? observations,
  }) {
    return SpellModel(
      id: id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      type: type ?? this.type,
      moonPhase: moonPhase ?? this.moonPhase,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      duration: duration ?? this.duration,
      observations: observations ?? this.observations,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// Extensões para tradução
extension SpellTypeExtension on SpellType {
  String get displayName {
    switch (this) {
      case SpellType.attraction:
        return 'Atração/Crescimento';
      case SpellType.banishment:
        return 'Banimento/Corte';
    }
  }
}

extension MoonPhaseExtension on MoonPhase {
  String get displayName {
    switch (this) {
      case MoonPhase.newMoon:
        return 'Lua Nova';
      case MoonPhase.waxingCrescent:
        return 'Crescente';
      case MoonPhase.firstQuarter:
        return 'Quarto Crescente';
      case MoonPhase.waxingGibbous:
        return 'Gibosa Crescente';
      case MoonPhase.fullMoon:
        return 'Lua Cheia';
      case MoonPhase.waningGibbous:
        return 'Gibosa Minguante';
      case MoonPhase.lastQuarter:
        return 'Quarto Minguante';
      case MoonPhase.waningCrescent:
        return 'Minguante';
    }
  }

  String get emoji {
    switch (this) {
      case MoonPhase.newMoon:
        return '🌑';
      case MoonPhase.waxingCrescent:
        return '🌒';
      case MoonPhase.firstQuarter:
        return '🌓';
      case MoonPhase.waxingGibbous:
        return '🌔';
      case MoonPhase.fullMoon:
        return '🌕';
      case MoonPhase.waningGibbous:
        return '🌖';
      case MoonPhase.lastQuarter:
        return '🌗';
      case MoonPhase.waningCrescent:
        return '🌘';
    }
  }

  String get description {
    switch (this) {
      case MoonPhase.newMoon:
        return 'Novos começos, intenções, planejamento';
      case MoonPhase.waxingCrescent:
        return 'Crescimento, atração, manifestação';
      case MoonPhase.firstQuarter:
        return 'Ação, decisão, superação de obstáculos';
      case MoonPhase.waxingGibbous:
        return 'Refinamento, ajustes, preparação';
      case MoonPhase.fullMoon:
        return 'Poder máximo, rituais importantes, gratidão';
      case MoonPhase.waningGibbous:
        return 'Gratidão, compartilhamento, ensino';
      case MoonPhase.lastQuarter:
        return 'Liberação, perdão, deixar ir';
      case MoonPhase.waningCrescent:
        return 'Descanso, reflexão, limpeza';
    }
  }
}
