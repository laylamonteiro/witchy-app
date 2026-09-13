import 'package:shared_preferences/shared_preferences.dart';

/// O consentimento do registro menstrual, por conta e neste aparelho.
///
/// Isto é dado de saúde, e por isso o sim é explícito e destacado — a LGPD
/// trata dado de saúde como dado pessoal sensível (art. 5º, II), por
/// consentimento específico para a finalidade. O aceite dos termos, no
/// cadastro, não substitui este.
///
/// O que mudou foi a CERIMÔNIA. Eram dois sins — um para registrar, outro
/// para a cópia na conta —, e a pessoa tinha de dar os dois, em telas
/// diferentes, para o registro funcionar inteiro. Agora é [accept]: um gesto
/// só, na porta, que liga os dois. Continuam sendo duas chaves aqui dentro
/// porque ela pode tirar só a cópia da nuvem depois ([setSyncAllowed], em
/// Configurações → Privacidade) sem perder o que já escreveu.
///
/// Recusar não apaga nada — só fecha a porta da entrada.
class MenstrualConsentStore {
  const MenstrualConsentStore();

  static const _recordPrefix = 'menstrual_consent_record_';
  static const _syncPrefix = 'menstrual_consent_sync_';

  /// A referência de próxima data saiu da tela junto com o que se calculava
  /// do histórico, e ninguém mais lê nem grava esta preferência. A chave
  /// continua aqui só para o [forget] apagar o sim antigo de quem chegou a
  /// ligá-la: deixar dado esquecido no aparelho seria guardar sem motivo.
  static const _nextReferencePrefix = 'menstrual_next_reference_';
  static const _revisionPrefix = 'menstrual_consent_revision_';

  Future<bool> recordingAllowed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_recordPrefix$userId') ?? false;
  }

  /// O SIM, num gesto só: registrar e deixar o registro acompanhar a conta.
  ///
  /// É o que o botão da porta chama. Antes ele ligava só o registro e a
  /// pessoa precisava caçar um segundo interruptor para a cópia na conta —
  /// que era a parte que ninguém achava, e o motivo de o registro ficar preso
  /// num aparelho só sem ela ter escolhido isso.
  ///
  /// O texto que ela lê antes de tocar diz as duas coisas, e diz onde
  /// desligar. Um sim que a pessoa não entendeu não é consentimento; um sim
  /// espalhado em duas telas também não.
  Future<void> accept(String userId) async {
    await setRecordingAllowed(userId, true);
    await setSyncAllowed(userId, true);
  }

  Future<void> setRecordingAllowed(String userId, bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    final before = prefs.getBool('$_recordPrefix$userId') ?? false;
    await prefs.setBool('$_recordPrefix$userId', allowed);
    // Deixar de consentir com o registro também fecha o envio: o contrário
    // seria continuar mandando para a nuvem o que ela pediu para parar.
    if (!allowed) await prefs.setBool('$_syncPrefix$userId', false);
    // Dizer sim de novo, depois de ter dito não, é OUTRO consentimento: a
    // revisão sobe, e toda autorização presa à revisão anterior deixa de
    // valer sozinha.
    if (allowed && !before) {
      await prefs.setInt(
          '$_revisionPrefix$userId', await consentRevision(userId) + 1);
    }
  }

  /// Quantas vezes ela disse sim ao registro nesta conta. Entra no contrato
  /// de uma análise autorizada: retirar e dar o sim de novo invalida o que
  /// tinha sido autorizado antes.
  Future<int> consentRevision(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_revisionPrefix$userId') ?? 0;
  }

  /// O envio para a conta na nuvem. Desligado até haver um sim explícito, e
  /// só faz sentido junto com o consentimento de registro.
  Future<bool> syncAllowed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('$_syncPrefix$userId') ?? false) &&
        (prefs.getBool('$_recordPrefix$userId') ?? false);
  }

  Future<void> setSyncAllowed(String userId, bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_syncPrefix$userId', allowed);
  }

  /// Esquece as respostas desta conta — usado quando a pessoa apaga tudo.
  Future<void> forget(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_recordPrefix$userId');
    await prefs.remove('$_syncPrefix$userId');
    await prefs.remove('$_nextReferencePrefix$userId');
    await prefs.remove('$_revisionPrefix$userId');
  }
}
