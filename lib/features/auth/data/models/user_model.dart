/// Roles de usuário no sistema
enum UserRole {
  /// Usuário gratuito - acesso limitado
  free,

  /// Usuário premium - acesso completo exceto diagnóstico
  premium,

  /// Administrador - acesso total
  admin,
}

/// Planos de assinatura
enum SubscriptionPlan {
  /// Plano gratuito
  free,

  /// Assinatura mensal
  monthly,

  /// Assinatura anual
  yearly,

  /// Acesso vitalício
  lifetime,
}

/// Modelo de usuário do aplicativo
class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthPlace;
  final UserRole role;
  final SubscriptionPlan plan;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic>? settings;

  /// Contadores de uso para limites do plano free
  final int spellsCount;
  final int diaryEntriesThisMonth;
  final int aiConsultationsToday;
  final DateTime? lastAiConsultationReset;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    required this.role,
    required this.plan,
    required this.createdAt,
    required this.lastLoginAt,
    this.settings,
    this.spellsCount = 0,
    this.diaryEntriesThisMonth = 0,
    this.aiConsultationsToday = 0,
    this.lastAiConsultationReset,
  });

  /// Usuário padrão (local, sem autenticação)
  factory UserModel.defaultUser() {
    return UserModel(
      id: 'local_user',
      role: UserRole.free,
      plan: SubscriptionPlan.free,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Usuário admin para desenvolvimento/teste
  factory UserModel.admin() {
    return UserModel(
      id: 'admin_user',
      email: 'admin@grimorio.app',
      displayName: 'Administrador',
      role: UserRole.admin,
      plan: SubscriptionPlan.lifetime,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Verifica se é admin
  bool get isAdmin => role == UserRole.admin;

  /// Verifica se é premium (inclui admin)
  bool get isPremium => role == UserRole.premium || role == UserRole.admin;

  /// Verifica se é usuário free
  bool get isFree => role == UserRole.free;

  /// Limite de feitiços para plano free
  static const int freeSpellsLimit = 10;

  /// Limite de entradas de diário por mês para plano free
  static const int freeDiaryEntriesLimit = 30;

  /// Limite de consultas IA por dia para plano free
  static const int freeAiConsultationsLimit = 3;

  /// Verifica se pode criar mais feitiços
  bool get canCreateSpell => isPremium || spellsCount < freeSpellsLimit;

  /// Verifica se pode criar mais entradas no diário
  bool get canCreateDiaryEntry => isPremium || diaryEntriesThisMonth < freeDiaryEntriesLimit;

  /// Verifica se pode usar IA hoje
  bool get canUseAi => isPremium || aiConsultationsToday < freeAiConsultationsLimit;

  /// Quantas consultas IA restam hoje
  int get remainingAiConsultations {
    if (isPremium) return -1; // ilimitado
    return freeAiConsultationsLimit - aiConsultationsToday;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
    String? birthTime,
    String? birthPlace,
    UserRole? role,
    SubscriptionPlan? plan,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
    int? spellsCount,
    int? diaryEntriesThisMonth,
    int? aiConsultationsToday,
    DateTime? lastAiConsultationReset,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
      spellsCount: spellsCount ?? this.spellsCount,
      diaryEntriesThisMonth: diaryEntriesThisMonth ?? this.diaryEntriesThisMonth,
      aiConsultationsToday: aiConsultationsToday ?? this.aiConsultationsToday,
      lastAiConsultationReset: lastAiConsultationReset ?? this.lastAiConsultationReset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'role': role.name,
      'plan': plan.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'settings': settings,
      'spellsCount': spellsCount,
      'diaryEntriesThisMonth': diaryEntriesThisMonth,
      'aiConsultationsToday': aiConsultationsToday,
      'lastAiConsultationReset': lastAiConsultationReset?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 'local_user',
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      birthTime: json['birthTime'],
      birthPlace: json['birthPlace'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.free,
      ),
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : DateTime.now(),
      settings: json['settings'],
      spellsCount: json['spellsCount'] ?? 0,
      diaryEntriesThisMonth: json['diaryEntriesThisMonth'] ?? 0,
      aiConsultationsToday: json['aiConsultationsToday'] ?? 0,
      lastAiConsultationReset: json['lastAiConsultationReset'] != null
          ? DateTime.parse(json['lastAiConsultationReset'])
          : null,
    );
  }
}
