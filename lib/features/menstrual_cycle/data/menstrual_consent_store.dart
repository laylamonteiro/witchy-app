import 'package:shared_preferences/shared_preferences.dart';

/// O consentimento do registro menstrual, por conta e neste aparelho.
///
/// São dois, separados de propósito: manter o registro no aparelho é um; e
/// sincronizá-lo com a conta na nuvem é outro, que continua desligado até a
/// pessoa dizer que sim. Recusar não apaga nada — só fecha a porta da
/// entrada; apagar é uma ação à parte, e continua disponível.
class MenstrualConsentStore {
  const MenstrualConsentStore();

  static const _recordPrefix = 'menstrual_consent_record_';
  static const _syncPrefix = 'menstrual_consent_sync_';
  static const _nextReferencePrefix = 'menstrual_next_reference_';
  static const _revisionPrefix = 'menstrual_consent_revision_';

  Future<bool> recordingAllowed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_recordPrefix$userId') ?? false;
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

  /// A referência de próxima data é opcional dentro do Premium: alguém pode
  /// querer registrar e ver médias sem uma data pairando na tela.
  Future<bool> nextReferenceWanted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_nextReferencePrefix$userId') ?? false;
  }

  Future<void> setNextReferenceWanted(String userId, bool wanted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_nextReferencePrefix$userId', wanted);
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
