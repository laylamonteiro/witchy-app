import '../../../core/i18n/gender.dart';

/// O que a pessoa pode ver e fazer no registro menstrual.
///
/// Duas perguntas, nesta ordem: a funcionalidade aparece para ela? e ela
/// consentiu?
///
/// **O consentimento continua explícito e destacado**, porque isto é dado de
/// saúde e a LGPD trata dado de saúde como dado pessoal sensível (art. 5º,
/// II), por consentimento específico para a finalidade. O que mudou foi a
/// cerimônia: eram DOIS sins — um para registrar, outro para acompanhar a
/// conta —, e virou UM só, dado na porta, que cobre os dois. Quem quiser
/// tirar o registro da conta depois desliga em Configurações → Privacidade,
/// e desligar lá já apaga a cópia que subiu.
///
/// **O Premium saiu desta área.** A roda do mês era paga e o calendário era a
/// alternativa gratuita; hoje as duas visões são de todo mundo, por decisão
/// da dona. Isto está escrito porque a regra antiga era categórica, e quem
/// lesse o texto sem ler a tela concluiria que falta um gate — e
/// "consertá-lo" voltaria a cobrar pelo que foi aberto de propósito. O card
/// "A Lua e você" já era gratuito pelo mesmo motivo: o que ela registrou é
/// dela, e olhar para isso não é um produto à parte.
class MenstrualAccess {
  const MenstrualAccess({
    required this.gender,
    required this.consented,
  });

  /// Como a pessoa pediu para ser tratada no app.
  final Gender gender;

  /// O sim explícito desta área — o único que existe.
  final bool consented;

  /// O cartão, o convite e qualquer oferta desta área existem apenas para
  /// quem se identifica no feminino ou no neutro.
  bool get isOffered =>
      gender == Gender.feminine || gender == Gender.neutral;

  /// Registrar e consultar os próprios dados, depois do consentimento.
  bool get canRecord => isOffered && consented;

  /// Levar embora ou apagar os próprios dados nunca depende do consentimento
  /// continuar de pé: quem já registrou precisa poder apagar depois de mudar
  /// de ideia. Isso acontece pelos gestos gerais de Privacidade — exportar,
  /// limpar este aparelho, excluir a conta —, que incluem o ciclo como
  /// incluem o resto.
  bool get canManageOwnData => isOffered;

  MenstrualAccess copyWith({Gender? gender, bool? consented}) =>
      MenstrualAccess(
        gender: gender ?? this.gender,
        consented: consented ?? this.consented,
      );
}
