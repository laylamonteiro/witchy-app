/// Política que diferencia uma retomada rápida de uma nova sessão do app.
class AppSessionPolicy {
  static const inactivityThreshold = Duration(minutes: 5);

  static bool shouldStartNewSession({
    required DateTime? backgroundedAt,
    required DateTime now,
  }) {
    if (backgroundedAt == null) return false;
    return now.difference(backgroundedAt) >= inactivityThreshold;
  }
}
