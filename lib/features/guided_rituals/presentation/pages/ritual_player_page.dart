import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../journeys/domain/action_outcome.dart';
import '../../../journeys/domain/action_recorder.dart';
import '../../data/models/guided_ritual_model.dart';
import '../../data/repositories/guided_ritual_log_repository.dart';
import '../widgets/ritual_circle.dart';

/// Player passo a passo de um ritual guiado: checkboxes, progresso e XP ao
/// concluir. Free vê o primeiro passo liberado e o restante como preview
/// premium (padrão PremiumContentSection).
class RitualPlayerPage extends StatefulWidget {
  final GuidedRitual ritual;

  /// Injetável em testes; por padrão o repositório local.
  final GuidedRitualLogRepository? repository;

  const RitualPlayerPage({super.key, required this.ritual, this.repository});

  @override
  State<RitualPlayerPage> createState() => _RitualPlayerPageState();
}

class _RitualPlayerPageState extends State<RitualPlayerPage> {
  final Set<int> _completed = {};
  late final GuidedRitualLogRepository _repository =
      widget.repository ?? GuidedRitualLogRepository();

  /// A conclusão desta sessão do player é UMA ocorrência: gravada uma vez,
  /// mesmo que os passos sejam desmarcados e marcados de novo.
  bool _logged = false;
  bool _logging = false;
  bool _logFailed = false;

  List<RitualStepText> get _steps => widget.ritual.steps;

  bool get _allDone => _completed.length == _steps.length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasFullAccess = context
        .watch<AuthProvider>()
        .checkFeatureAccess(AppFeature.guidedRitualPlayer)
        .hasFullAccess;

    return Scaffold(
      appBar: AppBar(title: ResponsiveAppBarTitle(widget.ritual.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgress(context),
            if (hasFullAccess)
              ..._steps.asMap().entries.map(
                  (entry) => _buildStep(context, entry.key, entry.value, true))
            else ...[
              _buildStep(context, 0, _steps.first, true),
              MagicalCard(
                child: PremiumContentSection(
                  feature: AppFeature.guidedRitualPlayer,
                  title: Text(
                    l10n.guidedRitualLockedStepsTitle(_steps.length - 1),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  subtitle: l10n.guidedRitualLockedStepsSubtitle,
                  contentBuilder: (context) => Column(
                    children: _steps
                        .asMap()
                        .entries
                        .skip(1)
                        .map((entry) =>
                            _buildStep(context, entry.key, entry.value, true))
                        .toList(),
                  ),
                ),
              ),
            ],
            if (_allDone && hasFullAccess) _buildCompletion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // O círculo ritual: cada passo concluído acende um trecho; o
              // último fecha o círculo. Segue a lista, nunca o contrário.
              RitualCircle(
                key: const ValueKey('ritual-circle'),
                steps: _steps.length,
                lit: _completed.length,
                emblem: widget.ritual.emoji,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.guidedRitualProgress(_completed.length, _steps.length),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, int index, RitualStepText step, bool enabled) {
    final done = _completed.contains(index);
    return MagicalCard(
      child: CheckboxListTile(
        value: done,
        onChanged: enabled
            ? (value) {
                setState(() {
                  if (value == true) {
                    _completed.add(index);
                  } else {
                    _completed.remove(index);
                  }
                });
                if (_allDone) _onAllStepsDone();
              }
            : null,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: context.gc.lilac,
        contentPadding: EdgeInsets.zero,
        title: Text(
          '${index + 1}. ${step.title}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: done ? TextDecoration.lineThrough : null,
                color: done ? context.gc.textSecondary : null,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            step.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
      ),
    );
  }

  /// Grava a conclusão e só então anuncia; falha oferece retomar a
  /// gravação, sem celebrar um sucesso que não aconteceu.
  Future<void> _onAllStepsDone() async {
    if (_logged || _logging) return;
    setState(() { _logging = true; _logFailed = false; });
    final userId = context.read<AuthProvider>().currentUser.id;
    final recorder = ActionRecorder.of(context);
    try {
      await _repository.logCompletion(
        userId: userId,
        ritualId: widget.ritual.id,
        xp: widget.ritual.xpReward,
        eventDate: DateTime.now(),
      );
    } catch (_) {
      if (mounted) setState(() { _logging = false; _logFailed = true; });
      return;
    }
    if (!mounted) return;
    setState(() { _logged = true; _logging = false; });
    unawaited(recorder.record(origin: ActionOrigin.ritual, entityId: widget.ritual.id));
  }

  Widget _buildCompletion(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_logFailed) {
      return MagicalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.guidedRitualLogFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.gc.alert),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('ritual-log-retry'),
              onPressed: _onAllStepsDone,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.advisorRetry),
            ),
          ],
        ),
      );
    }
    if (!_logged) {
      return const MagicalCard(
        child: Center(child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        )),
      );
    }
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text('✨', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.guidedRitualCompletedTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.guidedRitualCompletedBody(widget.ritual.xpReward),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.gc.starYellow,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
