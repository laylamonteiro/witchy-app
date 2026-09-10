import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../../learning/presentation/providers/learning_provider.dart';
import '../../your_day/presentation/providers/daily_checkin_provider.dart';
import 'action_outcome.dart';
import 'progress_coordinator.dart';

/// Captures, before any await, everything an action needs to be recorded
/// after it persisted. Screens read it while their context is still valid
/// and call [record] once the write succeeded; without the providers (a
/// widget test, a detached screen) it records nothing and never throws.
class ActionRecorder {
  ActionRecorder.of(BuildContext context)
      : _coordinator = context.read<ProgressCoordinator?>(),
        _learning = context.read<LearningProvider?>(),
        _checkin = context.read<DailyCheckinProvider?>(),
        _userId = context.read<AuthProvider?>()?.currentUser.id;

  final ProgressCoordinator? _coordinator;
  final LearningProvider? _learning;
  final DailyCheckinProvider? _checkin;
  final String? _userId;

  bool get isAvailable => _coordinator != null && _learning != null && _userId != null;

  Future<ActionOutcome?> record({
    required ActionOrigin origin,
    required String entityId,
    bool present = true,
  }) async {
    if (!isAvailable) return null;
    try {
      return await _coordinator!.record(
        userId: _userId!,
        origin: origin,
        entityId: entityId,
        learning: _learning!,
        checkin: _checkin,
        present: present,
      );
    } catch (_) {
      return null; // The record itself already happened; feedback is optional.
    }
  }
}
