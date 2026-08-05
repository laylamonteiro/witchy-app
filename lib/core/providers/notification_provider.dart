import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../../features/lunar/presentation/providers/lunar_provider.dart';
import '../../features/wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import '../../features/wheel_of_year/data/models/sabbat_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  final SharedPreferences _prefs;

  bool _fullMoonNotifications = true;
  bool _newMoonNotifications = true;
  bool _sabbatNotifications = true;
  // Água solar é opt-in (semanal, aos domingos) para não virar spam.
  bool _sunWaterNotifications = false;
  // Lembrete diário do Salem: ligado por padrão (é o convite de volta ao
  // ritual do dia), com horário escolhido pela Bruxa. Quem desliga tem a
  // escolha gravada nas prefs e não é reativado.
  bool _dailyReminder = true;
  int _dailyReminderHour = 9;
  bool _initialized = false;
  bool? _permissionGranted;
  int _scheduledCount = 0;
  String? _lastError;

  NotificationProvider(
    FlutterLocalNotificationsPlugin notificationsPlugin,
    this._prefs,
  ) : _notificationService = NotificationService(notificationsPlugin) {
    _loadPreferences();
  }

  bool get fullMoonNotifications => _fullMoonNotifications;
  bool get newMoonNotifications => _newMoonNotifications;
  bool get sabbatNotifications => _sabbatNotifications;
  bool get sunWaterNotifications => _sunWaterNotifications;
  bool get dailyReminder => _dailyReminder;
  int get dailyReminderHour => _dailyReminderHour;
  bool? get permissionGranted => _permissionGranted;
  int get scheduledCount => _scheduledCount;
  String? get lastError => _lastError;
  bool get isInitialized => _initialized;

  Future<List<PendingNotificationRequest>> pendingNotifications() =>
      _notificationService.pendingNotifications();

  Future<bool?> areNotificationsEnabled() =>
      _notificationService.areNotificationsEnabled();

  Future<NotificationScheduleResult> sendDebugNotification(
      {String? payload}) async {
    final result =
        await _notificationService.showDebugNotification(payload: payload);
    _permissionGranted = result.permissionGranted;
    _lastError = result.error;
    notifyListeners();
    return result;
  }

  /// Solicita permissão e agenda apenas depois que o login foi concluído.
  Future<void> updateSession({
    required bool isAuthenticated,
    required LunarProvider lunarProvider,
    required WheelOfYearProvider wheelProvider,
  }) async {
    if (kIsWeb) return;
    if (!isAuthenticated) {
      _initialized = false;
      return;
    }
    if (_initialized) return;

    _initialized = true;
    await scheduleNotifications(
      lunarProvider: lunarProvider,
      wheelProvider: wheelProvider,
    );
  }

  void _loadPreferences() {
    _fullMoonNotifications = _prefs.getBool('fullMoonNotifications') ?? true;
    _newMoonNotifications = _prefs.getBool('newMoonNotifications') ?? true;
    _sabbatNotifications = _prefs.getBool('sabbatNotifications') ?? true;
    _sunWaterNotifications = _prefs.getBool('sunWaterNotifications') ?? false;
    _dailyReminder = _prefs.getBool('dailyReminder') ?? true;
    _dailyReminderHour = _prefs.getInt('dailyReminderHour') ?? 9;
  }

  Future<void> setFullMoonNotifications(bool value) async {
    _fullMoonNotifications = value;
    await _prefs.setBool('fullMoonNotifications', value);
    notifyListeners();
  }

  Future<void> setNewMoonNotifications(bool value) async {
    _newMoonNotifications = value;
    await _prefs.setBool('newMoonNotifications', value);
    notifyListeners();
  }

  Future<void> setSabbatNotifications(bool value) async {
    _sabbatNotifications = value;
    await _prefs.setBool('sabbatNotifications', value);
    notifyListeners();
  }

  Future<void> setSunWaterNotifications(bool value) async {
    _sunWaterNotifications = value;
    await _prefs.setBool('sunWaterNotifications', value);
    notifyListeners();
  }

  Future<void> setDailyReminder(bool value) async {
    _dailyReminder = value;
    await _prefs.setBool('dailyReminder', value);
    notifyListeners();
  }

  Future<void> setDailyReminderHour(int hour) async {
    _dailyReminderHour = hour;
    await _prefs.setInt('dailyReminderHour', hour);
    notifyListeners();
  }

  Future<NotificationScheduleResult> scheduleNotifications({
    required LunarProvider lunarProvider,
    required WheelOfYearProvider wheelProvider,
  }) async {
    final List<DateTime> fullMoons = [];
    final List<DateTime> newMoons = [];

    if (_fullMoonNotifications || _newMoonNotifications) {
      DateTime currentDate = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final tempProvider = LunarProvider();
        tempProvider.setSelectedDate(currentDate);

        if (_fullMoonNotifications) {
          final nextFullMoon = tempProvider.getNextFullMoon();
          if (nextFullMoon != null && nextFullMoon.isAfter(DateTime.now())) {
            fullMoons.add(nextFullMoon);
            currentDate = nextFullMoon.add(const Duration(days: 1));
          }
        }

        if (_newMoonNotifications) {
          final nextNewMoon = tempProvider.getNextNewMoon();
          if (nextNewMoon != null && nextNewMoon.isAfter(DateTime.now())) {
            newMoons.add(nextNewMoon);
            if (currentDate.isBefore(nextNewMoon)) {
              currentDate = nextNewMoon.add(const Duration(days: 1));
            }
          }
        }
      }
    }

    final sabbats =
        _sabbatNotifications ? wheelProvider.getAllSabbats() : <Sabbat>[];

    // Nenhum aviso ligado (incluindo o lembrete diário) = cancela tudo.
    if (!_fullMoonNotifications &&
        !_newMoonNotifications &&
        !_sabbatNotifications &&
        !_sunWaterNotifications &&
        !_dailyReminder) {
      await _notificationService.cancelAllNotifications();
      _permissionGranted = true;
      _scheduledCount = 0;
      _lastError = null;
      notifyListeners();
      return const NotificationScheduleResult(permissionGranted: true);
    }

    final result = await _notificationService.scheduleNotifications(
      fullMoonDates: fullMoons,
      newMoonDates: newMoons,
      sabbats: sabbats,
      sunWater: _sunWaterNotifications,
      dailyReminder: _dailyReminder,
      dailyReminderHour: _dailyReminderHour,
    );
    _permissionGranted = result.permissionGranted;
    _scheduledCount = result.scheduledCount;
    _lastError = result.error;
    notifyListeners();
    return result;
  }
}
