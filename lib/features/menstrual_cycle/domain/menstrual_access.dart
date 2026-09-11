import '../../../core/i18n/gender.dart';

/// O que a pessoa pode ver e fazer no registro menstrual.
///
/// Três perguntas, nesta ordem: a funcionalidade aparece para ela? ela
/// consentiu em registrar? e o que ela vê é dado inserido ou derivado?
///
/// A regra que mais importa aqui é a última. Registrar, consultar, corrigir,
/// exportar e apagar são do plano gratuito. Dia do ciclo, duração, média,
/// intervalo, estimativa de próxima data e qualquer cruzamento com a Lua são
/// resultados calculados a partir do histórico — e esses são do Premium.
/// Não existe meio-termo: sem acesso, o resultado não é calculado para
/// depois ser escondido atrás de um borrão.
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

  /// As Estações Internas — escolher uma, ler o convite dela e escrever ali.
  /// Não é resultado calculado, é vocabulário simbólico; fica no Premium
  /// porque é conteúdo editorial, e continua sendo escolha explícita dela.
  bool get canChooseSeason => canRecord && premium;

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
