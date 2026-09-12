import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/motion/action_feedback_host.dart';
import 'package:grimorio_de_bolso/features/journeys/data/repositories/journey_stats_repository.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/action_outcome.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/progress_coordinator.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  ActionOutcome outcome(String id, {List<String> milestones = const [], int xp = 5,
      bool day = false, LearningLevel? level}) => ActionOutcome(
    actionId: id, userId: 'u', origin: ActionOrigin.dream, entityId: 'e',
    xpBefore: 0, xpAfter: xp, dayCompleted: day, newLevel: level,
    newMilestones: [for (final m in milestones) JourneyStatsRepository.stepById(m)!],
  );

  Future<ProgressCoordinator> show(WidgetTester tester, {bool reduced = false}) async {
    final coordinator = ProgressCoordinator();
    await tester.pumpWidget(ChangeNotifierProvider<ProgressCoordinator>.value(
      value: coordinator,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: ActionFeedbackHost(child: child!),
        ),
        home: const Scaffold(body: Center(child: Text('Page content'))),
      ),
    ));
    await tester.pump();
    return coordinator;
  }

  testWidgets('one composition carries XP, milestones, level and day; tap dismisses',
      (tester) async {
    final coordinator = await show(tester);
    expect(find.byKey(const ValueKey('feedback-card')), findsNothing);
    coordinator.present(outcome('a', milestones: ['son_01_02', 'ini_01_02'], xp: 20,
        day: true, level: LearningProvider.levels[1]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('feedback-card')), findsOneWidget);
    expect(find.text('Dream saved'), findsOneWidget);
    expect(find.text('+20 XP'), findsOneWidget);
    expect(find.text('2 milestones reached'), findsOneWidget);
    expect(find.byKey(const ValueKey('feedback-level')), findsOneWidget);
    expect(find.byKey(const ValueKey('feedback-day')), findsOneWidget);
    expect(find.text('Page content'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('feedback-card')));
    await tester.pump();
    expect(find.byKey(const ValueKey('feedback-card')), findsNothing);
    expect(coordinator.current, isNull);
  });

  testWidgets('outcomes queue one after another and leave on their own', (tester) async {
    final coordinator = await show(tester, reduced: true);
    coordinator.present(outcome('first'));
    coordinator.present(outcome('second', xp: 0, milestones: ['son_01_01']));
    await tester.pump();
    expect(find.text('+5 XP'), findsOneWidget);
    expect(find.text('Milestone reached'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('+5 XP'), findsNothing);
    expect(find.text('Milestone reached'), findsOneWidget);
    expect(find.byKey(const ValueKey('feedback-xp')), findsNothing,
        reason: 'No XP line when nothing was gained');
    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const ValueKey('feedback-card')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without a coordinator the host is just its child', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ActionFeedbackHost(child: Text('Alone')),
    ));
    expect(find.text('Alone'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
