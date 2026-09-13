import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../data/data_sources/blood_lore_content.dart';
import '../menstrual_shortcuts.dart';
import '../menstrual_type.dart';
import '../widgets/blood_lore_tag_chip.dart';

/// Um verbete dos Saberes do Sangue — um texto de história ou uma prática.
///
/// É um renderizador só para os dois casos de propósito: assim uma prática
/// explica de onde veio com as mesmas seções de um verbete de história, e
/// nenhuma delas pode ser publicada sem a sua classificação.
///
/// O convite do rodapé nunca cria nada novo: ou leva a um verbete irmão, ou
/// abre uma ferramenta que o Grimório já tem.
class BloodLoreEntryPage extends StatelessWidget {
  const BloodLoreEntryPage({super.key, required this.entry});

  final BloodLoreEntry entry;

  @override
  Widget build(BuildContext context) {
    final content = bloodLoreContent;
    final body = MenstrualType.body(context);
    final head = MenstrualType.sectionHead(context);
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(entry.title),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: StaggeredEntrance(
          children: [
            // A classificação vem ANTES do texto: saber de onde uma prática
            // veio muda o jeito de lê-la.
            MagicalCard(
              key: ValueKey('blood-lore-head-${entry.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(entry.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(entry.title,
                            style: MenstrualType.cardTitle(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(content.classificationLabel, style: head),
                  const SizedBox(height: 6),
                  BloodLoreTagChip(tag: entry.tag),
                  const SizedBox(height: 12),
                  Text(entry.summary, style: MenstrualType.quiet(context)),
                ],
              ),
            ),

            if (entry.isPractice)
              MagicalCard(
                key: ValueKey('blood-lore-practice-${entry.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.intention != null) ...[
                      Text(content.practiceIntentionLabel, style: head),
                      const SizedBox(height: 6),
                      Text(entry.intention!, style: body),
                      const SizedBox(height: 12),
                    ],
                    if (entry.materials.isNotEmpty) ...[
                      Text(content.practiceMaterialsLabel, style: head),
                      const SizedBox(height: 6),
                      for (final material in entry.materials)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('· $material', style: body),
                        ),
                      const SizedBox(height: 12),
                    ],
                    Text(content.practiceStepsLabel, style: head),
                    const SizedBox(height: 6),
                    for (var i = 0; i < entry.steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('${i + 1}. ${entry.steps[i]}', style: body),
                      ),
                    if (entry.withoutBlood != null) ...[
                      const SizedBox(height: 12),
                      Text(content.practiceWithoutBloodLabel, style: head),
                      const SizedBox(height: 6),
                      Text(
                        entry.withoutBlood!,
                        key: ValueKey('blood-lore-without-blood-${entry.id}'),
                        style: body,
                      ),
                    ],
                  ],
                ),
              ),

            for (final section in entry.sections)
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: head),
                    const SizedBox(height: 8),
                    Text(section.body, style: body),
                  ],
                ),
              ),

            // A nota de segurança acompanha tudo o que fala de sangue —
            // discreta, no fim, sempre com as mesmas palavras.
            if (entry.mentionsBlood)
              MagicalCard(
                key: ValueKey('blood-lore-safety-${entry.id}'),
                child: Text(content.safetyNote,
                    style: MenstrualType.caption(context)),
              ),

            if (entry.cta != null) _Cta(cta: entry.cta!),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// O convite do rodapé. Um verbete irmão é aberto aqui mesmo; qualquer outro
/// destino é uma ferramenta que já existe, e quem sabe abri-la é o
/// [MenstrualShortcuts].
class _Cta extends StatelessWidget {
  const _Cta({required this.cta});

  final BloodLoreCta cta;

  @override
  Widget build(BuildContext context) {
    final target =
        cta.link == BloodLoreLink.entry && cta.entryId != null
            ? bloodLoreContent.byId(cta.entryId!)
            : null;
    // Um convite que aponta para um verbete que não existe simplesmente não
    // aparece, em vez de levar a lugar nenhum.
    if (cta.link == BloodLoreLink.entry && target == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          key: const ValueKey('blood-lore-cta'),
          onPressed: () {
            if (target != null) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BloodLoreEntryPage(entry: target),
              ));
              return;
            }
            MenstrualShortcuts.follow(context, cta.link);
          },
          child: Text(cta.label),
        ),
      ),
    );
  }
}
