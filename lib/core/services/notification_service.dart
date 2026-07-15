import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/wheel_of_year/data/models/sabbat_model.dart';

class NotificationScheduleResult {
  final bool permissionGranted;
  final int scheduledCount;
  final String? error;

  const NotificationScheduleResult({
    required this.permissionGranted,
    this.scheduledCount = 0,
    this.error,
  });

  bool get success => permissionGranted && error == null;
}

class NotificationService {
  static const int debugNotificationId = 990001;
  static const String debugNotificationTitle = '🔮 Mensagem do Grimório';
  static const String debugNotificationBody =
      'Seu Grimório está pronto para acompanhar sua jornada mágica.';

  final FlutterLocalNotificationsPlugin _notifications;

  NotificationService(this._notifications);

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _notifications
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            true;
      case TargetPlatform.iOS:
        return await _notifications
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return true;
    }
  }

  Future<void> createChannels() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'moon_notifications',
      'Fases da Lua',
      description: 'Notificações sobre fases lunares importantes',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'sabbat_notifications',
      'Sabbats',
      description: 'Lembretes de celebrações da Roda do Ano',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      'debug_notifications',
      'Testes de notificação',
      description: 'Notificações enviadas pelo diagnóstico do aplicativo',
      importance: Importance.high,
    ));
  }

  Future<NotificationScheduleResult> showDebugNotification() async {
    try {
      final granted = await requestPermissions();
      if (!granted) {
        return const NotificationScheduleResult(
          permissionGranted: false,
          error: 'Permissão de notificações não concedida',
        );
      }
      await createChannels();
      await _notifications.show(
        debugNotificationId,
        debugNotificationTitle,
        debugNotificationBody,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debug_notifications',
            'Testes de notificação',
            channelDescription:
                'Notificações enviadas pelo diagnóstico do aplicativo',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      return const NotificationScheduleResult(
        permissionGranted: true,
        scheduledCount: 1,
      );
    } catch (e) {
      return NotificationScheduleResult(
        permissionGranted: true,
        error: 'Falha ao enviar notificação de teste: $e',
      );
    }
  }

  @visibleForTesting
  static int notificationId(String type, DateTime eventDate) {
    final datePart =
        (eventDate.year * 10000) + (eventDate.month * 100) + eventDate.day;
    final prefix = switch (type) {
      'full_moon' => 10,
      'new_moon' => 20,
      _ => 30,
    };
    return (prefix * 10000000) + datePart;
  }

  @visibleForTesting
  static DateTime reminderDate(
    DateTime eventDate, {
    required int daysBefore,
    required int hour,
  }) {
    return DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day - daysBefore,
      hour,
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime localDate,
    required NotificationDetails details,
  }) async {
    if (!localDate.isAfter(DateTime.now())) return;
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(localDate.toUtc(), tz.UTC),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleFullMoonNotification(DateTime eventDate) => _schedule(
        id: notificationId('full_moon', eventDate),
        title: '🌕 Lua Cheia se aproxima!',
        body:
            'Amanhã é Lua Cheia! Prepare-se para rituais de manifestação e gratidão.',
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: const NotificationDetails(
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
      );

  Future<void> scheduleNewMoonNotification(DateTime eventDate) => _schedule(
        id: notificationId('new_moon', eventDate),
        title: '🌑 Lua Nova se aproxima!',
        body:
            'Amanhã é Lua Nova! Momento perfeito para definir intenções e novos começos.',
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: const NotificationDetails(
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
      );

  Future<void> scheduleSabbatNotification(Sabbat sabbat) => _schedule(
        id: notificationId('sabbat', sabbat.date),
        title: '${sabbat.emoji} ${sabbat.name} se aproxima!',
        body: 'Em 3 dias celebramos ${sabbat.name}. Prepare seus rituais!',
        localDate: reminderDate(sabbat.date, daysBefore: 3, hour: 9),
        details: const NotificationDetails(
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
      );

  Future<void> cancelAllNotifications() => _notifications.cancelAll();

  Future<List<PendingNotificationRequest>> pendingNotifications() =>
      _notifications.pendingNotificationRequests();

  Future<bool?> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return android.areNotificationsEnabled();
    return null;
  }

  Future<NotificationScheduleResult> scheduleNotifications({
    required List<DateTime> fullMoonDates,
    required List<DateTime> newMoonDates,
    required List<Sabbat> sabbats,
  }) async {
    try {
      final granted = await requestPermissions();
      if (!granted) {
        return const NotificationScheduleResult(
          permissionGranted: false,
          error: 'Permissão de notificações não concedida',
        );
      }
      await createChannels();
      await cancelAllNotifications();
      for (final date in fullMoonDates) {
        await scheduleFullMoonNotification(date);
      }
      for (final date in newMoonDates) {
        await scheduleNewMoonNotification(date);
      }
      for (final sabbat in sabbats) {
        await scheduleSabbatNotification(sabbat);
      }
      final pending = await _notifications.pendingNotificationRequests();
      return NotificationScheduleResult(
        permissionGranted: true,
        scheduledCount: pending.length,
      );
    } catch (e) {
      return NotificationScheduleResult(
        permissionGranted: true,
        error: 'Falha ao agendar notificações: $e',
      );
    }
  }
}
