import '../../domain/era_ruler.dart';

/// Texto de uma Era — o período longo, de 6 a 20 anos.
///
/// Três blocos porque a leitura é paginada: cada um vira uma tela que desliza.
class EraContent {
  const EraContent({
    required this.regente,
    required this.titulo,
    required this.tags,
    required this.corpo,
    required this.sombra,
    required this.convite,
  });

  final EraRegente regente;

  /// Título da Era, no tom do Grimório ("Tempo de colher e multiplicar").
  final String titulo;

  /// Três palavras-chave, exibidas como etiquetas no card.
  final List<String> tags;

  /// Página 1: o que este tempo traz.
  final String corpo;

  /// Página 2: onde ele costuma doer.
  final String sombra;

  /// Página 3: o que fazer com ele.
  final String convite;
}

/// Texto de uma Fase — o subperíodo dentro de uma Era.
///
/// Curto de propósito: a leitura da Fase é composta em tempo de execução como
/// Era + este tempero. Nove Eras × nove Fases dariam 81 combinações escritas à
/// mão, e isso não se paga.
class FaseContent {
  const FaseContent({
    required this.regente,
    required this.titulo,
    required this.tags,
    required this.sabor,
  });

  final EraRegente regente;

  /// Título da Fase, mais imediato que o da Era ("Foque em se sentir bem")
  final String titulo;

  final List<String> tags;

  /// O tempero que a Fase dá à Era em curso.
  final String sabor;
}
