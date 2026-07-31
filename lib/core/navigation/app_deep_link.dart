import 'package:flutter/foundation.dart';

/// Destinos internos do app alcançáveis por deep link (hoje, toques em
/// notificações; no futuro, links externos ou atalhos).
///
/// Para adicionar um destino novo:
/// 1. Crie um valor aqui com seu `payload` estável (é o que a notificação
///    agendada carrega — não renomeie payloads já emitidos);
/// 2. Informe a aba da HomePage e, se for o caso, a sub-aba da seção;
/// 3. Passe `payload` ao agendar a notificação no NotificationService.
/// A HomePage e as seções escutam o [DeepLinkService] e navegam sozinhas.
enum AppDeepLink {
  /// Enciclopédia Mágica → aba Lua (notificações de lua cheia/nova).
  moonEncyclopedia('encyclopedia/moon', encyclopediaTab: 0),

  /// Enciclopédia Mágica → aba Sabbats/Roda do Ano (notificações de sabbat).
  sabbatsEncyclopedia('encyclopedia/sabbats', encyclopediaTab: 1);

  const AppDeepLink(this.payload, {this.encyclopediaTab});

  /// Identificador estável usado como payload da notificação.
  final String payload;

  /// Sub-aba da Enciclopédia a abrir (null = não é um destino da Enciclopédia).
  final int? encyclopediaTab;

  /// Aba da bottom bar da HomePage (0 = Enciclopédia, 1 = Grimório,
  /// 2 = Diários). Hoje todos os destinos vivem na Enciclopédia.
  int get homeTab => 0;

  static AppDeepLink? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    for (final link in values) {
      if (link.payload == payload) return link;
    }
    return null;
  }
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
  final ValueNotifier<AppDeepLink?> pending = ValueNotifier(null);

  /// Despacha um payload (de notificação etc.). Payloads desconhecidos são
  /// ignorados em silêncio — notificações antigas nunca quebram o app.
  void dispatchPayload(String? payload) {
    final link = AppDeepLink.fromPayload(payload);
    if (link != null) pending.value = link;
  }

  /// Despacha um destino diretamente (ex.: reset de sessão → tela inicial).
  void dispatch(AppDeepLink link) => pending.value = link;

  /// Marca o link atual como tratado.
  void consume() => pending.value = null;
}
