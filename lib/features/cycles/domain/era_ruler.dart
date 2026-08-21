/// Regentes das Eras da vida, na ordem canônica do ciclo de 120 anos.
///
/// Os nomes do enum são identidade persistida (entram no cache em JSON) e por
/// isso NUNCA mudam com o idioma — o rótulo visível vem sempre do l10n. Na
/// interface dois deles têm nome próprio: `serpente` é "A Serpente" e `cauda`
/// é "A Cauda"; os termos técnicos originais ficam restritos a comentários.
enum EraRegente {
  cauda(7),
  venus(20),
  sol(6),
  lua(10),
  marte(7),
  serpente(18),
  jupiter(16),
  saturno(19),
  mercurio(17);

  const EraRegente(this.anos);

  /// Duração canônica da Era regida por este astro, em anos.
  final int anos;

  /// A ordem do ciclo é a própria ordem de declaração do enum, e ela é
  /// circular: depois de [mercurio] vem [cauda] de novo.
  ///
  /// Getter em vez de `static const` para não depender de `values` ser
  /// constante dentro da própria declaração do enum.
  static List<EraRegente> get ordem => EraRegente.values;

  /// Posição no ciclo (0..8).
  int get indice => index;

  /// O regente seguinte, dando a volta no fim.
  EraRegente get proximo => ordem[(index + 1) % ordem.length];

  /// O regente [passos] adiante, dando quantas voltas forem necessárias.
  EraRegente avancar(int passos) =>
      ordem[(index + passos) % ordem.length];

  static EraRegente porNome(String nome) =>
      ordem.firstWhere((r) => r.name == nome);
}

/// Soma das durações — 120 anos exatos. Exposto para o teste provar a
/// invariante em vez de repetir o número mágico.
final int kTotalAnosDoCiclo =
    EraRegente.ordem.fold(0, (soma, r) => soma + r.anos);
