// lib/models/spell.dart
enum SpellType {
  attraction, // crescimento / atração
  banishment, // banimento / corte
}

class Spell {
  final String id; // uuid ou timestamp
  final String name;
  final List<String> tags; // ["proteção", "amor próprio"]
  final SpellType type;
  final String? moonPhaseRecommendation; // "Lua Nova", "Lua Crescente", etc.
  final String ingredients; // texto livre por enquanto
  final String steps;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Spell({
    required this.id,
    required this.name,
    required this.tags,
    required this.type,
    this.moonPhaseRecommendation,
    required this.ingredients,
    required this.steps,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Spell copyWith({
    String? id,
    String? name,
    List<String>? tags,
    SpellType? type,
    String? moonPhaseRecommendation,
    String? ingredients,
    String? steps,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Spell(
      id: id ?? this.id,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      moonPhaseRecommendation:
          moonPhaseRecommendation ?? this.moonPhaseRecommendation,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tags': tags,
      'type': type.name,
      'moonPhaseRecommendation': moonPhaseRecommendation,
      'ingredients': ingredients,
      'steps': steps,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Spell.fromMap(Map<String, dynamic> map) {
    return Spell(
      id: map['id'] as String,
      name: map['name'] as String,
      tags: List<String>.from(map['tags'] ?? []),
      type: SpellType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => SpellType.attraction,
      ),
      moonPhaseRecommendation: map['moonPhaseRecommendation'] as String?,
      ingredients: map['ingredients'] as String,
      steps: map['steps'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
