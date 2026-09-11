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

  Future<bool> recordingAllowed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_recordPrefix$userId') ?? false;
  }

  Future<void> setRecordingAllowed(String userId, bool allowed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_recordPrefix$userId', allowed);
    // Deixar de consentir com o registro também fecha o envio: o contrário
    // seria continuar mandando para a nuvem o que ela pediu para parar.
    if (!allowed) await prefs.setBool('$_syncPrefix$userId', false);
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
  }
}
