import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../learning/presentation/providers/learning_provider.dart';
import '../../your_day/domain/day_completion_service.dart';
import '../../your_day/presentation/providers/daily_checkin_provider.dart';
import '../data/repositories/journey_stats_repository.dart';
import '../data/repositories/progress_milestone_repository.dart';
import 'action_outcome.dart';

/// Turns a persisted action into one [ActionOutcome]: progress before,
/// refresh through the existing XP formula, progress after, milestones
/// reached for the first time, level change and day completion. Evaluations
/// are serialized per account so a concurrent action never claims another's
/// points. Only outcomes recorded here are ever presented; loading history
/// or syncing changes numbers silently.
class ProgressCoordinator extends ChangeNotifier {
  ProgressCoordinator({
    JourneyStatsRepository? stats,
    ProgressMilestoneRepository? milestones,
    DayCompletionService? day,
  })  : _stats = stats ?? JourneyStatsRepository(),
        _milestones = milestones ?? ProgressMilestoneRepository(),
        _day = day ?? DayCompletionService();

  final JourneyStatsRepository _stats;
  final ProgressMilestoneRepository _milestones;
  final DayCompletionService _day;

  final Map<String, Future<void>> _adoption = {};
  final Map<String, Future<void>> _chain = {};
  final Queue<ActionOutcome> _queue = Queue();
  ActionOutcome? _current;
  String? _userId;

  /// Called for celebrations (milestone, level, closed day); the mascot's
  /// reaction hangs here and decides for itself whether it is appropriate.
  void Function()? onCelebration;

  String? get userId => _userId;

  /// Steps this account had already reached before the update, or reached
  /// while the app was closed, are adopted silently once per process.
  Future<void> setUserId(String userId) {
    _userId = userId;
    if (_current != null && _current!.userId != userId) {
      _queue.clear();
      _current = null;
      notifyListeners();
    }
    return _adoption[userId] ??= _adopt(userId);
  }

  Future<void> _adopt(String userId) async {
    try {
      final stats = await _stats.load(userId);
      await _milestones.record(
          userId: userId, milestoneIds: JourneyStatsRepository.reachedSteps(stats));
    } catch (_) {
      // Without adoption the next action would present old steps as new;
      // forget the attempt so it can run again.
      _adoption.remove(userId);
    }
  }

  /// Evaluate after [origin] persisted [entityId]. [learning] provides the
  /// stored XP formula; [checkin] enables day completion. With [present]
  /// the outcome enters the feedback queue.
  Future<ActionOutcome> record({
    required String userId,
    required ActionOrigin origin,
    required String entityId,
    required LearningProvider learning,
    DailyCheckinProvider? checkin,
    bool present = true,
    DateTime? now,
  }) {
    final previous = _chain[userId] ?? Future<void>.value();
    final run = previous.then((_) => _evaluate(
        userId: userId, origin: origin, entityId: entityId,
        learning: learning, checkin: checkin, present: present, now: now));
    _chain[userId] = run.then<void>((_) {}, onError: (_) {});
    return run;
  }

  Future<ActionOutcome> _evaluate({
    required String userId,
    required ActionOrigin origin,
    required String entityId,
    required LearningProvider learning,
    required DailyCheckinProvider? checkin,
    required bool present,
    required DateTime? now,
  }) async {
    await (_adoption[userId] ??= _adopt(userId));
    final actionId = const Uuid().v4();
    final xpBefore = learning.xp;
    final levelBefore = learning.level;
    var dayCompleted = false;
    if (checkin != null) {
      dayCompleted = await _day.evaluate(userId: userId, checkin: checkin, now: now);
    }
    await learning.refreshPracticeXp();
    final stats = await _stats.load(userId);
    final fresh = await _milestones.record(
      userId: userId,
      milestoneIds: JourneyStatsRepository.reachedSteps(stats),
      sourceActionId: actionId,
      at: now,
    );
    final levelAfter = learning.level;
    final outcome = ActionOutcome(
      actionId: actionId,
      userId: userId,
      origin: origin,
      entityId: entityId,
      xpBefore: xpBefore,
      xpAfter: learning.xp,
      newLevel: levelAfter.minXp != levelBefore.minXp ? levelAfter : null,
      newMilestones: [
        for (final id in fresh)
          if (JourneyStatsRepository.stepById(id) case final step?) step,
      ],
      dayCompleted: dayCompleted,
    );
    if (present && userId == _userId) {
      _queue.add(outcome);
      if (_current == null) _current = _queue.removeFirst();
      notifyListeners();
      if (outcome.isCelebration) onCelebration?.call();
      if (dayCompleted) checkin?.markDayCelebrationShown();
    }
    return outcome;
  }

  /// The outcome being presented, if any. One at a time, in order.
  ActionOutcome? get current => _current;

  void dismiss() {
    if (_current == null) return;
    _current = _queue.isEmpty ? null : _queue.removeFirst();
    notifyListeners();
  }

  /// Presents an outcome built elsewhere (tests and the gallery).
  @visibleForTesting
  void present(ActionOutcome outcome) {
    _queue.add(outcome);
    if (_current == null) _current = _queue.removeFirst();
    notifyListeners();
  }
}
