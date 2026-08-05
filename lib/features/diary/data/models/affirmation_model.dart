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
  final String? userId;
  final String text;
  final AffirmationCategory category;
  final bool isPreloaded;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final bool isFavorite;

  AffirmationModel({
    String? id,
    this.userId,
    required this.text,
    required this.category,
    this.isPreloaded = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId ?? 'local_user',
      'text': text,
      'category': category.name,
      'is_preloaded': isPreloaded ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced': synced ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory AffirmationModel.fromMap(Map<String, dynamic> map) {
    return AffirmationModel(
      id: map['id'],
      userId: map['user_id'],
      text: map['text'],
      category: AffirmationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AffirmationCategory.manifestation,
      ),
      isPreloaded: map['is_preloaded'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
          : DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      synced: map['synced'] == 1,
      isFavorite: map['is_favorite'] == 1,
    );
  }

  AffirmationModel copyWith({
    String? userId,
    String? text,
    AffirmationCategory? category,
    bool? isFavorite,
    bool? synced,
  }) {
    return AffirmationModel(
      id: id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      category: category ?? this.category,
      isPreloaded: isPreloaded,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? false,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Versão da semeadura das afirmações. Subir este número faz o app
  /// substituir as pré-carregadas antigas na próxima abertura (as que a
  /// pessoa favoritou são preservadas).
  static const int seedVersion = 2;

  /// Afirmações pré-carregadas.
  ///
  /// Escritas para soarem verdadeiras na boca de quem lê: presente,
  /// concretas, com agência na própria pessoa e SEM flexão de gênero
  /// (nada de "protegido/protegida"). Evitam promessa absoluta — o que
  /// a mente rejeita, ela não repete.
  static List<AffirmationModel> getPreloadedAffirmations() {
    return [
      // Abundância
      AffirmationModel(
        text: 'Reconheço a abundância que já existe na minha vida',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cuido bem do que tenho, e o que tenho floresce',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Mereço prosperidade sem sentir culpa',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Meu trabalho abre caminhos, e eu sei receber o que chega',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Tenho o bastante para hoje, e hoje é o que existe',
        category: AffirmationCategory.abundance,
        isPreloaded: true,
      ),

      // Proteção
      AffirmationModel(
        text: 'Escolho onde ponho minha energia — isso já é proteção',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Meus limites são o meu círculo mágico',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Tenho o direito de dizer não sem me explicar',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O que não me pertence, eu devolvo',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Estou em segurança neste corpo, neste instante',
        category: AffirmationCategory.protection,
        isPreloaded: true,
      ),

      // Amor
      AffirmationModel(
        text: 'Meu afeto começa em mim e transborda daqui',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Mereço um amor que não me peça para diminuir',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Falo comigo com a doçura que ofereço a quem amo',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Meu coração se abre no meu tempo, não no tempo dos outros',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Aceito minha magia e minhas falhas no mesmo abraço',
        category: AffirmationCategory.love,
        isPreloaded: true,
      ),

      // Cura
      AffirmationModel(
        text: 'Meu corpo pede coisas simples, e eu escuto',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Descansar também é um ato de cura',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O que dói hoje não é tudo o que eu sou',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Devolvo à terra aquilo que já não me serve',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Sigo no meu ritmo, e meu ritmo basta',
        category: AffirmationCategory.healing,
        isPreloaded: true,
      ),

      // Poder Pessoal
      AffirmationModel(
        text: 'Conduzo a minha própria vida, mesmo devagar',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha vontade tem força, e eu a uso com cuidado',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Tenho poder sobre o que faço agora',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha voz merece ser ouvida, a começar por mim',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Escolho meus caminhos, inclusive os difíceis',
        category: AffirmationCategory.power,
        isPreloaded: true,
      ),

      // Sabedoria
      AffirmationModel(
        text: 'Minha intuição fala baixo, e eu aprendo a escutar',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Não preciso saber tudo para começar',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Cada erro me ensina o que o acerto não ensinaria',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Pergunto sem vergonha e aprendo sem pressa',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Carrego comigo o saber de quem veio antes de mim',
        category: AffirmationCategory.wisdom,
        isPreloaded: true,
      ),

      // Manifestação
      AffirmationModel(
        text: 'Digo com clareza o que quero — a clareza já é magia',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Dou o primeiro passo, e o caminho responde',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Minha intenção fica viva quando eu a pratico',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Escrevo meus desejos para não perdê-los de vista',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'O que planto hoje tem seu próprio tempo de brotar',
        category: AffirmationCategory.manifestation,
        isPreloaded: true,
      ),

      // Transformação
      AffirmationModel(
        text: 'Mudo como a lua muda: por fases, não de uma vez',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Posso recomeçar quantas vezes for preciso',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Deixo ir o que já cumpriu seu papel',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Não sou quem eu era ontem, e tudo bem',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
      AffirmationModel(
        text: 'Todo fim que atravessei me trouxe até aqui',
        category: AffirmationCategory.transformation,
        isPreloaded: true,
      ),
    ];
  }
}
