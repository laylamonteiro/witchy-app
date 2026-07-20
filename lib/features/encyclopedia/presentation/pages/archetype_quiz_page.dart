import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/archetypes_data.dart';
import '../../data/models/arcane_entry_model.dart';
import 'arcane_detail_page.dart';

/// Pergunta do teste: cada opção pontua para um arquétipo da Enciclopédia.
class _QuizOption {
  final String text;
  final String archetype; // deve casar com ArcaneEntry.name

  const _QuizOption(this.text, this.archetype);
}

class _Question {
  final String text;
  final List<_QuizOption> options;

  const _Question(this.text, this.options);
}

const List<_Question> _questions = [
  _Question('Num dia difícil, o que mais te restaura?', [
    _QuizOption('Ficar em silêncio comigo mesma, longe de todos', 'A Sábia'),
    _QuizOption('Preparar um chá, um banho, cuidar do corpo', 'A Curandeira'),
    _QuizOption('Sair para a natureza, caminhar sem rumo', 'A Caçadora'),
    _QuizOption('Organizar minha casa e meus planos', 'A Guardiã'),
    _QuizOption('Criar algo novo: cozinhar, desenhar, inventar', 'A Alquimista'),
    _QuizOption('Colocar uma música e dançar como ninguém está vendo', 'A Donzela'),
  ]),
  _Question('Qual destes presentes te encantaria mais?', [
    _QuizOption('Um baralho de tarot antigo', 'A Vidente'),
    _QuizOption('Um caderno em branco encadernado à mão', 'A Tecelã'),
    _QuizOption('Um kit de ervas e óleos essenciais', 'A Curandeira'),
    _QuizOption('Um livro raro de mistérios', 'A Alquimista'),
    _QuizOption('Uma capa preta que arrasta no chão', 'A Bruxa'),
    _QuizOption('Um álbum de fotografias antigas da família', 'A Mãe'),
  ]),
  _Question('Como você reage quando alguém que ama é ameaçado?', [
    _QuizOption('Viro uma muralha: ninguém passa por mim', 'A Guardiã'),
    _QuizOption('Acolho e cuido das feridas primeiro', 'A Mãe'),
    _QuizOption('Enfrento de frente, sem hesitar', 'A Caçadora'),
    _QuizOption('Percebo a ameaça antes de todo mundo', 'A Vidente'),
    _QuizOption('Encaro o agressor com uma verdade que ninguém disse', 'A Rainha Sombria'),
    _QuizOption('Amarro as pontas: descubro quem, como e por quê', 'A Tecelã'),
  ]),
  _Question('O que mais te atrai no caminho da bruxaria?', [
    _QuizOption('A liberdade de ser quem eu sou', 'A Bruxa'),
    _QuizOption('Transformar dor em sabedoria', 'A Alquimista'),
    _QuizOption('Os sonhos, sinais e presságios', 'A Vidente'),
    _QuizOption('Os ciclos, padrões e conexões de tudo', 'A Tecelã'),
    _QuizOption('O poder de curar a mim e aos meus', 'A Curandeira'),
    _QuizOption('Proteger quem amo com algo maior que eu', 'A Guardiã'),
  ]),
  _Question('Qual frase soa mais como você?', [
    _QuizOption('"Eu começo de novo quantas vezes precisar"', 'A Donzela'),
    _QuizOption('"Eu faço crescer tudo o que toco"', 'A Mãe'),
    _QuizOption('"Eu não devo satisfações a ninguém"', 'A Bruxa'),
    _QuizOption('"Eu já vi essa história antes"', 'A Sábia'),
    _QuizOption('"Eu vou aonde ninguém teve coragem de ir"', 'A Caçadora'),
    _QuizOption('"Eu enxergo o que ainda não aconteceu"', 'A Vidente'),
  ]),
  _Question('Diante da própria sombra, você…', [
    _QuizOption('Desço até ela: quero conhecê-la inteira', 'A Rainha Sombria'),
    _QuizOption('Transformo: nada em mim é lixo, tudo é matéria-prima',
        'A Alquimista'),
    _QuizOption('Escuto o que ela tem a dizer, sem pressa', 'A Sábia'),
    _QuizOption('Ilumino com práticas de cura e autocompaixão',
        'A Curandeira'),
    _QuizOption('Enfrento como caça: olho nos olhos até ela recuar', 'A Caçadora'),
    _QuizOption('Rio dela: sombra também é parte da minha liberdade', 'A Bruxa'),
  ]),
  _Question('Seu lugar favorito num festival místico seria…', [
    _QuizOption('A roda de dança, no meio da alegria', 'A Donzela'),
    _QuizOption('A tenda de leituras e oráculos', 'A Vidente'),
    _QuizOption('A fogueira, contando histórias antigas', 'A Sábia'),
    _QuizOption('A barraca de artesanato: nós, fios e amuletos', 'A Tecelã'),
    _QuizOption('A cozinha comunitária, alimentando todo mundo', 'A Mãe'),
    _QuizOption('O ritual de meia-noite, longe das luzes', 'A Rainha Sombria'),
  ]),
  _Question('O que as pessoas mais buscam em você?', [
    _QuizOption('Proteção: comigo elas se sentem seguras', 'A Guardiã'),
    _QuizOption('Colo: acolhimento e incentivo', 'A Mãe'),
    _QuizOption('Coragem: eu vou na frente', 'A Caçadora'),
    _QuizOption('Verdade: falo o que ninguém ousa', 'A Rainha Sombria'),
    _QuizOption('Leveza: eu lembro a elas que recomeçar é possível', 'A Donzela'),
    _QuizOption('Transformação: saio melhor de tudo que me atravessa', 'A Alquimista'),
  ]),
];

/// Teste de Arquétipo: 8 perguntas, resultado abre o verbete da Enciclopédia.
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
  final Map<String, int> _scores = {};
  List<MapEntry<String, int>> _topThree = [];
  ArcaneEntry? _result;
  String? _savedDate;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_resultKey);
    if (name == null || !mounted) return;
    setState(() {
      _result = archetypesData.firstWhere(
        (e) => e.name == name,
        orElse: () => archetypesData.first,
      );
      _topThree = (prefs.getStringList(_topThreeKey) ?? [])
          .map((raw) {
            final parts = raw.split('|');
            return MapEntry(parts.first, int.tryParse(parts.last) ?? 0);
          })
          .toList();
      _savedDate = prefs.getString(_dateKey);
    });
  }

  Future<void> _persist(String winner) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    _savedDate = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    await prefs.setString(_resultKey, winner);
    await prefs.setStringList(
      _topThreeKey,
      [for (final e in _topThree) '${e.key}|${e.value}'],
    );
    await prefs.setString(_dateKey, _savedDate!);
  }

  void _answer(_QuizOption option) {
    _scores[option.archetype] = (_scores[option.archetype] ?? 0) + 1;

    if (_index < _questions.length - 1) {
      setState(() => _index++);
      return;
    }

    // Cada resposta soma 1 ponto ao arquétipo correspondente; vence o de
    // maior pontuação (empate: o que atingiu a pontuação primeiro).
    final winner = _scores.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    _topThree = (_scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .toList();
    _persist(winner);
    setState(() {
      _result = archetypesData.firstWhere(
        (e) => e.name == winner,
        orElse: () => archetypesData.first,
      );
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _scores.clear();
      _topThree = [];
      _result = null;
      _savedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).quizTitle),
      ),
      body: _result != null ? _buildResult(_result!) : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: context.gc.surfaceBorder,
            valueColor: AlwaysStoppedAnimation(context.gc.lilac),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).quizProgress('${_index + 1}', '${_questions.length}'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                Text(result.emoji, style: const TextStyle(fontSize: 56)),
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
                Text(
                  result.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: context.gc.lilac,
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
                        categoryTitle: 'Arquétipos',
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
          if (_topThree.length > 1)
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
                  for (final entry in _topThree)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: context.gc.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: LinearProgressIndicator(
                              value: entry.value / _questions.length,
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
