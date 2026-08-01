import 'package:flutter/foundation.dart';

import 'encyclopedia_section.dart';

/// Destinos internos do app alcançáveis por deep link (hoje, toques em
/// notificações; no futuro, links externos ou atalhos).
///
/// Para adicionar um destino novo:
/// 1. Crie um valor aqui com seu `payload` estável (é o que a notificação
///    agendada carrega — não renomeie payloads já emitidos);
/// 2. Informe a aba da HomePage e, se for o caso, a sub-aba da seção;
/// 3. Passe `payload` ao agendar a notificação no NotificationService.
///    Destinos com argumento emitem `'<payload>/<arg>'` (ex.:
///    `ritual/sabbat/imbolc`) e o argumento chega em [PendingDeepLink.arg].
/// A HomePage e as seções escutam o [DeepLinkService] e navegam sozinhas.
enum AppDeepLink {
  /// Aba "Seu Dia" da bottom bar (hub diário).
  yourDay('today'),

  /// Enciclopédia Mágica → seção Lua (notificações de lua cheia/nova).
  moonEncyclopedia('encyclopedia/moon',
      homeTab: 1, encyclopediaSection: EncyclopediaSection.moon),

  /// Enciclopédia Mágica → seção Sol.
  sunEncyclopedia('encyclopedia/sun',
      homeTab: 1, encyclopediaSection: EncyclopediaSection.sun),

  /// Enciclopédia Mágica → seção Sabbats/Roda do Ano (notificações de sabbat).
  sabbatsEncyclopedia('encyclopedia/sabbats',
      homeTab: 1, encyclopediaSection: EncyclopediaSection.sabbats),

  /// Página guiada do ritual de um sabbat (payload emitido:
  /// `ritual/sabbat/<SabbatType.name>`, ex. `ritual/sabbat/imbolc`).
  guidedRitualSabbat('ritual/sabbat',
      homeTab: 1, encyclopediaSection: EncyclopediaSection.sabbats),

  /// Página guiada do ritual de lua cheia.
  guidedRitualFullMoon('ritual/full_moon',
      homeTab: 1,
      encyclopediaSection: EncyclopediaSection.moon,
      ritualId: 'full_moon'),

  /// Página guiada do ritual de lua nova.
  guidedRitualNewMoon('ritual/new_moon',
      homeTab: 1,
      encyclopediaSection: EncyclopediaSection.moon,
      ritualId: 'new_moon'),

  /// Página guiada da água solar (notificação semanal opt-in) — abre sobre
  /// a seção Sol.
  guidedRitualSunWater('ritual/sun_water',
      homeTab: 1,
      encyclopediaSection: EncyclopediaSection.sun,
      ritualId: 'sun_water'),

  /// Diários → aba Sonhos (diário onírico).
  dreamsDiary('diary/dreams', homeTab: 3, diaryTab: 3);

  const AppDeepLink(this.payload,
      {this.homeTab = 0,
      this.encyclopediaSection,
      this.diaryTab,
      this.ritualId});

  /// Identificador estável usado como payload da notificação.
  final String payload;

  /// Aba da bottom bar da HomePage (0 = Seu Dia, 1 = Enciclopédia,
  /// 2 = Grimório, 3 = Diários).
  final int homeTab;

  /// Seção da Enciclopédia a abrir (null = não é um destino da Enciclopédia).
  /// A aba correspondente é derivada da ordem canônica do enum — reordenar
  /// as seções nunca quebra um deep link.
  final EncyclopediaSection? encyclopediaSection;

  /// Índice da sub-aba da Enciclopédia derivado de [encyclopediaSection].
  int? get encyclopediaTab => encyclopediaSection?.index;

  /// Sub-aba dos Diários a abrir (null = não é um destino dos Diários).
  final int? diaryTab;

  /// Ritual guiado fixo deste destino (null = sem ritual, ou o ritual vem do
  /// argumento do payload, como nos sabbats).
  final String? ritualId;

  /// É um destino de página guiada de ritual?
  bool get isGuidedRitual =>
      ritualId != null || this == AppDeepLink.guidedRitualSabbat;

  static AppDeepLink? fromPayload(String? payload) =>
      PendingDeepLink.parse(payload)?.link;
}

/// Um deep link pendente: o destino + argumento opcional do payload
/// (ex.: `ritual/sabbat/imbolc` → link=guidedRitualSabbat, arg='imbolc').
@immutable
class PendingDeepLink {
  final AppDeepLink link;
  final String? arg;

  const PendingDeepLink(this.link, {this.arg});

  /// Resolve um payload em destino + argumento. Payloads desconhecidos
  /// retornam null (notificações antigas nunca quebram o app).
  static PendingDeepLink? parse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    for (final link in AppDeepLink.values) {
      if (link.payload == payload) return PendingDeepLink(link);
    }
    // Match por prefixo para payloads com argumento.
    for (final link in AppDeepLink.values) {
      final prefix = '${link.payload}/';
      if (payload.startsWith(prefix) && payload.length > prefix.length) {
        return PendingDeepLink(link, arg: payload.substring(prefix.length));
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is PendingDeepLink && other.link == link && other.arg == arg;

  @override
  int get hashCode => Object.hash(link, arg);
}

/// Canal único de deep links: quem recebe o evento (toque em notificação,
/// retomada de sessão) despacha aqui; HomePage e seções escutam [pending]
/// e navegam. O último ouvinte da cadeia chama [consume].
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  /// Link aguardando navegação (null = nada pendente). Sobrevive ao caso de
  /// app aberto pela notificação: o dispatch acontece antes do runApp e a
  /// HomePage/seção leem o valor inicial ao montar.
  final ValueNotifier<PendingDeepLink?> pending = ValueNotifier(null);

  /// Despacha um payload (de notificação etc.). Payloads desconhecidos são
  /// ignorados em silêncio — notificações antigas nunca quebram o app.
  void dispatchPayload(String? payload) {
    final parsed = PendingDeepLink.parse(payload);
    if (parsed != null) pending.value = parsed;
  }

  /// Despacha um destino diretamente (ex.: reset de sessão → tela inicial).
  void dispatch(AppDeepLink link) => pending.value = PendingDeepLink(link);

  /// Marca o link atual como tratado.
  void consume() => pending.value = null;
}
