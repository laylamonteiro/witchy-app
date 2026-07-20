import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/wheel_of_year/data/models/sabbat_model.dart';
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

  Future<NotificationScheduleResult> showDebugNotification() async {
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
        title: _l10n.notifFullMoonTitle,
        body: _l10n.notifFullMoonBody,
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: _moonDetails(),
      );

  Future<void> scheduleNewMoonNotification(DateTime eventDate) => _schedule(
        id: notificationId('new_moon', eventDate),
        title: _l10n.notifNewMoonTitle,
        body: _l10n.notifNewMoonBody,
        localDate: reminderDate(eventDate, daysBefore: 1, hour: 20),
        details: _moonDetails(),
      );

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
        details: NotificationDetails(
          android: AndroidNotificationDetails(
            'sabbat_notifications',
            _l10n.notifChannelSabbatName,
            channelDescription: _l10n.notifChannelSabbatDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
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
        return NotificationScheduleResult(
          permissionGranted: false,
          error: _l10n.notifErrPermissionDenied,
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
        error: _l10n.notifErrScheduleFailed('$e'),
      );
    }
  }
}
