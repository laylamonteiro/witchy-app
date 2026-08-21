import 'cycle_time.dart';
import 'era_ruler.dart';

/// Uma Fase — o subperíodo dentro de uma Era, regido por outro astro.
///
/// (Termo técnico correspondente: antardasha. Nunca exibido.)
class Fase {
  const Fase({
    required this.regente,
    required this.regenteDaEra,
    required this.inicio,
    required this.fim,
  });

  /// O astro que rege esta Fase.
  final EraRegente regente;

  /// O astro que rege a Era em que esta Fase acontece.
  final EraRegente regenteDaEra;

  /// Sempre em UTC.
  final DateTime inicio;
  final DateTime fim;

  Duration get duracao => fim.difference(inicio);

  double get duracaoEmAnos => duracaoParaAnos(duracao);

  bool contem(DateTime quando) =>
      !quando.isBefore(inicio) && quando.isBefore(fim);

  /// Posição de [quando] dentro da Fase, de 0.0 a 1.0 (clampado).
  double progresso(DateTime quando) => _progressoEntre(inicio, fim, quando);

  Map<String, dynamic> toJson() => {
        'regente': regente.name,
        'regenteDaEra': regenteDaEra.name,
        'inicio': inicio.toIso8601String(),
        'fim': fim.toIso8601String(),
      };

  factory Fase.fromJson(Map<String, dynamic> json) => Fase(
        regente: EraRegente.porNome(json['regente'] as String),
        regenteDaEra: EraRegente.porNome(json['regenteDaEra'] as String),
        inicio: DateTime.parse(json['inicio'] as String).toUtc(),
        fim: DateTime.parse(json['fim'] as String).toUtc(),
      );
}

/// Uma Era — um dos nove grandes períodos do ciclo de 120 anos.
///
/// (Termo técnico correspondente: mahadasha. Nunca exibido.)
class Era {
  const Era({
    required this.regente,
    required this.inicio,
    required this.fim,
    required this.anosCompletos,
    required this.parcial,
    required this.fases,
  });

  final EraRegente regente;

  /// Sempre em UTC.
  final DateTime inicio;
  final DateTime fim;

  /// Duração canônica da Era, em anos — mesmo quando ela entra pela metade.
  ///
  /// A primeira Era da vida quase sempre é [parcial]: a pessoa nasce no meio
  /// dela. Ainda assim é a duração COMPLETA que governa o tamanho das Fases,
  /// e é ela que a interface mostra ("Era de 16 anos").
  final double anosCompletos;

  /// Verdadeiro só para a primeira Era, que começou antes do nascimento.
  final bool parcial;

  /// As Fases desta Era, em ordem. Na Era parcial, as que terminaram antes do
  /// nascimento não entram, e a primeira que sobra vem recortada.
  final List<Fase> fases;

  Duration get duracao => fim.difference(inicio);

  /// Anos efetivamente vividos nesta Era — menor que [anosCompletos] quando
  /// ela é [parcial].
  double get anosVividos => duracaoParaAnos(duracao);

  bool contem(DateTime quando) =>
      !quando.isBefore(inicio) && quando.isBefore(fim);

  /// Posição de [quando] dentro da Era, de 0.0 a 1.0 (clampado).
  double progresso(DateTime quando) => _progressoEntre(inicio, fim, quando);

  /// A Fase vigente em [quando]. Fora do intervalo, devolve a primeira ou a
  /// última — a interface nunca fica sem Fase para mostrar.
  Fase faseEm(DateTime quando) {
    for (final fase in fases) {
      if (fase.contem(quando)) return fase;
    }
    return quando.isBefore(inicio) ? fases.first : fases.last;
  }

  Map<String, dynamic> toJson() => {
        'regente': regente.name,
        'inicio': inicio.toIso8601String(),
        'fim': fim.toIso8601String(),
        'anosCompletos': anosCompletos,
        'parcial': parcial,
        'fases': fases.map((f) => f.toJson()).toList(),
      };

  factory Era.fromJson(Map<String, dynamic> json) => Era(
        regente: EraRegente.porNome(json['regente'] as String),
        inicio: DateTime.parse(json['inicio'] as String).toUtc(),
        fim: DateTime.parse(json['fim'] as String).toUtc(),
        anosCompletos: (json['anosCompletos'] as num).toDouble(),
        parcial: json['parcial'] as bool,
        fases: (json['fases'] as List)
            .map((f) => Fase.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}

/// A linha do tempo completa: nove Eras cobrindo 120 anos a partir do
/// nascimento.
class LinhaDoTempo {
  const LinhaDoTempo({
    required this.eras,
    required this.regenteNatal,
    required this.nakshatra,
    required this.saldoInicialAnos,
    required this.nascimentoUtc,
  });

  /// As nove Eras, em ordem cronológica.
  final List<Era> eras;

  /// O astro que regia o céu no nascimento — o regente da primeira Era.
  final EraRegente regenteNatal;

  /// Setor lunar do nascimento, 0..26. Interno: nunca vai para a tela.
  final int nakshatra;

  /// Quanto sobrava da primeira Era no momento do nascimento, em anos.
  final double saldoInicialAnos;

  final DateTime nascimentoUtc;

  DateTime get inicio => eras.first.inicio;
  DateTime get fim => eras.last.fim;

  /// A Era vigente em [quando]. Fora do intervalo, devolve a primeira ou a
  /// última — assim a interface nunca fica sem Era corrente.
  Era eraEm(DateTime quando) {
    for (final era in eras) {
      if (era.contem(quando)) return era;
    }
    return quando.isBefore(inicio) ? eras.first : eras.last;
  }

  /// A Fase vigente em [quando].
  Fase faseEm(DateTime quando) => eraEm(quando).faseEm(quando);

  /// Eras já encerradas em [quando], da mais recente para a mais antiga —
  /// a ordem em que a lista "Passado" mostra.
  List<Era> passadas(DateTime quando) =>
      eras.where((e) => !e.fim.isAfter(quando)).toList().reversed.toList();

  /// Eras que ainda não começaram em [quando], em ordem cronológica.
  List<Era> futuras(DateTime quando) =>
      eras.where((e) => e.inicio.isAfter(quando)).toList();

  Map<String, dynamic> toJson() => {
        'regenteNatal': regenteNatal.name,
        'nakshatra': nakshatra,
        'saldoInicialAnos': saldoInicialAnos,
        'nascimentoUtc': nascimentoUtc.toIso8601String(),
        'eras': eras.map((e) => e.toJson()).toList(),
      };

  factory LinhaDoTempo.fromJson(Map<String, dynamic> json) => LinhaDoTempo(
        regenteNatal: EraRegente.porNome(json['regenteNatal'] as String),
        nakshatra: json['nakshatra'] as int,
        saldoInicialAnos: (json['saldoInicialAnos'] as num).toDouble(),
        nascimentoUtc:
            DateTime.parse(json['nascimentoUtc'] as String).toUtc(),
        eras: (json['eras'] as List)
            .map((e) => Era.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Fração percorrida entre dois instantes, clampada em 0.0..1.0.
double _progressoEntre(DateTime inicio, DateTime fim, DateTime quando) {
  final total = fim.difference(inicio).inMilliseconds;
  if (total <= 0) return 1.0;
  final andado = quando.difference(inicio).inMilliseconds;
  if (andado <= 0) return 0.0;
  if (andado >= total) return 1.0;
  return andado / total;
}
