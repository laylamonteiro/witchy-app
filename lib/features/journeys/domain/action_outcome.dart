import '../../learning/presentation/providers/learning_provider.dart';
import '../data/models/journey_model.dart';

/// What the person just did, for the feedback's wording only.
enum ActionOrigin {
  dream,
  gratitude,
  desire,
  desireManifested,
  desireReleased,
  affirmation,
  spell,
  sigil,
  encyclopedia,
  reading,
  ritual,
  lesson,
  other,
}

/// The result of one persisted action: the XP the stored formula now
/// yields, the level it lands on, the journey steps reached for the first
/// time and whether the day just closed. Built after persistence, never by
/// an animation; presented at most once, by this session only.
class ActionOutcome {
  const ActionOutcome({
    required this.actionId,
    required this.userId,
    required this.origin,
    required this.entityId,
    required this.xpBefore,
    required this.xpAfter,
    this.newLevel,
    this.newMilestones = const [],
    this.dayCompleted = false,
  });

  final String actionId;
  final String userId;
  final ActionOrigin origin;
  final String entityId;
  final int xpBefore;
  final int xpAfter;

  /// Level entered by this action, identified by its threshold, never by
  /// the translated title.
  final LearningLevel? newLevel;
  final List<JourneyStep> newMilestones;
  final bool dayCompleted;

  int get xpGained => xpAfter - xpBefore;

  /// Something beyond the plain confirmation: a milestone, a level or a
  /// closed day. It is what earns the mascot's reaction.
  bool get isCelebration =>
      newLevel != null || newMilestones.isNotEmpty || dayCompleted;
}
