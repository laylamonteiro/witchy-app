import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/numerology_meanings_data.dart';
import '../../domain/numerology_calculator.dart';
import 'numerology_profile_page.dart';

/// Hub de Numerologia: perfil pessoal, consulta de número,
/// horas espelho e sequências repetidas.
class NumerologyPage extends StatelessWidget {
  const NumerologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Numerologia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('🔢', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 12),
                  Text(
                    'A Magia dos Números',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: context.gc.lilac),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore os números que vibram na sua vida: seu perfil '
                    'de nascimento, o significado de qualquer número, as '
                    'horas espelho e as sequências que insistem em aparecer.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _buildModeCard(
              context,
              emoji: '🌟',
              title: 'Perfil Pessoal',
              description:
                  'Seus 5 números-chave a partir do nome e da data de nascimento',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NumerologyProfilePage(),
                ),
              ),
            ),
            _buildModeCard(
              context,
              emoji: '🔍',
              title: 'Consultar um Número',
              description: 'Um número te acompanha? Descubra o que ele vibra',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NumberLookupPage(),
                ),
              ),
            ),
            _buildModeCard(
              context,
              emoji: '🕰️',
              title: 'Horas Espelho',
              description: 'O recado das horas duplas: 11:11, 22:22 e além',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MirrorHoursPage(),
                ),
              ),
            ),
            _buildModeCard(
              context,
              emoji: '🌀',
              title: 'Sequências Repetidas',
              description: 'O significado de padrões como 333, 1010 e 1234',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RepeatedSequencesPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: MagicalCard(
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.gc.lilac),
          ],
        ),
      ),
    );
  }
}

/// Card padrão com o significado de um número.
class NumberMeaningCard extends StatelessWidget {
  final int number;
  final String? contextLine;

  const NumberMeaningCard({
    super.key,
    required this.number,
    this.contextLine,
  });

  @override
  Widget build(BuildContext context) {
    final meaning = numberMeanings[number];
    if (meaning == null) return const SizedBox.shrink();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.gc.lilac.withOpacity(0.15),
                  border: Border.all(color: context.gc.lilac),
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: context.gc.lilac,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meaning.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.gc.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (contextLine != null)
                      Text(
                        contextLine!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.gc.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meaning.keywords
                .map(
                  (k) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.gc.lilac.withOpacity(0.12),
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        color: context.gc.lilac,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            meaning.description,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            meaning.shadow,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

/// Consulta avulsa: digite um número e veja sua vibração.
class NumberLookupPage extends StatefulWidget {
  const NumberLookupPage({super.key});

  @override
  State<NumberLookupPage> createState() => _NumberLookupPageState();
}

class _NumberLookupPageState extends State<NumberLookupPage> {
  final _controller = TextEditingController();
  int? _result;
  int? _original;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0) return;
    setState(() {
      _original = value;
      _result = NumerologyCalculator.reduceAny(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Consultar um Número'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Que número te acompanha?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Placas, datas, portas, recibos… digite o número e veja '
                    'sua essência numerológica.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(hintText: 'Ex.: 713'),
                          onSubmitted: (_) => _lookup(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _lookup,
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              if (_original != _result)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$_original reduz para $_result',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.gc.textSecondary),
                  ),
                ),
              NumberMeaningCard(number: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horas espelho (duplas): 00:00 a 23:23.
class MirrorHoursPage extends StatelessWidget {
  const MirrorHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (h) => h);

    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Horas Espelho'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Olhou o relógio exatamente numa hora dupla? Cada espelho '
              'carrega uma vibração numérica. Toque para ver o recado.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final h = hours[index].toString().padLeft(2, '0');
              final label = '$h:$h';
              final digitSum = h.codeUnits
                      .map((c) => c - 48)
                      .fold<int>(0, (a, b) => a + b) *
                  2;
              final number = NumerologyCalculator.reduceAny(digitSum);
              return Material(
                color: context.gc.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => _MirrorHourSheet(
                      label: label,
                      number: number,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.gc.surfaceBorder),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MirrorHourSheet extends StatelessWidget {
  final String label;
  final int number;

  const _MirrorHourSheet({required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.gc.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.gc.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            '🕰️ $label',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.gc.lilac,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vibração do número $number',
            style: TextStyle(color: context.gc.textSecondary),
          ),
          NumberMeaningCard(
            number: number,
            contextLine: 'Recado do espelho $label',
          ),
        ],
      ),
    );
  }
}

/// Sequências repetidas: 111, 333, 1010, 1234…
class RepeatedSequencesPage extends StatelessWidget {
  const RepeatedSequencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = repeatedSequenceMessages.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Sequências Repetidas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'Aquele número que aparece em todo lugar pode ser um padrão '
                'pedindo atenção. Os clássicos:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.gc.textSecondary,
                    ),
              ),
            );
          }
          final entry = entries[index - 1];
          final digits = entry.key.codeUnits.map((c) => c - 48);
          final number = NumerologyCalculator.reduceAny(
            digits.fold<int>(0, (a, b) => a + b),
          );
          return MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.gc.lilac,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: context.gc.lilac.withOpacity(0.12),
                      ),
                      child: Text(
                        'vibra no $number',
                        style:
                            TextStyle(color: context.gc.lilac, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
