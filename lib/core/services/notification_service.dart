import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/lunar/data/models/moon_phase.dart';
import '../../features/wheel_of_year/data/models/sabbat_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  NotificationService(this._notifications);

  /// Agendar notificação para Lua Cheia (1 dia antes)
  Future<void> scheduleFullMoonNotification(DateTime fullMoonDate) async {
    final scheduledDate = fullMoonDate.subtract(const Duration(days: 1));

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      1, // ID único para lua cheia
      '🌕 Lua Cheia se aproxima!',
      'Amanhã é Lua Cheia! Prepare-se para rituais de manifestação e gratidão.',
      tz.TZDateTime.from(scheduledDate, tz.local).add(const Duration(hours: 20)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'moon_notifications',
          'Fases da Lua',
          channelDescription: 'Notificações sobre fases lunares importantes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Agendar notificação para Lua Nova (1 dia antes)
  Future<void> scheduleNewMoonNotification(DateTime newMoonDate) async {
    final scheduledDate = newMoonDate.subtract(const Duration(days: 1));

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      2, // ID único para lua nova
      '🌑 Lua Nova se aproxima!',
      'Amanhã é Lua Nova! Momento perfeito para definir intenções e novos começos.',
      tz.TZDateTime.from(scheduledDate, tz.local).add(const Duration(hours: 20)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'moon_notifications',
          'Fases da Lua',
          channelDescription: 'Notificações sobre fases lunares importantes',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Agendar notificação para Sabbat (3 dias antes)
  Future<void> scheduleSabbatNotification(Sabbat sabbat) async {
    final scheduledDate = sabbat.date.subtract(const Duration(days: 3));

    if (scheduledDate.isBefore(DateTime.now())) return;

    // ID baseado no hash do nome do sabbat para evitar duplicatas
    final id = sabbat.name.hashCode % 10000 + 100; // IDs 100+

    await _notifications.zonedSchedule(
      id,
      '${sabbat.emoji} ${sabbat.name} se aproxima!',
      'Em 3 dias celebramos ${sabbat.name}. Prepare seus rituais!',
      tz.TZDateTime.from(scheduledDate, tz.local).add(const Duration(hours: 9)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sabbat_notifications',
          'Sabbats',
          channelDescription: 'Lembretes de celebrações da Roda do Ano',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancelar notificação específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Agendar todas as notificações do mês
  Future<void> scheduleMonthlyNotifications({
    required List<DateTime> fullMoonDates,
    required List<DateTime> newMoonDates,
    required List<Sabbat> sabbats,
  }) async {
    // Cancelar notificações antigas primeiro
    await cancelAllNotifications();

    // Agendar notificações de Luas
    for (final date in fullMoonDates) {
      await scheduleFullMoonNotification(date);
    }
    for (final date in newMoonDates) {
      await scheduleNewMoonNotification(date);
    }

    // Agendar notificações de Sabbats
    for (final sabbat in sabbats) {
      await scheduleSabbatNotification(sabbat);
    }
  }
}
