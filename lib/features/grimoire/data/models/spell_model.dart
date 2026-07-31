import 'package:uuid/uuid.dart';

import '../../../../core/content/content_locale.dart';

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
// Nomes de exibição por idioma (a chave persistida é o enum.name, invariante;
// paridade das 3 línguas testada em content_models_parity_test).
extension SpellTypeExtension on SpellType {
  String get displayName => ContentLocale.instance.select(
        pt: _spellTypeNamesPt,
        en: _spellTypeNamesEn,
        es: _spellTypeNamesEs,
      )[this]!;
}

const Map<SpellType, String> _spellTypeNamesPt = {
  SpellType.attraction: 'Atração/Crescimento',
  SpellType.banishment: 'Banimento/Corte',
};

const Map<SpellType, String> _spellTypeNamesEn = {
  SpellType.attraction: 'Attraction/Growth',
  SpellType.banishment: 'Banishing/Cutting',
};

const Map<SpellType, String> _spellTypeNamesEs = {
  SpellType.attraction: 'Atracción/Crecimiento',
  SpellType.banishment: 'Destierro/Corte',
};

extension SpellCategoryExtension on SpellCategory {
  String get displayName => ContentLocale.instance.select(
        pt: _spellCategoryNamesPt,
        en: _spellCategoryNamesEn,
        es: _spellCategoryNamesEs,
      )[this]!;

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
  String get displayName => ContentLocale.instance.select(
        pt: _moonPhaseNamesPt,
        en: _moonPhaseNamesEn,
        es: _moonPhaseNamesEs,
      )[this]!;

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

  String get description => ContentLocale.instance.select(
        pt: _moonPhaseDescriptionsPt,
        en: _moonPhaseDescriptionsEn,
        es: _moonPhaseDescriptionsEs,
      )[this]!;
}

const Map<MoonPhase, String> _moonPhaseNamesPt = {
  MoonPhase.newMoon: 'Lua Nova',
  MoonPhase.waxingCrescent: 'Crescente',
  MoonPhase.firstQuarter: 'Quarto Crescente',
  MoonPhase.waxingGibbous: 'Gibosa Crescente',
  MoonPhase.fullMoon: 'Lua Cheia',
  MoonPhase.waningGibbous: 'Gibosa Minguante',
  MoonPhase.lastQuarter: 'Quarto Minguante',
  MoonPhase.waningCrescent: 'Minguante',
};

const Map<MoonPhase, String> _moonPhaseNamesEn = {
  MoonPhase.newMoon: 'New Moon',
  MoonPhase.waxingCrescent: 'Waxing Crescent',
  MoonPhase.firstQuarter: 'First Quarter',
  MoonPhase.waxingGibbous: 'Waxing Gibbous',
  MoonPhase.fullMoon: 'Full Moon',
  MoonPhase.waningGibbous: 'Waning Gibbous',
  MoonPhase.lastQuarter: 'Last Quarter',
  MoonPhase.waningCrescent: 'Waning Crescent',
};

const Map<MoonPhase, String> _moonPhaseNamesEs = {
  MoonPhase.newMoon: 'Luna Nueva',
  MoonPhase.waxingCrescent: 'Luna Creciente',
  MoonPhase.firstQuarter: 'Cuarto Creciente',
  MoonPhase.waxingGibbous: 'Gibosa Creciente',
  MoonPhase.fullMoon: 'Luna Llena',
  MoonPhase.waningGibbous: 'Gibosa Menguante',
  MoonPhase.lastQuarter: 'Cuarto Menguante',
  MoonPhase.waningCrescent: 'Luna Menguante',
};

const Map<MoonPhase, String> _moonPhaseDescriptionsPt = {
  MoonPhase.newMoon: 'Novos começos, intenções, planejamento',
  MoonPhase.waxingCrescent: 'Crescimento, atração, manifestação',
  MoonPhase.firstQuarter: 'Ação, decisão, superação de obstáculos',
  MoonPhase.waxingGibbous: 'Refinamento, ajustes, preparação',
  MoonPhase.fullMoon: 'Poder máximo, rituais importantes, gratidão',
  MoonPhase.waningGibbous: 'Gratidão, compartilhamento, ensino',
  MoonPhase.lastQuarter: 'Liberação, perdão, deixar ir',
  MoonPhase.waningCrescent: 'Descanso, reflexão, limpeza',
};

const Map<MoonPhase, String> _moonPhaseDescriptionsEn = {
  MoonPhase.newMoon: 'New beginnings, intentions, planning',
  MoonPhase.waxingCrescent: 'Growth, attraction, manifestation',
  MoonPhase.firstQuarter: 'Action, decision, overcoming obstacles',
  MoonPhase.waxingGibbous: 'Refinement, adjustments, preparation',
  MoonPhase.fullMoon: 'Peak power, important rituals, gratitude',
  MoonPhase.waningGibbous: 'Gratitude, sharing, teaching',
  MoonPhase.lastQuarter: 'Release, forgiveness, letting go',
  MoonPhase.waningCrescent: 'Rest, reflection, cleansing',
};

const Map<MoonPhase, String> _moonPhaseDescriptionsEs = {
  MoonPhase.newMoon: 'Nuevos comienzos, intenciones, planificación',
  MoonPhase.waxingCrescent: 'Crecimiento, atracción, manifestación',
  MoonPhase.firstQuarter: 'Acción, decisión, superación de obstáculos',
  MoonPhase.waxingGibbous: 'Refinamiento, ajustes, preparación',
  MoonPhase.fullMoon: 'Poder máximo, rituales importantes, gratitud',
  MoonPhase.waningGibbous: 'Gratitud, compartir, enseñanza',
  MoonPhase.lastQuarter: 'Liberación, perdón, dejar ir',
  MoonPhase.waningCrescent: 'Descanso, reflexión, limpieza',
};

const Map<SpellCategory, String> _spellCategoryNamesPt = {
  SpellCategory.love: 'Amor e Romance',
  SpellCategory.selfLove: 'Amor Próprio',
  SpellCategory.protection: 'Proteção',
  SpellCategory.prosperity: 'Prosperidade',
  SpellCategory.healing: 'Cura',
  SpellCategory.cleansing: 'Limpeza',
  SpellCategory.banishing: 'Banimento',
  SpellCategory.luck: 'Sorte',
  SpellCategory.creativity: 'Criatividade',
  SpellCategory.communication: 'Comunicação',
  SpellCategory.dreams: 'Sonhos',
  SpellCategory.divination: 'Adivinhação',
  SpellCategory.energy: 'Energia',
  SpellCategory.wisdom: 'Sabedoria',
  SpellCategory.courage: 'Coragem',
  SpellCategory.friendship: 'Amizade',
  SpellCategory.home: 'Casa e Lar',
  SpellCategory.work: 'Trabalho',
  SpellCategory.study: 'Estudos',
  SpellCategory.other: 'Outros',
};

const Map<SpellCategory, String> _spellCategoryNamesEn = {
  SpellCategory.love: 'Love and Romance',
  SpellCategory.selfLove: 'Self-Love',
  SpellCategory.protection: 'Protection',
  SpellCategory.prosperity: 'Prosperity',
  SpellCategory.healing: 'Healing',
  SpellCategory.cleansing: 'Cleansing',
  SpellCategory.banishing: 'Banishing',
  SpellCategory.luck: 'Luck',
  SpellCategory.creativity: 'Creativity',
  SpellCategory.communication: 'Communication',
  SpellCategory.dreams: 'Dreams',
  SpellCategory.divination: 'Divination',
  SpellCategory.energy: 'Energy',
  SpellCategory.wisdom: 'Wisdom',
  SpellCategory.courage: 'Courage',
  SpellCategory.friendship: 'Friendship',
  SpellCategory.home: 'Home and Hearth',
  SpellCategory.work: 'Work',
  SpellCategory.study: 'Studies',
  SpellCategory.other: 'Other',
};

const Map<SpellCategory, String> _spellCategoryNamesEs = {
  SpellCategory.love: 'Amor y Romance',
  SpellCategory.selfLove: 'Amor Propio',
  SpellCategory.protection: 'Protección',
  SpellCategory.prosperity: 'Prosperidad',
  SpellCategory.healing: 'Sanación',
  SpellCategory.cleansing: 'Limpieza',
  SpellCategory.banishing: 'Destierro',
  SpellCategory.luck: 'Suerte',
  SpellCategory.creativity: 'Creatividad',
  SpellCategory.communication: 'Comunicación',
  SpellCategory.dreams: 'Sueños',
  SpellCategory.divination: 'Adivinación',
  SpellCategory.energy: 'Energía',
  SpellCategory.wisdom: 'Sabiduría',
  SpellCategory.courage: 'Coraje',
  SpellCategory.friendship: 'Amistad',
  SpellCategory.home: 'Casa y Hogar',
  SpellCategory.work: 'Trabajo',
  SpellCategory.study: 'Estudios',
  SpellCategory.other: 'Otros',
};
