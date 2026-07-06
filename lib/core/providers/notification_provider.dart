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

    final List<DateTime> fullMoons = [];
    final List<DateTime> newMoons = [];

    // Coletar próximas 3 luas cheias e novas usando cálculos precisos
    if (_fullMoonNotifications || _newMoonNotifications) {
      // Criar uma cópia do provider para não afetar o estado atual
      DateTime currentDate = DateTime.now();

      for (int i = 0; i < 3; i++) {
        // Obter próximas luas usando o LunarProvider
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
            // Avançar para depois da lua nova para encontrar a próxima
            if (currentDate.isBefore(nextNewMoon)) {
              currentDate = nextNewMoon.add(const Duration(days: 1));
            }
          }
        }
      }
    }

    final sabbats = _sabbatNotifications ? wheelProvider.getAllSabbats() : <Sabbat>[];

    try {
      await _notificationService.scheduleMonthlyNotifications(
        fullMoonDates: fullMoons,
        newMoonDates: newMoons,
        sabbats: sabbats,
      );
    } catch (e) {
      debugPrint('Erro ao agendar notificações mensais: $e');
    }
  }
}
