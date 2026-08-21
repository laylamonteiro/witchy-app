import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/cycle_time.dart';
import '../../domain/era_ruler.dart';

/// Traduções e formatações compartilhadas pela aba Ciclos.
///
/// Os nomes dos regentes ficam aqui, e não no enum, porque o enum é
/// identidade persistida: ele nunca muda de idioma. Na tela dois deles têm
/// nome próprio — "A Serpente" e "A Cauda" — e nenhum termo técnico aparece.
extension EraRegenteLabel on EraRegente {
  String nome(AppLocalizations l10n) => switch (this) {
        EraRegente.cauda => l10n.cyclesRulerCauda,
        EraRegente.venus => l10n.cyclesRulerVenus,
        EraRegente.sol => l10n.cyclesRulerSol,
        EraRegente.lua => l10n.cyclesRulerLua,
        EraRegente.marte => l10n.cyclesRulerMarte,
        EraRegente.serpente => l10n.cyclesRulerSerpente,
        EraRegente.jupiter => l10n.cyclesRulerJupiter,
        EraRegente.saturno => l10n.cyclesRulerSaturno,
        EraRegente.mercurio => l10n.cyclesRulerMercurio,
      };
}

/// Mês e ano no idioma ativo, como "Abr 2016".
String formatarMesAno(BuildContext context, DateTime quando) {
  final locale = Localizations.localeOf(context).toString();
  final texto = DateFormat('MMM y', locale).format(quando.toLocal());
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}

/// Duração em anos e meses, como "3 anos e 8 meses".
///
/// Arredonda para o mês porque é essa a precisão em que o cálculo faz sentido
/// para quem lê: dizer "3,67 anos" seria falsa exatidão.
String formatarDuracao(AppLocalizations l10n, double anos) {
  final totalMeses = (anos * 12).round();
  if (totalMeses <= 0) return l10n.cyclesLessThanMonth;

  final quantosAnos = totalMeses ~/ 12;
  final quantosMeses = totalMeses % 12;

  if (quantosAnos == 0) return l10n.cyclesMonths(quantosMeses);
  if (quantosMeses == 0) return l10n.cyclesYears(quantosAnos);
  return l10n.cyclesDurationJoin(
    l10n.cyclesYears(quantosAnos),
    l10n.cyclesMonths(quantosMeses),
  );
}

/// Duração entre dois instantes, já em anos e meses.
String formatarIntervalo(AppLocalizations l10n, DateTime de, DateTime ate) =>
    formatarDuracao(l10n, duracaoParaAnos(ate.difference(de)));

/// Só o mês abreviado, como "ago" — para a coluna de data do céu do mês.
String formatarMesCurto(BuildContext context, DateTime quando) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat('MMM', locale).format(quando.toLocal());
}
