import '../../lunar/presentation/providers/lunar_provider.dart';
import 'lunar_comparison.dart';
import 'menstrual_day.dart';
import 'menstrual_reading_scope.dart';

/// O quanto da fonte íntima cada seção da leitura pode receber.
enum MenstrualProjection {
  /// Nada. É o padrão de qualquer chave que este arquivo não conheça.
  none,

  /// Só os temas que ela escolheu — a estação, e mais nada. Sem datas, sem
  /// sintomas, sem as palavras dela.
  themes,

  /// As datas observadas e o contexto lunar calculado para elas.
  dates,

  /// O que ela marcou naqueles dias: marca, intensidade, sintomas, humor e
  /// a estação escolhida, conforme os campos autorizados.
  observations,

  /// As observações e, quando ela autorizou esses campos, as palavras que
  /// escreveu.
  full,
}

/// Que seção recebe o quê.
///
/// A lista é fechada de propósito: uma chave nova, desconhecida deste
/// arquivo, NÃO recebe dado menstrual por fallback. Acrescentar uma seção à
/// fonte íntima é uma decisão, não um efeito colateral.
abstract final class MenstrualSectionAccess {
  static const allowed = <String, MenstrualProjection>{
    // O retrato do período conta o que ela registrou sobre o próprio corpo,
    // com atribuição explícita.
    'portrait': MenstrualProjection.full,
    // Os fios ligam observações datadas a temas do diário e da prática.
    'threads': MenstrualProjection.full,
    // O céu cruza datas com a Lua calculada — e nada além disso.
    'sky': MenstrualProjection.dates,
    // A prática contextualiza pausas relatadas; não soma constância nem XP.
    'practice': MenstrualProjection.observations,
    // As três áreas só usam o que os relatos daquela área sustentarem.
    'love': MenstrualProjection.observations,
    'work': MenstrualProjection.observations,
    'family': MenstrualProjection.observations,
    // O que se anuncia respeita preferências de cuidado declaradas, sem
    // prever menstruação, ovulação ou sintoma.
    'forecast': MenstrualProjection.themes,
    // Rituais e afirmação recebem só temas, nunca datas ou sintomas.
    'rituals': MenstrualProjection.themes,
    'affirmation': MenstrualProjection.themes,
    'seal': MenstrualProjection.themes,
  };

  static MenstrualProjection of(String section) =>
      allowed[section] ?? MenstrualProjection.none;
}

/// O material autorizado desta geração, já recortado pelo escopo.
///
/// Nada aqui consulta o histórico por fora da janela, e nada aqui infere:
/// campo ausente aparece como ausente, dado observado aparece como
/// observado, e a estação aparece como escolha dela. Um dia sem sintoma
/// registrado não vira "sem sintomas".
class MenstrualReadingContext {
  const MenstrualReadingContext({required this.scope, required this.days});

  /// Monta o contexto a partir do que existe no aparelho, deixando de fora
  /// tudo o que o escopo não autoriza — inclusive um dia que mudou depois.
  factory MenstrualReadingContext.of(
    MenstrualReadingScope scope,
    Iterable<MenstrualDay> days,
  ) =>
      MenstrualReadingContext(scope: scope, days: scope.select(days));

  final MenstrualReadingScope scope;
  final List<MenstrualDay> days;

  bool get isEmpty => days.isEmpty;

  /// Todos os dias autorizados continuam existindo como ela os deixou?
  /// Um registro corrigido ou apagado derruba a geração que dependia dele.
  bool isIntactFor(Iterable<MenstrualDay> current) =>
      MenstrualReadingContext.of(scope, current).days.length ==
      scope.recordCount;

  /// O bloco que uma seção recebe, ou nada quando ela não recebe fonte
  /// íntima. O marcador `source` existe para o texto poder atribuir: isto é
  /// o que ela registrou, não uma conclusão do app.
  Map<String, dynamic>? projectionFor(String section) {
    final projection = MenstrualSectionAccess.of(section);
    if (projection == MenstrualProjection.none || isEmpty) return null;
    return switch (projection) {
      MenstrualProjection.none => null,
      MenstrualProjection.themes => {
          'source': 'menstrual_authorized',
          'chosen_seasons': _seasons,
        },
      MenstrualProjection.dates => {
          'source': 'menstrual_authorized',
          'days': [
            for (final day in days)
              {
                'date': day.dayKey,
                'moon_estimated': _moonOf(day.day),
              },
          ],
        },
      MenstrualProjection.observations => {
          'source': 'menstrual_authorized',
          'days': [for (final day in days) _dayOf(day, withWords: false)],
        },
      MenstrualProjection.full => {
          'source': 'menstrual_authorized',
          'days': [for (final day in days) _dayOf(day, withWords: true)],
        },
    };
  }

  /// A cobertura da fonte, em bloco próprio. Serve para dizer o alcance do
  /// que foi incluído — nunca para virar atividade, constância ou nota.
  Map<String, dynamic> get coverage => {
        'authorized_days': days.length,
        'window': {
          'start': scope.start == null ? null : MenstrualDay.keyOf(scope.start!),
          'end': scope.end == null ? null : MenstrualDay.keyOf(scope.end!),
        },
        'fields': [
          for (final field in MenstrualField.values)
            if (scope.fields.contains(field)) field.name,
        ],
        'includes_written_words': scope.includesWrittenWords,
        'scope': scope.fingerprint,
      };

  List<String> get _seasons => [
        for (final day in days)
          if (day.season != null &&
              scope.fields.contains(MenstrualField.season))
            day.season!.name,
      ].toSet().toList()
        ..sort();

  static String _moonOf(DateTime day) =>
      LunarProvider.phaseOn(LunarComparison.noonOf(day)).name;

  /// Um dia como ele foi registrado: o que ela observou, o que ela escolheu,
  /// e a lista do que simplesmente não foi registrado.
  Map<String, dynamic> _dayOf(MenstrualDay day, {required bool withWords}) {
    final observed = <String, dynamic>{};
    final chosen = <String, dynamic>{};
    final absent = <String>[];

    void take(MenstrualField field, Object? value, Map<String, dynamic> into) {
      if (!scope.fields.contains(field)) return;
      if (value == null || (value is List && value.isEmpty)) {
        absent.add(field.name);
        return;
      }
      into[field.name] = value;
    }

    take(MenstrualField.mark, day.mark.name, observed);
    take(MenstrualField.flow, day.flow?.name, observed);
    take(MenstrualField.symptoms, day.symptoms, observed);
    take(MenstrualField.mood, day.mood, observed);
    take(MenstrualField.season, day.season?.name, chosen);
    if (withWords) {
      take(MenstrualField.note, day.note.isEmpty ? null : day.note, observed);
      take(MenstrualField.seasonNote,
          day.seasonNote.isEmpty ? null : day.seasonNote, chosen);
    }

    return {
      'date': day.dayKey,
      'observed': observed,
      if (chosen.isNotEmpty) 'chosen_by_her': chosen,
      // Ausente é ausente: nunca "sem sintomas".
      if (absent.isNotEmpty) 'not_recorded': absent,
      'moon_estimated': _moonOf(day.day),
    };
  }
}
