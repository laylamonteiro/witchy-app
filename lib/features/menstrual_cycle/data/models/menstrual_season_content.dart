import '../../domain/internal_season.dart';

/// Uma correspondência simbólica: a chave estável e o nome do verbete no
/// idioma do conteúdo.
///
/// A chave é o que a curadoria enxerga — ela é a mesma nos três idiomas, e é
/// por ela que a paridade é verificada. O rótulo é o nome do verbete como ele
/// existe no catálogo daquele idioma, e é por ele que a Enciclopédia resolve
/// o destino, preservando as telas e URLs que já existem.
class MenstrualCorrespondence {
  const MenstrualCorrespondence({required this.key, required this.label});

  final String key;
  final String label;
}

/// O conteúdo de uma Estação Interna, num idioma.
///
/// É convite, nunca previsão: aqui não se escreve "você estará irritada" nem
/// "sua confiança está no pico". As práticas são leves e opcionais, e nenhuma
/// delas trata dor, fluxo ou hormônio.
class MenstrualSeasonContent {
  const MenstrualSeasonContent({
    required this.season,
    required this.title,
    required this.invitation,
    required this.practices,
    required this.writingQuestion,
    required this.correspondences,
    this.editorialVersion = 1,
  });

  final InternalSeason season;
  final String title;
  final String invitation;
  final List<String> practices;
  final String writingQuestion;
  final List<MenstrualCorrespondence> correspondences;

  /// Versão editorial do texto. Muda quando a prosa muda, para que uma
  /// revisão futura saiba o que já foi lido.
  final int editorialVersion;
}
