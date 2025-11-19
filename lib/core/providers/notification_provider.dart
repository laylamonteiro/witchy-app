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

  NotificationProvider(
    FlutterLocalNotificationsPlugin notificationsPlugin,
    this._prefs,
  ) : _notificationService = NotificationService(notificationsPlugin) {
    _loadPreferences();
  }

  bool get fullMoonNotifications => _fullMoonNotifications;
  bool get newMoonNotifications => _newMoonNotifications;
  bool get sabbatNotifications => _sabbatNotifications;

  void _loadPreferences() {
    _fullMoonNotifications = _prefs.getBool('fullMoonNotifications') ?? true;
    _newMoonNotifications = _prefs.getBool('newMoonNotifications') ?? true;
    _sabbatNotifications = _prefs.getBool('sabbatNotifications') ?? true;
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

  /// Agendar notificações com base nas configurações atuais
  Future<void> scheduleNotifications({
    required LunarProvider lunarProvider,
    required WheelOfYearProvider wheelProvider,
  }) async {
    await _notificationService.cancelAllNotifications();

    final now = DateTime.now();
    final List<DateTime> fullMoons = [];
    final List<DateTime> newMoons = [];

    // Coletar próximas 3 luas cheias e novas
    // Simplificação: usar datas aproximadas (dia 15 para cheia, dia 1 para nova)
    // Em produção, usar cálculo preciso baseado em lunar
    if (_fullMoonNotifications || _newMoonNotifications) {
      for (int month = 0; month < 3; month++) {
        if (_fullMoonNotifications) {
          fullMoons.add(DateTime(now.year, now.month + month, 15));
        }
        if (_newMoonNotifications) {
          newMoons.add(DateTime(now.year, now.month + month, 1));
        }
      }
    }

    final sabbats = _sabbatNotifications ? wheelProvider.getAllSabbats() : <Sabbat>[];

    await _notificationService.scheduleMonthlyNotifications(
      fullMoonDates: fullMoons,
      newMoonDates: newMoons,
      sabbats: sabbats,
    );
  }
}
