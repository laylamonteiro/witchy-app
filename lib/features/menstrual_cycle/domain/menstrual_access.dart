import '../../../core/i18n/gender.dart';

/// O que a pessoa pode ver e fazer no registro menstrual.
///
/// Três perguntas, nesta ordem: a funcionalidade aparece para ela? ela
/// consentiu em registrar? e o que ela vê é dado inserido ou derivado?
///
/// A regra que mais importa aqui é a última. Registrar, consultar, corrigir,
/// exportar e apagar são do plano gratuito. Dia do ciclo, duração, média,
/// intervalo e estimativa de próxima data são resultados calculados a partir
/// do histórico — e esses são do Premium. Quando o cálculo é do Premium não
/// existe meio-termo: sem acesso, o resultado não é calculado para depois ser
/// escondido atrás de um borrão.
///
/// O cruzamento com a Lua mudou de lado e voltou a ser gratuito: o card "A Lua
/// e você" (a comparação dos começos com a Nova e a Cheia, e a contagem das
/// emoções mais anotadas) é montado sem gate na página do Ciclo Menstrual,
/// ACIMA do alternador Calendário/Roda — ou seja, à vista de quem nunca chega
/// à roda —, por decisão da dona. Isto está escrito porque a regra antiga era
/// categórica, e quem lesse o texto sem ler a tela concluiria que o card
/// gratuito é um gate esquecido — e "consertá-lo" tiraria de graça o que foi
/// aberto de propósito. [canSeeDerived] hoje cobre o alternador
/// Calendário/Roda e a roda do mês.
class MenstrualAccess {
  const MenstrualAccess({
    required this.gender,
    required this.consented,
    required this.premium,
  });

  /// Como a pessoa pediu para ser tratada no app.
  final Gender gender;

  /// Consentimento específico para manter o registro neste aparelho.
  final bool consented;

  /// `AuthProvider.isPremiumEffective`: assinatura, código ou vitalício.
  final bool premium;

  /// O cartão, o convite e qualquer oferta desta área existem apenas para
  /// quem se identifica no feminino ou no neutro.
  bool get isOffered =>
      gender == Gender.feminine || gender == Gender.neutral;

  /// Registrar e consultar os próprios dados: do plano gratuito, depois do
  /// consentimento.
  bool get canRecord => isOffered && consented;

  /// Levar embora ou apagar os próprios dados nunca depende de assinatura —
  /// nem de o consentimento continuar de pé, porque quem já registrou
  /// precisa poder apagar depois de mudar de ideia.
  bool get canManageOwnData => isOffered;

  /// Resultados calculados a partir do histórico.
  bool get canSeeDerived => canRecord && premium;

  /// Um convite genérico para conhecer o Premium é aceitável; usar sintomas,
  /// datas ou a ausência de registro para oferecer nunca é.
  bool get showsGenericPremiumInvite => canRecord && !premium;

  MenstrualAccess copyWith({Gender? gender, bool? consented, bool? premium}) =>
      MenstrualAccess(
        gender: gender ?? this.gender,
        consented: consented ?? this.consented,
        premium: premium ?? this.premium,
      );
}
