import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/data_sources/archetype_identity.dart';
import '../../data/data_sources/archetype_quiz_data.dart';
import '../../data/models/arcane_entry_model.dart';
import '../widgets/arcane_glyph.dart';
import '../widgets/archetype_constellation.dart';
import '../widgets/archetype_glyph.dart';
import 'arcane_detail_page.dart';
import '../../../../core/tools/tool_identity.dart';

/// Teste de Arquétipo: 8 perguntas, resultado abre o verbete da Enciclopédia.
///
/// As perguntas vêm de `archetype_quiz_data.dart` (ContentLocale, pt/en/es).
/// A pontuação e a persistência usam o ID do arquétipo (`archetype_identity`)
/// como chave: ele é invariante entre idiomas, como o emoji era, mas não
/// depende da fonte nem da grafia da sequência de emoji para casar com o
/// catálogo. O emoji continua no catálogo como chave do conteúdo; na tela,
/// quem aparece é o DESENHO do arquétipo (`archetype_glyph.dart`).
class ArchetypeQuizPage extends StatefulWidget {
  const ArchetypeQuizPage({super.key});

  @override
  State<ArchetypeQuizPage> createState() => _ArchetypeQuizPageState();
}

class _ArchetypeQuizPageState extends State<ArchetypeQuizPage> {
  static const _resultKey = 'archetype_result';
  static const _topThreeKey = 'archetype_top3';
  static const _dateKey = 'archetype_date';

  int _index = 0;

  /// Pontos por id de arquétipo — a mesma chave que vai para o aparelho.
  final Map<String, int> _scores = {};
  List<MapEntry<String, int>> _topThree = [];

  /// O arquétipo do resultado, guardado pelo id: o verbete é resolvido no
  /// idioma da vez a cada build, então trocar de idioma reescreve a tela sem
  /// reescrever o que está gravado.
  String? _resultId;
  String? _savedDate;

  /// A constelação e a revelação só acontecem na sessão que acabou de
  /// terminar; um resultado guardado abre direto no estado final.
  bool _justFinished = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  /// Converte as energias gravadas para os ids de hoje, descartando as que
  /// não casam com arquétipo nenhum.
  List<MapEntry<String, int>> _migrateEnergies(List<String> stored) {
    final energies = <MapEntry<String, int>>[];
    for (final raw in stored) {
      // O separador é o ÚLTIMO '|': a chave antiga era conteúdo, não um
      // número, e é ela que pode ter forma inesperada.
      final cut = raw.lastIndexOf('|');
      if (cut < 0) continue;
      final id = archetypeIdForStoredKey(raw.substring(0, cut));
      if (id == null) continue;
      energies.add(MapEntry(id, int.tryParse(raw.substring(cut + 1)) ?? 0));
    }
    return energies;
  }

  /// Lê o resultado gravado e, se ele veio numa identidade antiga (emoji, ou
  /// o nome em português antes disso), converte e regrava na de hoje — quem
  /// já fez o teste não perde o resultado. Um valor que não casa com nenhum
  /// arquétipo é ausência, não erro: a tela abre o teste em vez de mostrar
  /// um arquétipo que não foi o da pessoa.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_resultKey);
    if (stored == null) return;
    final id = archetypeIdForStoredKey(stored);
    if (id == null || archetypeForId(id) == null) return;

    final storedEnergies = prefs.getStringList(_topThreeKey) ?? const <String>[];
    final energies = _migrateEnergies(storedEnergies);
    final migrated = [for (final e in energies) '${e.key}|${e.value}'];
    // As energias só são regravadas quando TODAS foram entendidas. Uma linha
    // que não casa com arquétipo nenhum é a mesma ausência do resultado: não
    // se apaga o que não se entende — ela some da tela, continua no aparelho
    // e é convertida de novo na próxima abertura. Sem isto, a regravação
    // filtrada apagaria de vez a energia ilegível (e ainda criaria a chave
    // vazia em quem nunca teve top3).
    final rewriteEnergies = migrated.length == storedEnergies.length &&
        !_sameKeys(storedEnergies, migrated);
    if (stored != id || rewriteEnergies) {
      await _rewrite(id, rewriteEnergies ? migrated : null);
    }

    if (!mounted) return;
    setState(() {
      _resultId = id;
      _topThree = energies;
      _savedDate = prefs.getString(_dateKey);
    });
  }

  /// Regrava o resultado na identidade de hoje sem tocar na data: a pessoa
  /// fez o teste no dia em que fez, e a migração não é um teste novo.
  Future<void> _rewrite(String id, List<String>? energies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_resultKey, id);
      if (energies != null) await prefs.setStringList(_topThreeKey, energies);
    } catch (_) {
      // A regravação é oportunista: se o aparelho recusar a escrita agora, a
      // leitura converte de novo na próxima abertura.
      return;
    }
  }

  /// Grava o resultado e devolve a data gravada, ou null se a gravação
  /// falhou — a tela só mostra a data que existe de verdade no aparelho.
  Future<String?> _persist(String winnerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/${now.year}';
      await prefs.setString(_resultKey, winnerId);
      await prefs.setStringList(
        _topThreeKey,
        [for (final e in _topThree) '${e.key}|${e.value}'],
      );
      await prefs.setString(_dateKey, date);
      return date;
    } catch (_) {
      return null;
    }
  }

  Future<void> _answer(ArchetypeQuizOption option) async {
    // O conteúdo aponta a opção para o arquétipo pelo emoji; o ponto vai
    // para o id, que é o que será gravado. Uma opção sem arquétipo
    // correspondente (impossível pela paridade de conteúdo, testada) deixa
    // de pontuar em vez de virar chave inválida no aparelho.
    final id = archetypeIdForEmoji(option.archetypeEmoji);
    if (id != null) _scores[id] = (_scores[id] ?? 0) + 1;

    if (_index < archetypeQuizQuestions.length - 1) {
      setState(() => _index++);
      return;
    }
    if (_scores.isEmpty) return;

    // Cada resposta soma 1 ponto ao arquétipo correspondente; vence o de
    // maior pontuação (empate: o que atingiu a pontuação primeiro). A
    // contagem é a de sempre: a constelação apenas desenha o que ela deu.
    final winner = _scores.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    _topThree = (_scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .toList();
    // Guardar primeiro, revelar depois: o resultado que aparece é o que
    // ficou no aparelho. O teste tem progresso próprio e não entra no XP.
    final date = await _persist(winner);
    if (!mounted) return;
    setState(() {
      _savedDate = date;
      _justFinished = true;
      _resultId = winner;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _scores.clear();
      _topThree = [];
      _resultId = null;
      _savedDate = null;
      _justFinished = false;
    });
  }

  /// Duas listas de chaves iguais item a item — evita regravar o que já está
  /// na identidade de hoje.
  static bool _sameKeys(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // O verbete é resolvido aqui, e não guardado no estado, para acompanhar
    // o idioma atual: o que está gravado é o id.
    final result = _resultId == null ? null : archetypeForId(_resultId!);
    return Scaffold(
      appBar: AppBar(
        title: ToolHeading(tool: ToolId.archetypes,
            title: AppLocalizations.of(context).quizTitle),
      ),
      body: result != null ? _buildResult(result) : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final questions = archetypeQuizQuestions;
    final question = questions[_index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / questions.length,
            backgroundColor: context.gc.surfaceBorder,
            valueColor: AlwaysStoppedAnimation(context.gc.lilac),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)
                .quizProgress('${_index + 1}', '${questions.length}'),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(
            question.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.gc.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          for (final option in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _answer(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.gc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.gc.surfaceBorder),
                  ),
                  child: Text(
                    option.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(ArcaneEntry result) {
    // As energias mais fortes já resolvidas no idioma atual; um id sem
    // arquétipo correspondente não vira linha em branco, simplesmente não
    // entra na lista.
    final energies = <MapEntry<ArcaneEntry, int>>[];
    for (final entry in _topThree) {
      final archetype = archetypeForId(entry.key);
      if (archetype != null) energies.add(MapEntry(archetype, entry.value));
    }

    // O prêmio, num widget só: os dois ramos abaixo (com constelação e sem)
    // mostram exatamente o mesmo desenho, no mesmo tamanho. Quando eram duas
    // cópias, era de dois lugares que o prêmio podia divergir.
    //
    // A caixa é a que faz o desenho ter o porte do emoji de 56 que estava
    // aqui; a constelação deixa o meio livre e a estrela mais próxima fica a
    // uns 62 pixels do centro (0,70 × 0,44 × 200), então os 83 de caixa —
    // 41 e meio de cada lado — não encostam nela nem no brilho dela.
    final prize = _Reveal(
      play: _justFinished,
      child: ArcaneGlyph(
        category: ArcaneCategory.archetypes,
        entry: result,
        size: ArchetypeGlyphArt.boxForEmojiSize(56),
        emojiStyle: const TextStyle(fontSize: 56),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                // A constelação da sessão: uma estrela por arquétipo tocado
                // pelas respostas, ligadas na ordem do céu. Sem sorteio: as
                // mesmas respostas dão sempre a mesma figura.
                // A constelação envolve o arquétipo: as estrelas da sessão
                // ficam em volta dele, não empilhadas por cima.
                if (_scores.isNotEmpty)
                  Semantics(
                    label: AppLocalizations.of(context).quizConstellationLabel,
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: ArchetypeConstellation(
                              scores: Map<String, int>.from(_scores),
                              order: archetypeIds,
                              winner: _resultId ?? '',
                              animate: _justFinished,
                              height: 200,
                            ),
                          ),
                          prize,
                        ],
                      ),
                    ),
                  )
                else
                  prize,
                const SizedBox(height: 12),
                if (_savedDate != null) ...[
                  Text(
                    AppLocalizations.of(context).quizSavedOn(_savedDate!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  AppLocalizations.of(context).quizYourArchetypeIs,
                  style: TextStyle(color: context.gc.textSecondary),
                ),
                const SizedBox(height: 4),
                _Reveal(
                  play: _justFinished,
                  delay: GrimoireMotion.state,
                  child: Text(
                    result.name,
                    key: const ValueKey('quiz-result-name'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.summary,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArcaneDetailPage(
                        entry: result,
                        category: ArcaneCategory.archetypes,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: Text(AppLocalizations.of(context).quizSeeInEncyclopedia),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(AppLocalizations.of(context).quizRetake),
                ),
              ],
            ),
          ),
          if (energies.length > 1)
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).quizStrongestEnergies,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  for (final entry in energies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key.name,
                              style: TextStyle(
                                color: context.gc.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: LinearProgressIndicator(
                              value: entry.value /
                                  archetypeQuizQuestions.length,
                              backgroundColor: context.gc.surfaceBorder,
                              valueColor: AlwaysStoppedAnimation(
                                  context.gc.lilac),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: context.gc.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          MagicalCard(
            child: Text(
              AppLocalizations.of(context).quizMirrorNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A revelação do arquétipo: sobe e assenta uma vez, quando o teste acaba
/// de terminar. Um resultado guardado — e o movimento reduzido — abre
/// direto no estado final, que é o mesmo.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.play, required this.child, this.delay = Duration.zero});

  final bool play;
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (!play || GrimoireMotion.reduced(context)) return child;
    final total = GrimoireMotion.celebration + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Curves.linear,
      builder: (context, raw, inner) {
        final t = Interval(start, 1, curve: GrimoireMotion.enter).transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: inner),
        );
      },
      child: child,
    );
  }
}
