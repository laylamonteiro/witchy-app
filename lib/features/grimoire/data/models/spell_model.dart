import 'package:uuid/uuid.dart';

enum SpellType {
  attraction, // Atração/crescimento
  banishment, // Banimento/corte
}

enum SpellCategory {
  love, // Amor e romance
  selfLove, // Amor próprio
  protection, // Proteção
  prosperity, // Prosperidade e dinheiro
  healing, // Cura
  cleansing, // Limpeza energética
  banishing, // Banimento
  luck, // Sorte
  creativity, // Criatividade
  communication, // Comunicação
  dreams, // Sonhos
  divination, // Adivinhação
  energy, // Energia e vitalidade
  wisdom, // Sabedoria
  courage, // Coragem
  friendship, // Amizade
  home, // Casa e lar
  work, // Trabalho e carreira
  study, // Estudos
  other, // Outros
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
  /// Marcador persistido em `spells.user_id` para feitiços globais/precarregados.
  static const String globalUserId = 'global';

  final String id;
  final String? userId;
  final String name;
  final String purpose;
  final SpellType type;
  final SpellCategory category;
  final MoonPhase? moonPhase;
  final List<String> ingredients;
  final String steps;
  final int? duration; // em dias
  final String? observations;
  final bool isPreloaded; // Se é um feitiço pré-carregado do app
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  SpellModel({
    String? id,
    this.userId,
    required this.name,
    required this.purpose,
    required this.type,
    required this.category,
    this.moonPhase,
    required this.ingredients,
    required this.steps,
    this.duration,
    this.observations,
    this.isPreloaded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Páginas de registro do Grimório Vivo (aba "Meus Registros"):
  /// gravadas como feitiço, mas separadas dos feitiços de verdade.
  bool get isRecord => id.startsWith('registro_');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': isPreloaded ? globalUserId : (userId ?? 'local_user'),
      'name': name,
      'purpose': purpose,
      'type': type.name,
      'category': category.name,
      'moon_phase': moonPhase?.name,
      'ingredients': ingredients.join('|||'), // separador
      'steps': steps,
      'duration': duration,
      'observations': observations,
      'is_preloaded': isPreloaded ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
    };
  }

  factory SpellModel.fromMap(Map<String, dynamic> map) {
    return SpellModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      purpose: map['purpose'],
      type: SpellType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SpellType.attraction,
      ),
      category: SpellCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => SpellCategory.other,
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
      isPreloaded: map['is_preloaded'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      synced: map['synced'] == 1,
    );
  }

  SpellModel copyWith({
    String? userId,
    String? name,
    String? purpose,
    SpellType? type,
    SpellCategory? category,
    MoonPhase? moonPhase,
    List<String>? ingredients,
    String? steps,
    int? duration,
    String? observations,
    bool? synced,
  }) {
    return SpellModel(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      type: type ?? this.type,
      category: category ?? this.category,
      moonPhase: moonPhase ?? this.moonPhase,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      duration: duration ?? this.duration,
      observations: observations ?? this.observations,
      isPreloaded: isPreloaded,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
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

extension SpellCategoryExtension on SpellCategory {
  String get displayName {
    switch (this) {
      case SpellCategory.love:
        return 'Amor e Romance';
      case SpellCategory.selfLove:
        return 'Amor Próprio';
      case SpellCategory.protection:
        return 'Proteção';
      case SpellCategory.prosperity:
        return 'Prosperidade';
      case SpellCategory.healing:
        return 'Cura';
      case SpellCategory.cleansing:
        return 'Limpeza';
      case SpellCategory.banishing:
        return 'Banimento';
      case SpellCategory.luck:
        return 'Sorte';
      case SpellCategory.creativity:
        return 'Criatividade';
      case SpellCategory.communication:
        return 'Comunicação';
      case SpellCategory.dreams:
        return 'Sonhos';
      case SpellCategory.divination:
        return 'Adivinhação';
      case SpellCategory.energy:
        return 'Energia';
      case SpellCategory.wisdom:
        return 'Sabedoria';
      case SpellCategory.courage:
        return 'Coragem';
      case SpellCategory.friendship:
        return 'Amizade';
      case SpellCategory.home:
        return 'Casa e Lar';
      case SpellCategory.work:
        return 'Trabalho';
      case SpellCategory.study:
        return 'Estudos';
      case SpellCategory.other:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case SpellCategory.love:
        return '💖';
      case SpellCategory.selfLove:
        return '💗';
      case SpellCategory.protection:
        return '🛡️';
      case SpellCategory.prosperity:
        return '💰';
      case SpellCategory.healing:
        return '💚';
      case SpellCategory.cleansing:
        return '✨';
      case SpellCategory.banishing:
        return '🚫';
      case SpellCategory.luck:
        return '🍀';
      case SpellCategory.creativity:
        return '🎨';
      case SpellCategory.communication:
        return '💬';
      case SpellCategory.dreams:
        return '💤';
      case SpellCategory.divination:
        return '🔮';
      case SpellCategory.energy:
        return '⚡';
      case SpellCategory.wisdom:
        return '📚';
      case SpellCategory.courage:
        return '🦁';
      case SpellCategory.friendship:
        return '👥';
      case SpellCategory.home:
        return '🏠';
      case SpellCategory.work:
        return '💼';
      case SpellCategory.study:
        return '📖';
      case SpellCategory.other:
        return '🌟';
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
