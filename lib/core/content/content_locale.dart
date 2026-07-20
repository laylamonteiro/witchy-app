import 'dart:ui' show Locale;

/// Locale atual da camada de conteúdo estático (cartas, runas, enciclopédia,
/// trilhas etc.), espelhando o padrão de `AIService.setLocale`.
///
/// Mantido fora da árvore de widgets para que repositórios, serviços e
/// agendamento de notificações resolvam conteúdo sem `BuildContext`.
/// É atualizado exclusivamente pelo `LanguageProvider`.
class ContentLocale {
  ContentLocale._();

  static final ContentLocale instance = ContentLocale._();

  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
  }

  /// Seleciona a variante de conteúdo do idioma atual (fallback: português).
  T select<T>({required T pt, required T en, required T es}) {
    switch (_locale.languageCode) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return pt;
    }
  }
}
