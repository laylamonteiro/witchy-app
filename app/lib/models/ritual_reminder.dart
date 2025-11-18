// lib/models/ritual_reminder.dart
enum RitualType {
  meditation,
  visualization,
  gratitude,
  dreamJournal,
  custom,
}

class RitualReminder {
  final String id;
  final RitualType type;
  final String? customLabel; // se type == custom
  final int hour; // 0-23
  final int minute; // 0-59
  final bool enabled;

  RitualReminder({
    required this.id,
    required this.type,
    this.customLabel,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'customLabel': customLabel,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
    };
  }

  factory RitualReminder.fromMap(Map<String, dynamic> map) {
    return RitualReminder(
      id: map['id'] as String,
      type: RitualType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => RitualType.custom,
      ),
      customLabel: map['customLabel'] as String?,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      enabled: map['enabled'] as bool,
    );
  }
}
