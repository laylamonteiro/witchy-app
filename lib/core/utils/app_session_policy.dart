/// Política que diferencia uma retomada rápida de uma nova sessão do app.
class AppSessionPolicy {
  static const inactivityThreshold = Duration(minutes: 30);

  static bool shouldStartNewSession({
    required DateTime? backgroundedAt,
    required DateTime now,
  }) {
    if (backgroundedAt == null) return false;
    return now.difference(backgroundedAt) >= inactivityThreshold;
  }

  /// Folga entre duas sincronizações automáticas de retomada.
  static const folgaEntreAutoSyncs = Duration(minutes: 10);

  /// Vale sincronizar agora, na volta para o app?
  ///
  /// O carimbo é o da última TENTATIVA, não o do último sucesso. Contar só
  /// sucessos parece mais generoso e é o oposto: com a sincronização
  /// falhando (uma tabela que falta no servidor, a rede fora), o carimbo
  /// nunca avança e TODA volta para a aba refaz a varredura inteira — na
  /// web, com o SQLite em wasm na mesma thread da interface, isso é a tela
  /// congelando a cada troca de app (relato de 23/08).
  static bool deveAutoSincronizar({
    required DateTime? ultimaTentativa,
    required DateTime now,
  }) {
    if (ultimaTentativa == null) return true;
    return now.difference(ultimaTentativa) >= folgaEntreAutoSyncs;
  }
}
