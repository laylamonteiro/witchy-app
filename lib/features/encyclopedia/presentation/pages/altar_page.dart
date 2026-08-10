import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/expansion_magical_card.dart';
import '../../data/data_sources/altar_content.dart';

/// Página informativa sobre altares.
///
/// Todo o conteúdo textual vem de `altar_content.dart` (ContentLocale),
/// localizado em pt/en/es.
class AltarPage extends StatelessWidget {
  const AltarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final content = altarContent;

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(content.pageTitle),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StaggeredEntrance(
          children: [
            const LivingEmblem(emblem: SectionEmblem.altar),
            const SizedBox(height: 12),
            // Introdução
            MagicalCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🛐', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          content.introTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.introBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.introHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Passo-a-Passo para Iniciantes
            _buildPassoAPasso(context, content),

            const SizedBox(height: 16),

            // Como montar
            ExpansionMagicalCard(
              title: content.mountTitle,
              emoji: '🏡',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final step in content.mountSteps)
                    _buildStep(context, step.title, step.description),
                ],
              ),
            ),

            // O que usar
            ExpansionMagicalCard(
              title: content.itemsTitle,
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final item in content.items)
                    _buildItem(context, item.emoji, item.title,
                        item.description),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.lilac.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      content.itemsNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // O que não usar
            ExpansionMagicalCard(
              title: content.avoidTitle,
              emoji: '⚠️',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final item in content.avoidItems)
                    _buildWarning(context, item.title, item.description),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.alert.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: context.gc.alert.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            content.safetyNote,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Como purificar
            ExpansionMagicalCard(
              title: content.purifyTitle,
              emoji: '🌊',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    content.purifyIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  for (final method in content.purifyMethods)
                    _buildMethod(context, '${method.emoji} ${method.title}',
                        method.description),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: context.gc.info.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      content.purifyFrequency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Como manter
            ExpansionMagicalCard(
              title: content.maintainTitle,
              emoji: '🧹',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final item in content.maintainItems)
                    _buildMaintenance(context, item.title, item.description),
                ],
              ),
            ),

            // Como utilizar
            ExpansionMagicalCard(
              title: content.usageTitle,
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  for (final item in content.usageItems)
                    _buildUsage(context, item.title, item.description),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gc.mint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: context.gc.mint.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.routineTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: context.gc.mint),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          content.routineBody,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Considerações finais
            ExpansionMagicalCard(
              title: content.finalTitle,
              emoji: '🌟',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    content.finalBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '✨🕯️🌙',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassoAPasso(BuildContext context, AltarContent content) {
    return MagicalCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.beginnerTitle,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.gc.lilac,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.beginnerSubtitle,
                      style: TextStyle(
                        color: context.gc.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: context.gc.lilac),
          const SizedBox(height: 16),

          // Introdução
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.gc.lilac.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
            ),
            child: Text(
              content.beginnerIntro,
              style: TextStyle(
                color: context.gc.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Passos numerados
          for (var i = 0; i < content.beginnerSteps.length; i++)
            _buildPassoNumerado(
              context,
              '${i + 1}',
              content.beginnerSteps[i].title,
              content.beginnerSteps[i].description,
              content.beginnerSteps[i].tip,
            ),

          const SizedBox(height: 20),

          // O que fazer no altar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.gc.mint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.gc.mint.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.firstTimesTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.gc.mint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in content.firstTimesItems)
                  _buildListaSimples(context, item),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // O que falar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.gc.starYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.gc.starYellow.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.speakTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.gc.starYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final example in content.speakExamples)
                  _buildExemploFala(context, example.label, example.phrase),
                const SizedBox(height: 8),
                Text(
                  content.speakNote,
                  style: TextStyle(
                    color: context.gc.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dúvidas comuns
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.gc.pink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.gc.pink.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.faqTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.gc.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final faq in content.faqs)
                  _buildDuvida(context, faq.question, faq.answer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassoNumerado(
      BuildContext context, String numero, String titulo, String descricao, String dica) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.gc.lilac.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: context.gc.lilac),
            ),
            child: Center(
              child: Text(
                numero,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(
                    color: context.gc.textSecondary,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 ', style: TextStyle(color: context.gc.starYellow)),
                    Expanded(
                      child: Text(
                        dica,
                        style: TextStyle(
                          color: context.gc.starYellow,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaSimples(BuildContext context, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: TextStyle(
          color: context.gc.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildExemploFala(BuildContext context, String titulo, String fala) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: context.gc.starYellow,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.gc.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              fala,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuvida(BuildContext context, String pergunta, String resposta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pergunta,
            style: TextStyle(
              color: context.gc.pink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            resposta,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String emoji, String title,
      String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel, color: context.gc.alert, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethod(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenance(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: context.gc.mint, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsage(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: context.gc.starYellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
