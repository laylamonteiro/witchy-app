import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/journeys/data/repositories/journey_stats_repository.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/action_outcome.dart';
import 'package:grimorio_de_bolso/features/learning/data/data_sources/trails_data.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/widgets/bound_book_cover.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/widgets/lesson_celebration_card.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/widgets/wax_seal_stamp.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  final trail = learningTrails.first;

  Future<void> show(WidgetTester tester, LessonReward reward,
      {ActionOutcome? outcome, VoidCallback? onDone, bool reduced = false}) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: SingleChildScrollView(child: LessonCelebrationCard(
          trail: trail, reward: reward, outcome: outcome, onDone: onDone ?? () {},
          onShare: () {},
        ))),
      ),
    ));
    await tester.pump();
  }

  testWidgets('a sealed page shows the wax seal and the lesson XP only', (tester) async {
    var done = false;
    await show(tester, const LessonReward(xpGained: 25), onDone: () => done = true);
    expect(find.byType(WaxSealStamp), findsOneWidget);
    expect(find.byType(BoundBookCover), findsNothing);
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-level')), findsNothing);
    expect(find.byKey(const ValueKey('lesson-milestones')), findsNothing);
    expect(find.text('Share'), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('lesson-so-be-it')));
    expect(done, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a bound trail closes the book and folds level, milestones and day in',
      (tester) async {
    final outcome = ActionOutcome(
      actionId: 'a', userId: 'u', origin: ActionOrigin.lesson, entityId: 'l',
      xpBefore: 0, xpAfter: 0, dayCompleted: true,
      newMilestones: [JourneyStatsRepository.stepById('ini_01_01')!],
    );
    await show(tester, LessonReward(xpGained: 125, trailBound: true,
        leveledUpTo: LearningProvider.levels[1]), outcome: outcome, reduced: true);
    expect(find.byType(BoundBookCover), findsOneWidget);
    expect(find.byType(WaxSealStamp), findsNothing);
    expect(find.text('+125 XP'), findsOneWidget, reason: 'The trail bonus is counted once');
    expect(find.byKey(const ValueKey('lesson-level')), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-milestones')), findsOneWidget);
    expect(find.text('Milestone reached'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-day')), findsOneWidget);
    expect(find.textContaining(trail.title), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('covers are keyed by trail id and the seal replays by token', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Row(children: [
      for (final t in learningTrails.take(3))
        BoundBookCover(trailId: t.id, emblem: t.emoji, width: 48),
      const WaxSealStamp(size: 48, playToken: 1),
    ]))));
    await tester.pump();
    final accents = {for (final t in learningTrails.take(3))
      TrailCoverRegistry.accentFor(tester.element(find.byType(Row)), t.id)};
    expect(accents, hasLength(3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
