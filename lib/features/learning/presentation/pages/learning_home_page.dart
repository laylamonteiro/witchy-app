import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/trails_data.dart';
import '../providers/learning_provider.dart';
import '../widgets/bound_book_cover.dart';
import 'trail_page.dart';
import '../../../../core/tools/tool_identity.dart';

/// Grimório Vivo: trilhas de aprendizado em que cada lição termina com uma
/// página real escrita no Meu Grimório.
class LearningHomePage extends StatefulWidget {
  const LearningHomePage({super.key});

  @override
  State<LearningHomePage> createState() => _LearningHomePageState();
}

class _LearningHomePageState extends State<LearningHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ToolHeading(tool: ToolId.livingGrimoire,
            title: AppLocalizations.of(context).toolLivingGrimoireTitle),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, learning, _) {
          return SingleChildScrollView(
            // A margem lateral é do MagicalCard; aqui só o respiro de cima e
            // de baixo, o mesmo das outras onze.
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MagicalCard(
                  child: Column(
                    children: [
                      // O emblema da entrada continua na cena, no mesmo porte
                      // de abertura das irmãs (48) e normalizado num quadrado
                      // — como Text, o emoji crescia com a fonte do sistema.
                      const ToolEmblem(
                          tool: ToolId.livingGrimoire, size: 48, flies: false),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context).learnHomeTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: context.gc.lilac),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).learnHomeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.textSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 14),
                      // Nível e XP — a gamificação das Jornadas Mágicas
                      // aplicada ao aprendizado.
                      Row(
                        children: [
                          Text(learning.level.emoji,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  learning.level.title,
                                  style: TextStyle(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: learning.levelProgress,
                                  backgroundColor: context.gc.surfaceBorder,
                                  valueColor: AlwaysStoppedAnimation(
                                      context.gc.starYellow),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${learning.xp} XP',
                            style: TextStyle(
                              color: context.gc.starYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        learning.nextLevel == null
                            ? AppLocalizations.of(context).learnMaxTitle
                            : AppLocalizations.of(context).learnNextTitle('${learning.totalPagesWritten}', learning.nextLevel!.title, '${learning.nextLevel!.minXp}'),
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estante: os volumes já encadernados, derivados do
                // progresso existente. Só aparece quando há algum.
                if (learningTrails.any(learning.isTrailComplete))
                  _buildShelf(context, learning),
                for (final trail in learningTrails)
                  _buildTrailCard(context, learning, trail),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailCard(
      BuildContext context, LearningProvider learning, trail) {
    final done = learning.completedInTrail(trail);
    final total = trail.lessons.length;
    final complete = learning.isTrailComplete(trail);

    void abrir() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrailPage(trail: trail)),
        );
    // O toque é do próprio cartão, como no hub das Ferramentas: com um
    // InkWell POR FORA, o Ink opaco cobria o brilho do toque e o encolhimento
    // de resposta nunca disparava.
    if (complete) return _buildBoundCover(context, trail, abrir);
    return MagicalCard(
      onTap: abrir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(trail.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      trail.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // A mesma seta de 'isto abre' do hub.
              Icon(Icons.arrow_forward_ios, color: context.gc.lilac, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  backgroundColor: context.gc.surfaceBorder,
                  valueColor: AlwaysStoppedAnimation(context.gc.lilac),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              // A trilha completa sai daqui pela capa encadernada; este é
              // sempre o contador de páginas de uma trilha em andamento.
              Text(
                AppLocalizations.of(context)
                    .learnPagesProgress('$done', '$total'),
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Capa de livro encadernado: a trilha completa vira um volume do grimório.
  Widget _buildShelf(BuildContext context, LearningProvider learning) {
    final bound = learningTrails.where(learning.isTrailComplete).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A mesma etiqueta de seção do hub das Ferramentas (caixa alta,
          // bodySmall, 1.2 de entreletras, cinza): é o mesmo papel — o rótulo
          // que agrupa blocos — e ela vê os dois em sequência ao abrir a
          // primeira ferramenta da lista. O dourado ficou para o que é
          // encadernado de verdade, logo abaixo.
          Text(
            AppLocalizations.of(context)
                .learnShelfTitle(bound.length)
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            key: const ValueKey('learn-shelf'),
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final trail in bound)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      // A estante só tem volumes encadernados, e a capa
                      // fechada diz isso a quem vê. Quem ouve a tela recebia
                      // só o nome da trilha, igual ao da lista de baixo.
                      label: '${trail.title} — '
                          '${AppLocalizations.of(context).learnBoundShort}',
                      button: true,
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => TrailPage(trail: trail)),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: BoundBookCover(
                            trailId: trail.id, emblem: trail.emoji, width: 64),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoundCover(BuildContext context, trail, VoidCallback onTap) {
    final radius = BorderRadius.circular(16);
    // A mesma montagem do MagicalCard: a sombra fica FORA do Material (dentro
    // do Ink ela seria recortada) e o gradiente é pintado pelo Ink, para o
    // brilho do toque aparecer POR CIMA dele. Com o InkWell por fora, a capa
    // era o único cartão da tela que não respondia ao dedo.
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.gc.starYellow.withValues(alpha: 0.18),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(context.gc.surface, context.gc.starYellow, 0.10)!,
                Color.lerp(context.gc.surface, context.gc.lilac, 0.16)!,
              ],
            ),
            border: Border.all(color: context.gc.starYellow, width: 1.6),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: context.gc.lilac.withValues(alpha: 0.12),
            highlightColor: context.gc.lilac.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // O mesmo livro fechado da cena de encadernação, em
                  // miniatura.
                  BoundBookCover(
                      trailId: trail.id, emblem: trail.emoji, width: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trail.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: context.gc.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)
                              .learnBoundVolume('${trail.lessons.length}'),
                          style: TextStyle(
                            color: context.gc.starYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // A mesma seta de 'isto abre' das outras trilhas — mesmo
                  // glifo, mesmo tamanho e o MESMO lilás. O dourado é a
                  // identidade do volume encadernado (a borda, a sombra, a
                  // contagem de páginas); a seta não é identidade, é o sinal
                  // de navegação que as doze entradas repetem, e tingi-la de
                  // dourado aqui faria a única exceção da jornada.
                  Icon(Icons.arrow_forward_ios,
                      color: context.gc.lilac, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
