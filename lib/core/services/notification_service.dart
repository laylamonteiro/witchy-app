import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/wheel_of_year/data/models/sabbat_model.dart';
import '../navigation/app_deep_link.dart';
import '../../l10n/generated/app_localizations.dart';
import '../content/content_locale.dart';

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

  final FlutterLocalNotificationsPlugin _notifications;

  NotificationService(this._notifications);

  /// Textos resolvidos no idioma atual do app (via ContentLocale), sem
  /// depender de BuildContext — os textos são "assados" no agendamento,
  /// então reagendar após trocar o idioma re-emite tudo traduzido.
  AppLocalizations get _l10n =>
      lookupAppLocalizations(ContentLocale.instance.locale);

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
    final l10n = _l10n;
    await android.createNotificationChannel(AndroidNotificationChannel(
      'moon_notifications',
      l10n.notifChannelMoonName,
      description: l10n.notifChannelMoonDesc,
      importance: Importance.high,
    ));
    await android.createNotificationChannel(AndroidNotificationChannel(
      'sabbat_notifications',
      l10n.notifChannelSabbatName,
      description: l10n.notifChannelSabbatDesc,
      importance: Importance.high,
    ));
    await android.createNotificationChannel(AndroidNotificationChannel(
      'debug_notifications',
      l10n.notifChannelDebugName,
      description: l10n.notifChannelDebugDesc,
      importance: Importance.high,
    ));
  }

  /// [payload] permite testar o fluxo notificação → deep link de qualquer
  /// destino (ex.: `ritual/sabbat/imbolc`); default = aba Lua.
  Future<NotificationScheduleResult> showDebugNotification(
      {String? payload}) async {
    try {
      final granted = await requestPermissions();
      if (!granted) {
        return NotificationScheduleResult(
          permissionGranted: false,
          error: _l10n.notifErrPermissionDenied,
        );
      }
      await createChannels();
      await _notifications.show(
        debugNotificationId,
        _l10n.notifDebugTitle,
        _l10n.notifDebugBody,
        payload: payload ?? AppDeepLink.moonEncyclopedia.payload,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'debug_notifications',
            _l10n.notifChannelDebugName,
            channelDescription: _l10n.notifChannelDebugDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
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
        error: _l10n.notifErrTestFailed('$e'),
      );
    }
  }

  /// Id fixo da notificação semanal de água solar (agendamento recorrente,
  /// um único slot).
  static const int sunWaterNotificationId = 700001;
  static const int dailyReminderNotificationId = 800001;

  @visibleForTesting
  static int notificationId(String type, DateTime eventDate) {
    final datePart =
        (eventDate.year * 10000) + (eventDate.month * 100) + eventDate.day;
    final prefix = switch (type) {
      'full_moon' => 10,
      'new_moon' => 20,
      'full_moon_day' => 40,
      'new_moon_day' => 50,
      'sabbat_day' => 60,
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
    String? payload,
  }) async {
    if (!localDate.isAfter(DateTime.now())) return;
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(localDate.toUtc(), tz.UTC),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> scheduleFullMoonNotification(DateTime eventDate) => _schedule(
        id: notificationId('full_moon', eventDate),
        title: _l10n.notifFullMoonTitle,
        body: _l10n.notifFullMoonBody,
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: _moonDetails(),
        payload: AppDeepLink.moonEncyclopedia.payload,
      );

  Future<void> scheduleNewMoonNotification(DateTime eventDate) => _schedule(
        id: notificationId('new_moon', eventDate),
        title: _l10n.notifNewMoonTitle,
        body: _l10n.notifNewMoonBody,
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: _moonDetails(),
        payload: AppDeepLink.moonEncyclopedia.payload,
      );

  /// No dia da lua cheia, às 19h: convite para o ritual guiado + água de lua.
  Future<void> scheduleFullMoonDayNotification(DateTime eventDate) =>
      _schedule(
        id: notificationId('full_moon_day', eventDate),
        title: _l10n.notifFullMoonDayTitle,
        body: _l10n.notifFullMoonDayBody,
        localDate: reminderDate(eventDate, daysBefore: 0, hour: 19),
        details: _moonDetails(),
        payload: AppDeepLink.guidedRitualFullMoon.payload,
      );

  /// No dia da lua nova, às 19h: convite para plantar intenções.
  Future<void> scheduleNewMoonDayNotification(DateTime eventDate) => _schedule(
        id: notificationId('new_moon_day', eventDate),
        title: _l10n.notifNewMoonDayTitle,
        body: _l10n.notifNewMoonDayBody,
        localDate: reminderDate(eventDate, daysBefore: 0, hour: 19),
        details: _moonDetails(),
        payload: AppDeepLink.guidedRitualNewMoon.payload,
      );

  /// No dia do sabbat, às 9h: abre a página do ritual guiado do sabbat.
  Future<void> scheduleSabbatDayNotification(Sabbat sabbat) => _schedule(
        id: notificationId('sabbat_day', sabbat.date),
        title: _l10n.notifSabbatDayTitle(sabbat.emoji, sabbat.name),
        body: _l10n.notifSabbatDayBody(sabbat.name),
        localDate: reminderDate(sabbat.date, daysBefore: 0, hour: 9),
        payload:
            '${AppDeepLink.guidedRitualSabbat.payload}/${sabbat.type.name.toLowerCase()}',
        details: _sabbatDetails(),
      );

  /// Água solar: notificação semanal aos domingos (dia do Sol), 8h.
  /// Opt-in — só é agendada quando o toggle dedicado está ligado.
  Future<void> scheduleSunWaterNotification() async {
    final now = DateTime.now();
    // Próximo domingo às 8h (hoje mesmo, se ainda não passou).
    var next = DateTime(now.year, now.month, now.day, 8);
    while (next.weekday != DateTime.sunday || !next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    await _notifications.zonedSchedule(
      sunWaterNotificationId,
      _l10n.notifSunWaterTitle,
      _l10n.notifSunWaterBody,
      tz.TZDateTime.from(next.toUtc(), tz.UTC),
      _moonDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: AppDeepLink.guidedRitualSunWater.payload,
    );
  }

  /// Lembrete diário do Salem, no horário escolhido pela Bruxa.
  ///
  /// É a única notificação que não depende de evento astronômico: existe para
  /// sustentar o hábito (e a sequência de dias) nos dias comuns.
  Future<void> scheduleDailyReminder({required int hour, int minute = 0}) async {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _notifications.zonedSchedule(
      dailyReminderNotificationId,
      _l10n.notifDailyTitle,
      _l10n.notifDailyBody,
      tz.TZDateTime.from(next.toUtc(), tz.UTC),
      _moonDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Mesmo horário todo dia.
      matchDateTimeComponents: DateTimeComponents.time,
      payload: AppDeepLink.yourDay.payload,
    );
  }

  NotificationDetails _moonDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          'moon_notifications',
          _l10n.notifChannelMoonName,
          channelDescription: _l10n.notifChannelMoonDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      );

  Future<void> scheduleSabbatNotification(Sabbat sabbat) => _schedule(
        id: notificationId('sabbat', sabbat.date),
        title: _l10n.notifSabbatTitle(sabbat.emoji, sabbat.name),
        body: _l10n.notifSabbatBody(sabbat.name),
        localDate: reminderDate(sabbat.date, daysBefore: 3, hour: 9),
        payload: AppDeepLink.sabbatsEncyclopedia.payload,
        details: _sabbatDetails(),
      );

  NotificationDetails _sabbatDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          'sabbat_notifications',
          _l10n.notifChannelSabbatName,
          channelDescription: _l10n.notifChannelSabbatDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
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
    bool sunWater = false,
    bool dailyReminder = false,
    int dailyReminderHour = 9,
  }) async {
    try {
      final granted = await requestPermissions();
      if (!granted) {
        return NotificationScheduleResult(
          permissionGranted: false,
          error: _l10n.notifErrPermissionDenied,
        );
      }
      await createChannels();
      await cancelAllNotifications();
      for (final date in fullMoonDates) {
        await scheduleFullMoonNotification(date);
        await scheduleFullMoonDayNotification(date);
      }
      for (final date in newMoonDates) {
        await scheduleNewMoonNotification(date);
        await scheduleNewMoonDayNotification(date);
      }
      for (final sabbat in sabbats) {
        await scheduleSabbatNotification(sabbat);
        await scheduleSabbatDayNotification(sabbat);
      }
      if (sunWater) {
        await scheduleSunWaterNotification();
      }
      if (dailyReminder) {
        await scheduleDailyReminder(hour: dailyReminderHour);
      }
      final pending = await _notifications.pendingNotificationRequests();
      return NotificationScheduleResult(
        permissionGranted: true,
        scheduledCount: pending.length,
      );
    } catch (e) {
      return NotificationScheduleResult(
        permissionGranted: true,
        error: _l10n.notifErrScheduleFailed('$e'),
      );
    }
  }
}
