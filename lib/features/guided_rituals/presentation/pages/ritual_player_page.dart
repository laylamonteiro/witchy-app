import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../grimoire/presentation/pages/spell_form_page.dart';
import '../../data/models/guided_ritual_model.dart';
import '../../data/repositories/guided_ritual_log_repository.dart';

/// Player passo a passo de um ritual guiado: checkboxes, progresso e XP ao
/// concluir. Free vê o primeiro passo liberado e o restante como preview
/// premium (padrão PremiumContentSection).
class RitualPlayerPage extends StatefulWidget {
  final GuidedRitual ritual;

  const RitualPlayerPage({super.key, required this.ritual});

  @override
  State<RitualPlayerPage> createState() => _RitualPlayerPageState();
}

class _RitualPlayerPageState extends State<RitualPlayerPage> {
  final Set<int> _completed = {};
  final GuidedRitualLogRepository _repository = GuidedRitualLogRepository();
  bool _logged = false;

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
              Text(widget.ritual.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.guidedRitualProgress(_completed.length, _steps.length),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _steps.isEmpty ? 0 : _completed.length / _steps.length,
              minHeight: 10,
              backgroundColor: context.gc.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(context.gc.lilac),
            ),
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

  Future<void> _onAllStepsDone() async {
    if (_logged) return;
    _logged = true;
    final userId = context.read<AuthProvider>().currentUser.id;
    await _repository.logCompletion(
      userId: userId,
      ritualId: widget.ritual.id,
      xp: widget.ritual.xpReward,
      eventDate: DateTime.now(),
    );
  }

  Widget _buildCompletion(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          const SizedBox(height: 16),
          MagicalButton(
            text: l10n.guidedRitualCreateSpellCta,
            icon: Icons.auto_fix_high,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SpellFormPage(
                    initialCategory: widget.ritual.suggestedSpellCategory,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
