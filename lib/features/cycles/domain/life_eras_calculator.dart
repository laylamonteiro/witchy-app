/// Cálculo da linha do tempo de 120 anos a partir da posição da Lua natal.
///
/// Dart puro: sem Flutter, sem I/O, sem rede. Todo o resto da feature depende
/// desta função, e ela depende só dos dois argumentos.
///
/// (Sistema de referência: Vimshottari Dasha, da astrologia védica. O termo
/// não aparece em lugar nenhum da interface.)
library;

import 'cycle_time.dart';
import 'era_ruler.dart';
import 'life_timeline.dart';

/// Ayanamsa Lahiri para [quando] — a diferença entre o zodíaco tropical e o
/// sideral, em graus.
///
/// Fórmula linear ancorada em 2000-01-01 UTC. É o passo que NÃO pode faltar:
/// as efemérides do app (`SwephService`, com `SEFLG_MOSEPH`) devolvem longitude
/// tropical, e sem esta subtração a linha do tempo inteira sai deslocada em
/// cerca de um setor lunar — anos de erro nas fronteiras das Eras.
double ayanamsaLahiri(DateTime quando) {
  final decorridoMs = quando
      .toUtc()
      .difference(DateTime.utc(2000, 1, 1))
      .inMilliseconds;
  final anosDesde2000 = decorridoMs / (kAnoEmDias * kDiaEmMilissegundos);
  return 23.85306 + 0.0139721 * anosDesde2000;
}

/// Monta a linha do tempo completa.
///
/// [longitudeLuaTropical] é a longitude eclíptica absoluta da Lua natal em
/// graus (0-360), no zodíaco **tropical** — exatamente o que
/// `BirthChartModel.moon.longitude` guarda.
///
/// [nascimentoUtc] é o instante do nascimento em UTC.
LinhaDoTempo calcularLinhaDoTempo({
  required double longitudeLuaTropical,
  required DateTime nascimentoUtc,
}) {
  final nascimento = nascimentoUtc.toUtc();

  // 1. Tropical -> sideral.
  final sideral =
      (longitudeLuaTropical - ayanamsaLahiri(nascimento)) % 360.0;

  // 2. Em qual dos 27 setores lunares a Lua estava.
  var setor = sideral ~/ kNakshatraGraus;
  // Blindagem contra o caso de borda em que o arredondamento binário deixa
  // `sideral` colado em 360.0 e o setor estoura para 27.
  if (setor >= kTotalNakshatras) setor = kTotalNakshatras - 1;

  // 3. O regente natal repete a cada 9 setores.
  final regenteNatal = EraRegente.ordem[setor % EraRegente.ordem.length];

  // 4. Quanto do setor a Lua já tinha percorrido ao nascer (0.0..1.0).
  final percorrido = (sideral - setor * kNakshatraGraus) / kNakshatraGraus;

  // 5. A primeira Era entra pela metade: sobra só a parte não percorrida.
  final saldoInicialAnos = regenteNatal.anos * (1.0 - percorrido);

  // 6. As nove Eras, em ordem circular a partir do regente natal.
  final eras = <Era>[];
  var cursor = nascimento;
  for (var i = 0; i < EraRegente.ordem.length; i++) {
    final regente = regenteNatal.avancar(i);
    final parcial = i == 0;
    final anosDesta = parcial ? saldoInicialAnos : regente.anos.toDouble();
    final fim = cursor.add(anosParaDuracao(anosDesta));

    eras.add(Era(
      regente: regente,
      inicio: cursor,
      fim: fim,
      anosCompletos: regente.anos.toDouble(),
      parcial: parcial,
      fases: _fasesDaEra(
        regente: regente,
        inicioDaEra: cursor,
        fimDaEra: fim,
        anosCompletos: regente.anos.toDouble(),
        parcial: parcial,
      ),
    ));

    cursor = fim;
  }

  return LinhaDoTempo(
    eras: eras,
    regenteNatal: regenteNatal,
    nakshatra: setor,
    saldoInicialAnos: saldoInicialAnos,
    nascimentoUtc: nascimento,
  );
}

/// As nove Fases de uma Era, começando pelo próprio regente dela e seguindo a
/// ordem circular.
///
/// O detalhe que faz ou quebra o cálculo está na Era [parcial]: as Fases dela
/// precisam ser recortadas a partir de um **início virtual anterior ao
/// nascimento** (`fim − duração completa`), descartando as que terminam antes
/// de a pessoa nascer e cortando a que estava em curso. Subdividir o saldo em
/// nove partes iguais parece equivalente e não é — desloca as Fases em mais de
/// um ano para praticamente todo mundo.
List<Fase> _fasesDaEra({
  required EraRegente regente,
  required DateTime inicioDaEra,
  required DateTime fimDaEra,
  required double anosCompletos,
  required bool parcial,
}) {
  final inicioVirtual =
      parcial ? fimDaEra.subtract(anosParaDuracao(anosCompletos)) : inicioDaEra;

  final fases = <Fase>[];
  var cursor = inicioVirtual;

  for (var i = 0; i < EraRegente.ordem.length; i++) {
    final regenteDaFase = regente.avancar(i);
    final anosDaFase =
        anosCompletos * regenteDaFase.anos / kTotalAnosDoCiclo;
    final fim = cursor.add(anosParaDuracao(anosDaFase));

    // Fase inteiramente anterior ao nascimento: não existe para esta pessoa.
    if (!fim.isAfter(inicioDaEra)) {
      cursor = fim;
      continue;
    }

    fases.add(Fase(
      regente: regenteDaFase,
      regenteDaEra: regente,
      // A Fase em curso no nascimento entra recortada.
      inicio: cursor.isBefore(inicioDaEra) ? inicioDaEra : cursor,
      fim: fim,
    ));

    cursor = fim;
  }

  // Blindagem: se a pessoa nasce colada na fronteira do setor lunar, o saldo
  // da primeira Era arredonda para zero e TODAS as Fases caem no descarte.
  // Sem isto, `faseEm` estouraria num `first` sobre lista vazia.
  if (fases.isEmpty) {
    fases.add(Fase(
      regente: regente.avancar(EraRegente.ordem.length - 1),
      regenteDaEra: regente,
      inicio: inicioDaEra,
      fim: fimDaEra,
    ));
  }

  return fases;
}
