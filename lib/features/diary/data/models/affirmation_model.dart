import 'package:uuid/uuid.dart';

enum AffirmationCategory {
  abundance,
  protection,
  love,
  healing,
  power,
  wisdom,
  manifestation,
  transformation,
}

extension AffirmationCategoryExtension on AffirmationCategory {
  String get displayName {
    switch (this) {
      case AffirmationCategory.abundance:
        return 'Abundância';
      case AffirmationCategory.protection:
        return 'Proteção';
      case AffirmationCategory.love:
        return 'Amor';
      case AffirmationCategory.healing:
        return 'Cura';
      case AffirmationCategory.power:
        return 'Poder Pessoal';
      case AffirmationCategory.wisdom:
        return 'Sabedoria';
      case AffirmationCategory.manifestation:
        return 'Manifestação';
      case AffirmationCategory.transformation:
        return 'Transformação';
    }
  }

  String get icon {
    switch (this) {
      case AffirmationCategory.abundance:
        return '✨';
      case AffirmationCategory.protection:
        return '🛡️';
      case AffirmationCategory.love:
        return '💖';
      case AffirmationCategory.healing:
        return '🌿';
      case AffirmationCategory.power:
        return '🔥';
      case AffirmationCategory.wisdom:
        return '🦉';
      case AffirmationCategory.manifestation:
        return '🌙';
      case AffirmationCategory.transformation:
        return '🦋';
    }
  }
}

class AffirmationModel {
  final String id;
  final String text;
  final AffirmationCategory category;
  final bool isPreloaded;
  final DateTime createdAt;
  final bool isFavorite;

  AffirmationModel({
    String? id,
    required this.text,
    required this.category,
    this.isPreloaded = false,
    DateTime? createdAt,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category.name,
      'is_preloaded': isPreloaded ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory AffirmationModel.fromMap(Map<String, dynamic> map) {
    return AffirmationModel(
      id: map['id'],
      text: map['text'],
      category: AffirmationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AffirmationCategory.manifestation,
      ),
      isPreloaded: map['is_preloaded'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isFavorite: map['is_favorite'] == 1,
    );
  }

  AffirmationModel copyWith({
    String? text,
    AffirmationCategory? category,
    bool? isFavorite,
  }) {
    return AffirmationModel(
      id: id,
      text: text ?? this.text,
      category: category ?? this.category,
      isPreloaded: isPreloaded,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Afirmações pré-carregadas
  static List<AffirmationModel> getPreloadedAffirmations() {
    return [
      // Abundância
      AffirmationModel(
        text: 'Sou um ímã para a prosperidade e abundância em todas as formas',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O universo conspira a meu favor, trazendo riqueza e oportunidades',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha energia atrai recursos infinitos e bênçãos constantes',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Recebo com gratidão as dádivas do universo em forma de ouro e luz',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),

      // Proteção
      AffirmationModel(
        text: 'Estou protegido por uma luz branca divina que afasta toda negatividade',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha aura é um escudo impenetrável de energia sagrada',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Anjos e espíritos guardiões caminham ao meu lado sempre',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou envolvido por um círculo mágico de proteção e segurança',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),

      // Amor
      AffirmationModel(
        text: 'Meu coração irradia amor incondicional para mim e para o mundo',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou digno de amor puro, verdadeiro e mágico',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O amor flui através de mim como um rio de luz cristalina',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Atraio relacionamentos que nutrem minha alma e elevam meu espírito',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Me amo completamente, com toda minha magia e imperfeições',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),

      // Cura
      AffirmationModel(
        text: 'Meu corpo é um templo sagrado de cura e regeneração',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cada célula do meu ser vibra em harmonia e saúde perfeita',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'A energia curativa do universo flui através de mim',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Liberto traumas do passado e abraço a cura do presente',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou curado pelas forças místicas da natureza e do cosmos',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),

      // Poder Pessoal
      AffirmationModel(
        text: 'Possuo poder ilimitado para criar minha realidade',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou a bruxa/bruxo da minha própria vida, moldando meu destino',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha vontade é forte como fogo, meu poder é inesgotável',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Comando minha energia com confiança e propósito',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou soberano do meu reino interior e exterior',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),

      // Sabedoria
      AffirmationModel(
        text: 'A sabedoria ancestral flui através das minhas veias',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Confio na minha intuição, ela é minha bússola mágica',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Tenho acesso à biblioteca infinita do conhecimento universal',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cada experiência me traz lições valiosas e crescimento espiritual',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou guiado pela luz da sabedoria divina em cada decisão',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),

      // Manifestação
      AffirmationModel(
        text: 'Meus pensamentos se tornam realidade com facilidade mágica',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Manifesto meus sonhos sob a luz da lua cheia',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou cocriador do universo, moldando minha vida com intenção',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cada palavra que falo é um feitiço de manifestação',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O poder de manifestação corre em meu sangue místico',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),

      // Transformação
      AffirmationModel(
        text: 'Transformo-me como a lua, ciclicamente renovado e poderoso',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Abraço mudanças como portais para novas dimensões do meu ser',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sou fênix renascida das cinzas da minha antiga versão',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cada final é um novo começo mágico em minha jornada',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Metamorfoseio-me em versões cada vez mais elevadas de mim',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
    ];
  }
}
