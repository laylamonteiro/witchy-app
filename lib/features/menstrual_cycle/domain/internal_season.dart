/// As quatro Estações Internas.
///
/// São vocabulário simbólico, escolhido pela pessoa — nunca deduzido. O app
/// não infere estação a partir de datas, fluxo, humor ou média, e "nenhuma"
/// é uma resposta inteira. Nenhuma estação vale mais que outra, e escolher
/// uma não afirma nada sobre hormônios, ovulação ou fase do corpo.
enum InternalSeason {
  winter,
  spring,
  summer,
  autumn;

  /// A estação pelo nome guardado, ou nenhuma: um nome desconhecido não pode
  /// virar uma escolha que a pessoa não fez.
  static InternalSeason? named(String? name) {
    if (name == null) return null;
    for (final season in values) {
      if (season.name == name) return season;
    }
    return null;
  }
}
