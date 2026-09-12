import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instalação nova = todos os avisos já nascem ligados. Quem achar demais
/// desliga no painel, e essa escolha nunca pode ser sobrescrita pelo padrão.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<NotificationProvider> comPrefs(Map<String, Object> valores) async {
    SharedPreferences.setMockInitialValues(valores);
    final prefs = await SharedPreferences.getInstance();
    return NotificationProvider(FlutterLocalNotificationsPlugin(), prefs);
  }

  test('sem nada gravado, os cinco avisos vêm ligados', () async {
    final provider = await comPrefs({});

    expect(provider.fullMoonNotifications, isTrue);
    expect(provider.newMoonNotifications, isTrue);
    expect(provider.sabbatNotifications, isTrue);
    expect(provider.sunWaterNotifications, isTrue);
    expect(provider.dailyReminder, isTrue);
    expect(provider.dailyReminderHour, 9);
  });

  test('o que ela desligou continua desligado', () async {
    final provider = await comPrefs({
      'fullMoonNotifications': false,
      'newMoonNotifications': false,
      'sabbatNotifications': false,
      'sunWaterNotifications': false,
      'dailyReminder': false,
      'dailyReminderHour': 21,
    });

    expect(provider.fullMoonNotifications, isFalse);
    expect(provider.newMoonNotifications, isFalse);
    expect(provider.sabbatNotifications, isFalse);
    expect(provider.sunWaterNotifications, isFalse);
    expect(provider.dailyReminder, isFalse);
    expect(provider.dailyReminderHour, 21);
  });
}
