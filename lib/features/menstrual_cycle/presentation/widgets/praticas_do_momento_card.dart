import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../data/data_sources/blood_lore_content.dart';
import '../../domain/menstrual_moment.dart';
import '../../domain/menstrual_shortcut.dart';
import '../menstrual_shortcuts.dart';
import '../menstrual_type.dart';

/// "Práticas para este momento": um punhado de portas para o que o Grimório
/// já tem.
///
/// Esta seção NÃO cria sistema nenhum. Ela olha para duas coisas — se ela
/// marcou sangue hoje e qual é a Lua de hoje — e oferece atalhos: escrever
/// no Diário, tirar no Oráculo, registrar um sonho, criar um sigilo, ler uma
/// prática. O que nascer de cada porta nasce e vive na ferramenta de origem.
///
/// A linguagem é sempre de possibilidade ("pode", "costuma ser associada",
/// "se isso fizer sentido"). Nunca "seu corpo está pedindo", nunca "você
/// está mais intuitiva porque", nunca "você deve".
class PraticasDoMomentoCard extends StatelessWidget {
  const PraticasDoMomentoCard({super.key, required this.moment});

  final MenstrualMoment moment;

  @override
  Widget build(BuildContext context) {
    final content = bloodLoreContent;
    return MagicalCard(
      key: const ValueKey('menstrual-momento'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 18, color: context.gc.lilac),
              const SizedBox(width: 8),
              Expanded(
                child: Text(content.momentTitle,
                    style: MenstrualType.cardTitle(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content.momentIntro, style: MenstrualType.quiet(context)),
          // A correspondência só aparece quando as duas pontas falam da mesma
          // coisa: sangramento e Lua que recolhe. Fora disso, silêncio — é
          // melhor não dizer nada do que inventar um encontro.
          if (moment.sharesClosing) ...[
            const SizedBox(height: 12),
            Text(
              BloodLoreContent.fill(content.closingCorrespondence,
                  {'phase': moment.phase.displayName}),
              key: const ValueKey('menstrual-momento-lua'),
              style: MenstrualType.body(context),
            ),
          ],
          const SizedBox(height: 4),
          for (final shortcut in moment.shortcuts)
            _ShortcutRow(shortcut: shortcut, content: content),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.shortcut, required this.content});

  final MenstrualShortcut shortcut;
  final BloodLoreContent content;

  @override
  Widget build(BuildContext context) {
    final texts = content.shortcuts[shortcut]!;
    final colors = context.gc;
    return InkWell(
      key: ValueKey('menstrual-momento-${shortcut.name}'),
      onTap: () => MenstrualShortcuts.open(context, shortcut),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child:
                  Text(shortcut.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(texts.title, style: MenstrualType.body(context)),
                  const SizedBox(height: 2),
                  Text(texts.body, style: MenstrualType.quiet(context)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 18, color: colors.lilac),
          ],
        ),
      ),
    );
  }
}
