import 'menstrual_day.dart';

/// Os campos de um registro que podem, ou não, acompanhar a leitura.
///
/// A nota livre e a escrita da estação têm chave própria na tela: são as
/// palavras dela, e precisam poder sair sozinhas, sem levar junto o resto
/// do período.
enum MenstrualField { mark, flow, symptoms, mood, note, season, seasonNote }

/// Um registro autorizado, com a revisão que ela viu ao autorizar.
///
/// A revisão é o que permite descobrir que o dia mudou depois: corrigir ou
/// apagar um registro invalida a geração que dependia dele.
class MenstrualScopeEntry implements Comparable<MenstrualScopeEntry> {
  const MenstrualScopeEntry({required this.dayKey, required this.revision});

  factory MenstrualScopeEntry.of(MenstrualDay day) =>
      MenstrualScopeEntry(dayKey: day.dayKey, revision: day.revision);

  final String dayKey;
  final int revision;

  @override
  int compareTo(MenstrualScopeEntry other) => dayKey.compareTo(other.dayKey);

  @override
  bool operator ==(Object other) =>
      other is MenstrualScopeEntry &&
      other.dayKey == dayKey &&
      other.revision == revision;

  @override
  int get hashCode => Object.hash(dayKey, revision);

  @override
  String toString() => '$dayKey:$revision';
}

/// O escopo que ela autorizou para UMA geração de leitura.
///
/// O que este objeto guarda é um contrato, e ele vale só para aquela
/// geração e para as tentativas compatíveis dela:
///
/// * a janela é a mesma da leitura, `[start, end)`, em datas civis. Um
///   registro retroativo entra pela data observada, nunca pela data em que
///   foi digitado;
/// * os registros autorizados vêm listados um a um, com a revisão que ela
///   viu — nada de "tudo o que houver", e nada de dados futuros: autorizar
///   hoje não autoriza o que for escrito amanhã;
/// * os campos são explícitos: o escopo diz quais vão, um a um, e a nota
///   livre e a escrita da estação podem sair sem que os dias saiam;
/// * a revisão do consentimento entra no contrato: retirar o sim invalida o
///   escopo mesmo que os registros não mudem.
///
/// O [fingerprint] é derivado desse contrato inteiro. Ele existe para
/// perceber mudança — não é assinatura nem segredo — e é estável entre
/// execuções, porque não depende de `hashCode`.
class MenstrualReadingScope {
  const MenstrualReadingScope({
    required this.userId,
    required this.start,
    required this.end,
    required this.entries,
    this.fields = defaultFields,
    this.consentRevision = 1,
    this.contentVersion = 1,
  });

  /// Um escopo vazio: a fonte existe na tela, mas nada foi autorizado.
  const MenstrualReadingScope.none({required this.userId})
      : start = null,
        end = null,
        entries = const [],
        fields = defaultFields,
        consentRevision = 0,
        contentVersion = 1;

  final String userId;

  /// A janela da leitura, `[start, end)`. Nula num escopo vazio.
  final DateTime? start;
  final DateTime? end;

  final List<MenstrualScopeEntry> entries;
  final Set<MenstrualField> fields;
  final int consentRevision;

  /// Versão do contrato. Muda quando a forma do material mudar, para que uma
  /// geração antiga não seja retomada com regras novas.
  final int contentVersion;

  /// O conjunto base: o que ela marcou nos dias. As palavras que escreveu
  /// (nota do dia e nota da estação) entram por uma chave própria na tela,
  /// para poderem sair sozinhas sem levar o resto do período junto.
  static const defaultFields = {
    MenstrualField.mark,
    MenstrualField.flow,
    MenstrualField.symptoms,
    MenstrualField.mood,
    MenstrualField.season,
  };

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
  int get recordCount => entries.length;

  bool get includesWrittenWords =>
      fields.contains(MenstrualField.note) ||
      fields.contains(MenstrualField.seasonNote);

  /// O dia está autorizado, na revisão em que ela o viu?
  bool covers(MenstrualDay day) =>
      entries.contains(MenstrualScopeEntry.of(day));

  /// Só os dias autorizados, na revisão autorizada, e dentro da janela.
  /// Um dia corrigido depois da autorização não passa por aqui.
  List<MenstrualDay> select(Iterable<MenstrualDay> days) =>
      [for (final day in days) if (covers(day) && withinWindow(day.day)) day]
        ..sort((a, b) => a.day.compareTo(b.day));

  bool withinWindow(DateTime day) {
    final from = start;
    final to = end;
    if (from == null || to == null) return false;
    final at = DateTime(day.year, day.month, day.day);
    return !at.isBefore(DateTime(from.year, from.month, from.day)) &&
        at.isBefore(DateTime(to.year, to.month, to.day));
  }

  /// Duas autorizações compatíveis: a mesma pessoa, a mesma janela, os
  /// mesmos registros nas mesmas revisões, os mesmos campos e o mesmo
  /// consentimento. É o que decide se uma tentativa pode reaproveitar
  /// capítulos já prontos.
  bool matches(MenstrualReadingScope? other) =>
      other != null && other.fingerprint == fingerprint;

  /// A forma canônica do contrato — a mesma em qualquer aparelho, hoje e
  /// amanhã.
  String get canonical {
    final ordered = [...entries]..sort();
    final chosen = [
      for (final field in MenstrualField.values)
        if (fields.contains(field)) field.name,
    ];
    return [
      'v$contentVersion',
      userId,
      start == null ? '-' : MenstrualDay.keyOf(start!),
      end == null ? '-' : MenstrualDay.keyOf(end!),
      chosen.join(','),
      ordered.join(','),
      'c$consentRevision',
    ].join('|');
  }

  String get fingerprint => _digest(canonical);

  /// Um detector de mudança, não um resumo criptográfico: djb2 com módulo,
  /// escolhido por ser exato tanto no aparelho quanto na web, e por não
  /// depender de `String.hashCode`, que pode mudar entre versões.
  static String _digest(String canonical) {
    var hash = 5381;
    for (final unit in canonical.codeUnits) {
      hash = (hash * 33 + unit) % 0x7FFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  MenstrualReadingScope copyWith({
    List<MenstrualScopeEntry>? entries,
    Set<MenstrualField>? fields,
    int? consentRevision,
  }) =>
      MenstrualReadingScope(
        userId: userId,
        start: start,
        end: end,
        entries: entries ?? this.entries,
        fields: fields ?? this.fields,
        consentRevision: consentRevision ?? this.consentRevision,
        contentVersion: contentVersion,
      );
}
